### 4.2.4. Bounded Context: Incident

El Bounded Context **Incident** es responsable de gestionar el ciclo de vida de los incidentes generados a partir de las situaciones de riesgo o emergencias (como sismos, fugas de gas o incendios) detectadas en las edificaciones monitoreadas por ResQ.
Este Bounded Context atiende las necesidades operativas y de seguimiento del sistema, asegurando que cada emergencia crítica tenga un registro formal que permita conocer su estado, asignar personal responsable para su atención, registrar su resolución y proveer un historial confiable para posteriores auditorías o cálculos de métricas de seguridad.
Sus responsabilidades se derivan principalmente de los requisitos relacionados con la trazabilidad de las emergencias y la gestión humana de las mismas una vez que la plataforma ha emitido las alertas iniciales. En particular, ResQ exige que los administradores y responsables de seguridad puedan coordinar las acciones físicas revisando y actualizando el estado de los incidentes en tiempo real.
El Bounded Context Incident soporta principalmente **US14 — Consultar el estado de un incidente**, **US15 — Asignar un responsable de atención**, **US16 — Registrar la resolución de un incidente**, así como las historias de consulta histórica **US17 — Consultar incidentes anteriores**, **US18 — Buscar incidentes históricos**, **US19 — Consultar la secuencia de un incidente** y **TS09 — Procesar información cuantitativa para indicadores**.
El Bounded Context Incident no gestiona la configuración física de los edificios, la creación de zonas, ni el inventario de dispositivos (sensores o actuadores). Estas responsabilidades pertenecen al Bounded Context Building / Infrastructure. Incident solo mantiene la referencia al identificador de la zona para saber dónde ocurrió la emergencia.
Asimismo, Incident no se encarga de ejecutar la lógica de procesamiento local (Edge Computing) que captura mediciones y evalúa si existe un riesgo en tiempo real; esto pertenece al Bounded Context Detection o Monitoring. Incident actúa como el registro oficial y el flujo de trabajo posterior a la confirmación de la detección.

Las principales responsabilidades de este Bounded Context son:

- Registrar automáticamente un nuevo incidente a partir de un evento de detección de riesgo.
- Mantener el estado actual del incidente (ej. activo, en progreso, resuelto, cerrado).
- Vincular el evento crítico con la zona específica de la edificación donde se originó.
- Permitir la asignación de un usuario autenticado (responsable de seguridad) para la atención de la emergencia.
- Registrar el cierre o resolución del incidente, incluyendo notas, tipificación u observaciones finales.
- Mantener un registro cronológico de los cambios de estado (event sequence) durante la emergencia.
- Proveer mecanismos de consulta filtrada y paginada del historial de incidentes para cálculos cuantitativos e indicadores.
- Evitar la modificación de un incidente una vez que este ha sido cerrado formalmente.
- Mantener el modelo de dominio independiente de los detalles de hardware de los dispositivos.

Los principales conceptos identificados para el Bounded Context Incident son **Incident**, **IncidentId**, **ZoneId**, **RiskType RiskLevel**, **IncidentStatus** y **AttendantId**.

#### Diccionario de clases

La siguiente tabla resume las principales clases e interfaces que conforman el Bounded Context Incident.


| Clase / Interfaz | Capa | Propósito | Atributos principales | Operaciones principales | Relaciones principales |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Incident** | Domain | Representa una emergencia confirmada. Es el Aggregate Root responsable de mantener el estado de la incidencia, controlar sus transiciones y registrar a los responsables. | id: IncidentId, zoneId: ZoneId, type: RiskType, level: RiskLevel, status: IncidentStatus, assignedTo: AttendantId, createdAt: LocalDateTime, resolvedAt: LocalDateTime, resolutionNotes: String | assignAttendant(attendantId), resolveIncident(notes), changeRiskLevel(newLevel) | Compone IncidentId, RiskType, RiskLevel, IncidentStatus; utiliza ZoneId y AttendantId como referencias externas. |
| **IncidentId** | Domain | Value Object que representa el identificador único de un incidente en el sistema. | value: UUID | value() | Compuesto por Incident. |
| **ZoneId** | Domain | Value Object que referencia la zona de la infraestructura donde ocurre el incidente. | value: UUID | value() | Utilizado por Incident (referencia externa). |
| **AttendantId** | Domain | Value Object que referencia al usuario (responsable de seguridad) asignado para atender el incidente. | value: UUID | value() | Utilizado por Incident (referencia externa). |
| **RiskType** | Domain | Enumeración que define la naturaleza del incidente detectado. | EARTHQUAKE, FIRE, GAS_LEAK, UNKNOWN | — | Utilizada por Incident. |
| **RiskLevel** | Domain | Enumeración que indica la severidad actual del incidente. | LOW, MEDIUM, HIGH, CRITICAL | — | Utilizada por Incident. |
| **IncidentStatus** | Domain | Enumeración que controla el flujo de vida del incidente. | ACTIVE, IN_PROGRESS, RESOLVED, CLOSED | — | Utilizada por Incident. |
| **IncidentRepository** | Domain | Abstracción de Repository utilizada para recuperar y persistir agregados Incident sin acoplar la Domain Layer a una tecnología específica. | — | findById(id), findAllByZoneId(zoneId), save(incident) | Persiste y recupera agregados Incident. |
| **CreateIncidentCommand** | Application | Representa la solicitud para iniciar un nuevo incidente tras una detección del sistema. | zoneId: UUID, type: String, level: String | — | Gestionado por CreateIncidentCommandHandler. |
| **CreateIncidentCommandHandler** | Application | Coordina la creación del incidente en base a la información de detección y lo persiste. | Dependencia de IncidentRepository y EventPublisher | handle(command) | Utiliza IncidentRepository. |
| **AssignIncidentCommand** | Application | Representa una solicitud de un usuario autorizado para tomar o asignar la responsabilidad de un incidente activo. | incidentId: UUID, attendantId: UUID | — | Gestionado por AssignIncidentCommandHandler. |
| **AssignIncidentCommandHandler** | Application | Recupera el incidente, invoca la asignación y persiste el cambio de estado. | Dependencia de IncidentRepository | handle(command) | Utiliza IncidentRepository. |
| **ResolveIncidentCommand** | Application | Representa una solicitud para cerrar un incidente, aportando un reporte o resumen de las acciones tomadas. | incidentId: UUID, resolutionNotes: String | — | Gestionado por ResolveIncidentCommandHandler. |
| **ResolveIncidentCommandHandler** | Application | Ejecuta la lógica de resolución en el dominio, validando que el incidente esté en un estado transicionable. | Dependencia de IncidentRepository | handle(command) | Utiliza IncidentRepository. |
| **GetHistoricalIncidentsQuery** | Application | Representa una solicitud de lectura para buscar incidentes cerrados bajo ciertos filtros (zona, fecha, tipo). | zoneId: UUID, startDate: Date, endDate: Date, status: String | — | Gestionada por GetHistoricalIncidentsQueryHandler. |
| **GetHistoricalIncidentsQueryHandler** | Application | Orquesta la lectura de datos históricos sin modificar el estado del sistema. | Dependencia de abstracciones de lectura/Data Access | handle(query) | Recupera DTOs para la vista. |
| **IncidentController** | Interface | Recibe solicitudes HTTP REST (asignar, resolver, consultar) y las delega al Command o Query Handler correspondiente. | Dependencias de Command/Query Handlers | assign(...), resolve(...), getIncidents(...) | Delega a la Application Layer. |
| **KafkaIncidentEventPublisher** | Infrastructure | Implementa el mecanismo de publicación de Domain Events (IncidentCreatedEvent, IncidentResolvedEvent) hacia un bus de mensajes para integración asíncrona. | Dependencia de cliente Kafka/Broker | publish(event) | Implementa la interfaz de publicación del dominio. |
| **JpaIncidentRepository** | Infrastructure | Implementa IncidentRepository utilizando JPA/Hibernate para persistir los incidentes en una base de datos relacional. | Dependencia de persistencia (Base de Datos) | findById(), save(), findAllByZoneId() | Implementa IncidentRepository. |

Las relaciones entre estas clases preservan estrictamente los límites del Bounded Context. `Incident` mantiene únicamente el zoneId para contextualizar geográficamente la emergencia, pero no almacena detalles del edificio ni la lista de sensores.

Del mismo modo, almacena el `AttendantId` para indicar quién está atendiendo el problema, pero delega la gestión de información personal, permisos y credenciales de ese empleado al Bounded Context correspondiente (User o IAM).

---

#### 4.2.4.1. Domain Layer

La Domain Layer encapsula la lógica de negocio central y las reglas para la gestión de incidentes, asegurando que las transiciones de estado sean válidas y coherentes con la realidad física de la emergencia.

**Aggregate Root**
 * **`Incident`:**

Un `Incident` representa una emergencia detectada en una zona específica de la edificación. Controla su propio ciclo de vida y asegura la consistencia de sus datos.

**Categoría:** Aggregate Root / Entity.

**Propósito:** Representar la entidad principal de una emergencia dentro del sistema, gestionando sus estados, asignaciones y resoluciones bajo reglas estrictas de dominio.

**Atributos / Elementos del Dominio:**

* **Value Objects:**
    * **`incidentId`:** IncidentId — Identificador único del incidente.
    * **`zoneId`:** ZoneId — Referencia a la zona donde se originó el problema (vinculación con el contexto de Infraestructura/Edificación).
    * **`type`:** RiskType — Tipo de emergencia (e.g., EARTHQUAKE, FIRE, GAS_LEAK).
    * **`level`:** RiskLevel — Nivel de gravedad del incidente (e.g., LOW, MEDIUM, HIGH, CRITICAL).
    * **`status`:** IncidentStatus — Estado actual del incidente (e.g., ACTIVE, IN_PROGRESS, RESOLVED, CLOSED).
    * **`assignedTo`:** AttendantId — Identificador del usuario responsable de seguridad asignado a la atención.

* **Domain Events:**
    * **`IncidentCreatedEvent`:** Emitido cuando el sistema registra un nuevo incidente tras una detección crítica.
    * **`IncidentAssignedEvent`:** Emitido cuando un responsable asume o es asignado a la atención del incidente.
    * **`IncidentResolvedEvent`:** Emitido cuando se registra la solución del evento, permitiendo a otros contextos (como notificaciones o analítica) reaccionar.

* **Domain Services:**
    * **`IncidentMetricsService`:** Servicio de dominio para calcular tiempos de respuesta y resolución en base al historial.

* **Repositories (Interfaces):**
    * **`IncidentRepository`:** Define los contratos para persistir y recuperar agregados `Incident`.


### 4.2.8.2. Interface Layer

La Interface Layer define los puntos de entrada al Bounded Context, exponiendo las capacidades de ResQ hacia las aplicaciones cliente (web o móvil) mediante una API RESTful.

El controlador principal es `IncidentController`.

Un `IncidentController` maneja las peticiones HTTP relacionadas con la gestión de incidentes, validando los datos de entrada y delegando la ejecución hacia la Application Layer.

#### IncidentController

**Categoría:** REST Controller / Interface.

**Propósito:** Exponer los endpoints HTTP para la consulta, asignación y resolución de emergencias e incidentes en el sistema.

**Endpoints Principales:**

* **`GET /api/v1/incidents`:** Recupera la lista de incidentes (activos e históricos) con soporte para filtros por zona, tipo y estado.
* **`GET /api/v1/incidents/{incidentId}`:** Obtiene los detalles y el contexto de un incidente específico.
* **`PATCH /api/v1/incidents/{incidentId}/assign`:** Asigna un responsable de seguridad a un incidente activo.
* **`PATCH /api/v1/incidents/{incidentId}/resolve`:** Registra la resolución de un incidente, cambiando su estado y almacenando las observaciones finales.

**Data Transfer Objects (DTOs):**

* **`IncidentResponseDTO`:** Representación plana del incidente para la vista.
* **`AssignIncidentCommandDTO`:** Payload con los datos del responsable asignado.
* **`ResolveIncidentCommandDTO`:** Payload con el resumen o tipificación de la resolución.

### 4.2.8.3. Application Layer

La Application Layer orquesta los flujos de trabajo delegando la ejecución a los objetos del dominio. Se implementa utilizando el patrón CQRS (Command Query Responsibility Segregation) a nivel lógico para separar las operaciones de lectura y escritura.

Los manejadores se dividen según su responsabilidad en comandos y consultas.

#### Application Components

**Categoría:** Application Services / CQRS Handlers.

**Propósito:** Coordinar los casos de uso del sistema, gestionando las transacciones de escritura y abstrayendo las consultas de lectura sin alterar el estado del dominio.

**Componentes Principales:**

* **Command Handlers (Escritura):**
    * **`CreateIncidentCommandHandler`:** Orquesta la creación de un nuevo incidente (generalmente invocado por un evento asíncrono desde el contexto de Detección).
    * **`AssignIncidentCommandHandler`:** Valida los permisos y ejecuta el método de asignación en el Aggregate Root.
    * **`ResolveIncidentCommandHandler`:** Ejecuta la lógica de cierre del incidente y persiste el cambio.

* **Query Handlers (Lectura):**
    * **`GetIncidentByIdQueryHandler`:** Recupera los detalles de un incidente específico.
    * **`GetHistoricalIncidentsQueryHandler`:** Ejecuta búsquedas paginadas y filtradas para la consulta de incidentes anteriores.

### 4.2.8.4. Infrastructure Layer

La Infrastructure Layer implementa las interfaces definidas en las capas superiores, gestionando la persistencia en la base de datos y la comunicación externa con el bus de mensajes.

Los componentes se dividen en mecanismos de persistencia y adaptadores dirigidos por eventos.

#### Infrastructure Components

**Categoría:** Infrastructure Services / Adapters.

**Propósito:** Proveer las implementaciones técnicas concretas para el almacenamiento de datos y la integración asíncrona con otros sistemas.

**Componentes de Persistencia:**

* **`JpaIncidentRepository`:** Implementación de `IncidentRepository` utilizando Spring Data JPA para la gestión del ciclo de vida de los datos.
* **`IncidentEntity`:** Entidad de infraestructura mapeada directamente a las tablas de la base de datos relacional (MySQL/PostgreSQL).
* **`IncidentMapper`:** Componente encargado de transformar los datos entre `IncidentEntity` (Infraestructura) e `Incident` (Dominio) para mantener el desacoplamiento.

**Componentes de Mensajería (Event-Driven):**

* **`KafkaIncidentEventPublisher`:** Implementación encargada de publicar los *Domain Events* hacia un tópico de Apache Kafka (e.g., `resq.incident.events`), facilitando la integración asíncrona con los contextos de Notificaciones o Analítica.
* **`DetectionEventListener`:** Consumidor de Kafka que escucha activamente los eventos de riesgo crítico detectados en el Edge para instanciar automáticamente los incidentes en el sistema.

### 4.2.8.4. Infrastructure Layer

La Infrastructure Layer implementa las interfaces definidas en las capas superiores, gestionando la persistencia en la base de datos y la comunicación externa con el bus de mensajes.

Los componentes se dividen en mecanismos de persistencia y adaptadores dirigidos por eventos.

#### Infrastructure Components

**Categoría:** Infrastructure Services / Adapters.

**Propósito:** Proveer las implementaciones técnicas concretas para el almacenamiento de datos y la integración asíncrona con otros sistemas.

**Componentes de Persistencia:**

* **`JpaIncidentRepository`:** Implementación de `IncidentRepository` utilizando Spring Data JPA para la gestión del ciclo de vida de los datos.
* **`IncidentEntity`:** Entidad de infraestructura mapeada directamente a las tablas de la base de datos relacional (MySQL/PostgreSQL).
* **`IncidentMapper`:** Componente encargado de transformar los datos entre `IncidentEntity` (Infraestructura) e `Incident` (Dominio) para mantener el desacoplamiento.

**Componentes de Mensajería (Event-Driven):**

* **`KafkaIncidentEventPublisher`:** Implementación encargada de publicar los *Domain Events* hacia un tópico de Apache Kafka (e.g., `resq.incident.events`), facilitando la integración asíncrona con los contextos de Notificaciones o Analítica.
* **`DetectionEventListener`:** Consumidor de Kafka que escucha activamente los eventos de riesgo crítico detectados en el Edge para instanciar automáticamente los incidentes en el sistema.


#### 4.2.8.5. Bounded Context Software Architecture Component Level Diagrams

 ### Flujo Principal de Interacción

El flujo principal del Incident Bounded Context se desarrolla de manera secuencial a través de las distintas capas de la arquitectura para garantizar el cumplimiento de las reglas de negocio y el desacoplamiento técnico:

1. **Solicitud del usuario:** El cliente (aplicación web o móvil) envía una solicitud HTTP para consultar, asignar o resolver un incidente.
2. **IncidentController:** La Interface Layer recibe la petición, valida el formato del DTO de entrada y la dirige al manejador correspondiente en la capa superior.
3. **Application Layer:** El componente de aplicación toma el control utilizando el patrón CQRS; un `IncidentCommandHandler` procesa las operaciones de escritura, mientras que un `IncidentQueryHandler` gestiona las consultas de lectura.
4. **Incident Aggregate:** En operaciones de escritura, el agregador `Incident` ejecuta la lógica de negocio central, valida las transiciones de estado y asegura la consistencia de la emergencia.
5. **Repository Interface:** La capa de aplicación utiliza la abstracción `IncidentRepository` para solicitar la persistencia o recuperación del agregado sin acoplarse a la tecnología de almacenamiento.
6. **JPA Repository:** La Infrastructure Layer, a través de `JpaIncidentRepository`, implementa dicho contrato y realiza las consultas u operaciones físicas sobre la base de datos PostgreSQL.
7. **Kafka Publisher:** Si la regla de negocio del agregador generó un cambio significativo, `KafkaIncidentEventPublisher` publica los eventos de dominio resultantes (como `IncidentCreatedEvent` o `IncidentResolvedEvent`) en el bus de mensajes.
8. **Respuesta:** El resultado del proceso se transforma de nuevo a un DTO y retorna a través del `IncidentController` hacia el cliente con el estado HTTP correspondiente.


![Flujo Process Diagram](assets/images/chapter-04-solution-software-desing/chapter-04-flujo-process-diagram.png)

**Diagrama - Incidente Component Level Diagram**
 
 El siguiente diagrama C4 (Nivel 3: Componentes) detalla la estructura interna del Bounded Context de Incidentes organizada en cuatro capas:
- Interface Layer: recibe y gestiona las solicitudes mediante el Incident Controller.
- Application Layer: coordina los casos de uso de incidentes, separando operaciones de escritura y consulta.
- Domain Layer: contiene las reglas de negocio mediante el Incident Aggregate y define el contrato de persistencia mediante Incident Repository Interface.
- Infrastructure Layer: implementa la persistencia con JPA Incident Repository y la comunicación mediante eventos con Kafka Event Publisher.
- Base de datos: almacena la información de los incidentes y registros relacionados.

Las relaciones entre los componentes muestran cómo las solicitudes atraviesan las diferentes capas, manteniendo una separación de responsabilidades y facilitando el mantenimiento y evolución del sistema.

![Incident Component Level Diagram](assets/images/chapter-04-solution-software-desing/chapter-04-component-level-diagram.png)

