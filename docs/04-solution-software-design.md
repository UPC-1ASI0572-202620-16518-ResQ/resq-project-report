# Capítulo IV: Solution Software Design

> Imágenes del capítulo:
> `assets/images/chapter-04-solution-software-design/`

## 4.1. Strategic-Level Domain-Driven Design

### 4.1.1. Design-Level EventStorming

#### 4.1.1.1. Candidate Context Discovery
[COMPLETAR]

#### 4.1.1.2. Domain Message Flows Modeling
[COMPLETAR]

#### 4.1.1.3. Bounded Context Canvases
[COMPLETAR]

### 4.1.2. Context Mapping
[COMPLETAR]

### 4.1.3. Software Architecture

#### 4.1.3.1. Software Architecture System Landscape Diagram
[INSERTAR DIAGRAMA + EXPLICACIÓN]

#### 4.1.3.2. Software Architecture Context Level Diagrams
[INSERTAR DIAGRAMAS + EXPLICACIÓN]

#### 4.1.3.2. Software Architecture Container Level Diagrams
[INSERTAR DIAGRAMAS + EXPLICACIÓN]

#### 4.1.3.3. Software Architecture Deployment Diagrams
[INSERTAR DIAGRAMA + EXPLICACIÓN]

> Nota: se conserva la numeración del Project Statement, que repite 4.1.3.2.

## 4.2. Tactical-Level Domain-Driven Design

Building Management (Buildings) y Device Management (Devices) corresponden a los contextos **Building** y **Device** del informe de alineamiento; no son contextos adicionales. Las referencias a historias de estas dos secciones utilizan la tabla actualizada de 3.1 del [README del equipo, versión 7fb3499](https://github.com/UPC-1ASI0572-202620-16518-ResQ/resq-project-report/blob/7fb349974c2f4b1ca8983e35eb93f76d2e1a403a/README.md#31-user-stories). Las épicas agrupan resultados de usuario y pueden requerir la colaboración de varios contextos.

El profesional de una integradora accede al entorno del cliente mediante permisos concedidos por IAM y User. `organizationId` identifica la organización del registro, no necesariamente la empresa empleadora del integrador. Participar en una instalación no concede acceso automático a todos los edificios ni a otros clientes.

### 4.2.3. Bounded Context: Building Management

Building conserva la estructura de edificaciones y zonas. Atiende **US21 — Registrar una edificación** y **US22 — Definir zonas de una edificación**, de EP05. Colabora con Device en US23 y US33 al validar ubicaciones; proporciona contexto a Monitoring y Risk Detection sin asumir mediciones, detección, integración de protocolos ni soporte comercial.

#### 4.2.3.1. Domain Layer

**Aggregates**

`Building`

Raíz del aggregate que representa una edificación de una organización. Mantiene su identificación, dirección, estado administrativo y zonas. Todas las modificaciones de una zona se realizan a través de Building.

| Atributo | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| id | Guid | Private | Identificador interno e inmutable de la edificación. |
| organizationId | Guid | Private | Organización a la que pertenece la edificación. |
| buildingCode | BuildingCode | Private | Código único dentro de la organización. |
| name | string | Private | Nombre de la edificación, entre 1 y 120 caracteres. |
| description | string? | Private | Descripción opcional de hasta 500 caracteres. |
| address | BuildingAddress | Private | Dirección física de la edificación. |
| administrativeStatus | LocationAdministrativeStatus | Private | Estado administrativo ACTIVE o INACTIVE. |
| zones | List\<Zone\> | Private | Zonas de la edificación; puede estar vacía al registrarse. |
| createdAt | DateTimeOffset | Private | Fecha y hora UTC de registro. |
| updatedAt | DateTimeOffset | Private | Fecha y hora UTC de la última modificación del agregado. |
| version | long | Private | Versión del agregado, incluidos los cambios en sus zonas. |

| Método | Tipo de retorno | Descripción |
|---|---|---|
| Register(...) | Building | Registra una edificación activa, inicialmente sin zonas. |
| UpdateDetails(name, description, address) | void | Actualiza los datos descriptivos y la dirección. |
| ChangeAdministrativeStatus(status) | void | Activa o desactiva administrativamente la edificación. |
| AddZone(zoneCode, name, description, floorLabel) | Zone | Agrega una zona activa a una edificación activa y verifica que su código no se repita. |
| UpdateZone(zoneId, name, description, floorLabel) | void | Modifica los datos de una zona perteneciente a la edificación. |
| ChangeZoneAdministrativeStatus(zoneId, status) | void | Cambia el estado de una zona; su activación exige una edificación activa. |
| IsAvailableForAssignment(zoneId?) | bool | Comprueba si la edificación y, cuando se indica, la zona están disponibles para asignar dispositivos. |

**Entities**

`Zone`

**Descripción:** Área física de una edificación, como una cocina, un almacén o una sala técnica. Tiene identidad propia y pertenece a un único Building. No contiene dispositivos, mediciones ni reglas de detección.

| Atributo | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| id | Guid | Private | Identificador interno e inmutable de la zona. |
| zoneCode | ZoneCode | Private | Código único dentro de la edificación. |
| name | string | Private | Nombre de la zona, entre 1 y 120 caracteres. |
| description | string? | Private | Descripción opcional de hasta 500 caracteres. |
| floorLabel | string? | Private | Referencia opcional del nivel, hasta 50 caracteres; por ejemplo, Piso 2 o Sótano 1. |
| administrativeStatus | LocationAdministrativeStatus | Private | Estado administrativo propio de la zona. |
| createdAt | DateTimeOffset | Private | Fecha y hora UTC de creación. |
| updatedAt | DateTimeOffset | Private | Fecha y hora UTC de su última modificación. |

El nivel es un dato descriptivo; esta propuesta no incorpora un agregado Floor ni una jerarquía de zonas. Zone no tiene repositorio independiente ni cambia de edificación. Si el área física se reemplaza, se registra otra zona y se desactiva la anterior para conservar sus referencias.

**Value Objects**

| Value Object (`record`) | Atributos | Validación y significado |
|---|---|---|
| BuildingCode | value: string | Entre 1 y 64 caracteres; letras ASCII, números, guion y guion bajo. Se eliminan espacios exteriores y se convierte a mayúsculas. |
| ZoneCode | value: string | Aplica la misma normalización que BuildingCode; su unicidad se limita a la edificación. |
| BuildingAddress | streetAddress: string, district: string, city: string, countryCode: string | Dirección de hasta 200 caracteres; distrito y ciudad de hasta 100; código de país de dos letras mayúsculas, por ejemplo PE. Todos los campos son obligatorios. |

Los identificadores rechazan `Guid.Empty`. Los códigos, la organización y la pertenencia de una zona son inmutables. Las propiedades públicas de records en C# utilizan PascalCase; los campos de los contratos JSON se presentan en camelCase.

**Enumerations**

| Enumeración | Valores | Significado |
|---|---|---|
| LocationAdministrativeStatus | ACTIVE, INACTIVE | Ubicación habilitada o deshabilitada administrativamente para nuevas asignaciones. |

Desactivar una edificación impide nuevas asignaciones tanto a ella como a sus zonas, pero conserva el estado propio de cada zona. Al reactivarla, solo quedan disponibles las zonas que conservan ACTIVE. No se eliminan asociaciones existentes ni se confirma ninguna acción sobre equipos físicos. Estos estados y las reglas de normalización son decisiones de diseño propuestas para desarrollar US21 y US22; no se presentan como requisitos explícitos de sus criterios de aceptación.

**Commands**

`organizationId` procede del contexto autorizado. `expectedVersion` corresponde siempre a la versión de Building, incluso al modificar una zona.

| Command (`record`) | Datos |
|---|---|
| RegisterBuildingCommand | organizationId, buildingCode, name, description?, address |
| UpdateBuildingDetailsCommand | organizationId, buildingId, name, description?, address, expectedVersion |
| ChangeBuildingAdministrativeStatusCommand | organizationId, buildingId, administrativeStatus, expectedVersion |
| AddZoneToBuildingCommand | organizationId, buildingId, zoneCode, name, description?, floorLabel?, expectedVersion |
| UpdateZoneCommand | organizationId, buildingId, zoneId, name, description?, floorLabel?, expectedVersion |
| ChangeZoneAdministrativeStatusCommand | organizationId, buildingId, zoneId, administrativeStatus, expectedVersion |

**Queries**

| Query (`record`) | Datos | Resultado |
|---|---|---|
| GetBuildingByIdQuery | organizationId, buildingId | Building? |
| GetBuildingsQuery | organizationId, administrativeStatus?, page, size | PagedResult\<Building\> |
| GetZonesByBuildingIdQuery | organizationId, buildingId, administrativeStatus?, page, size | PagedResult\<Zone\> |
| GetZoneByIdQuery | organizationId, buildingId, zoneId | Zone? |

**Services**

| Interfaz | Método | Tipo de retorno |
|---|---|---|
| IBuildingCommandService | Handle(RegisterBuildingCommand) | Building |
| IBuildingCommandService | Handle(UpdateBuildingDetailsCommand) | Building |
| IBuildingCommandService | Handle(ChangeBuildingAdministrativeStatusCommand) | Building |
| IBuildingCommandService | Handle(AddZoneToBuildingCommand) | Building |
| IBuildingCommandService | Handle(UpdateZoneCommand) | Building |
| IBuildingCommandService | Handle(ChangeZoneAdministrativeStatusCommand) | Building |
| IBuildingQueryService | Handle(GetBuildingByIdQuery) | Building? |
| IBuildingQueryService | Handle(GetBuildingsQuery) | PagedResult\<Building\> |
| IBuildingQueryService | Handle(GetZonesByBuildingIdQuery) | PagedResult\<Zone\> |
| IBuildingQueryService | Handle(GetZoneByIdQuery) | Zone? |

`IBuildingRepository` declara el contrato de persistencia del agregado. `BuildingReadScope` representa las edificaciones y zonas visibles para el solicitante; `BuildingFilters` y `ZoneFilters` contienen los filtros de consulta. Estos contratos no dependen del framework web ni de clases internas de IAM. `PagedResult<T>` contiene Items, Page, Size, TotalElements y TotalPages.

**Domain Events**

| Evento | Se produce cuando |
|---|---|
| BuildingRegistered | Se registra una edificación. |
| BuildingDetailsUpdated | Cambian sus datos descriptivos o dirección. |
| BuildingAdministrativeStatusChanged | Cambia el estado administrativo de la edificación. |
| ZoneAddedToBuilding | Se agrega una zona. |
| ZoneDetailsUpdated | Cambian los datos descriptivos de una zona. |
| ZoneAdministrativeStatusChanged | Cambia el estado administrativo de una zona. |

Cada cambio efectivo incrementa una vez la versión de Building y genera un evento. Repetir valores existentes no produce un cambio adicional. El mensaje de integración contiene eventId, eventType, schemaVersion, organizationId, buildingId, aggregateVersion, occurredAt y una instantánea de la edificación con sus zonas. Los cambios de zona incluyen además affectedZoneId. La aplicación conserva el mensaje mediante una outbox para informar a los consumidores sin compartir tablas.

#### 4.2.3.2. Interface Layer

**REST Controllers**

`BuildingsController`

**Descripción:** Expone el registro y consulta de edificaciones y zonas. Construye comandos y consultas, aplica el contrato HTTP y transforma los resultados en recursos. Las rutas anidadas expresan que cada zona pertenece a una edificación.

| Método | Ruta | Descripción | Respuesta exitosa |
|---|---|---|---|
| RegisterBuilding() | POST /api/v1/buildings | Registra una edificación. | 201, BuildingResource, Location y ETag |
| GetBuildings() | GET /api/v1/buildings | Lista edificaciones; admite administrativeStatus, page y size. | 200, BuildingPageResource |
| GetBuildingById() | GET /api/v1/buildings/{buildingId} | Consulta una edificación y sus zonas visibles. | 200, BuildingResource y ETag |
| UpdateBuildingDetails() | PUT /api/v1/buildings/{buildingId}/details | Actualiza nombre, descripción y dirección. | 200, BuildingResource y ETag |
| ChangeBuildingAdministrativeStatus() | PUT /api/v1/buildings/{buildingId}/administrative-status | Activa o desactiva la edificación. | 200, BuildingResource y ETag |
| AddZoneToBuilding() | POST /api/v1/buildings/{buildingId}/zones | Agrega una zona a la edificación. | 201, BuildingResource, Location de la zona y ETag |
| GetZonesByBuildingId() | GET /api/v1/buildings/{buildingId}/zones | Lista zonas; admite administrativeStatus, page y size. | 200, ZonePageResource |
| GetZoneById() | GET /api/v1/buildings/{buildingId}/zones/{zoneId} | Consulta una zona de la edificación indicada. | 200, ZoneResource |
| UpdateZone() | PUT /api/v1/buildings/{buildingId}/zones/{zoneId}/details | Actualiza los datos de una zona. | 200, BuildingResource y ETag |
| ChangeZoneAdministrativeStatus() | PUT /api/v1/buildings/{buildingId}/zones/{zoneId}/administrative-status | Activa o desactiva una zona. | 200, BuildingResource y ETag |

Los PUT y el POST de creación de una zona requieren `If-Match` con el ETag de Building, obtenido en GET /buildings/{buildingId}. Los comandos devuelven el agregado actualizado y su nuevo ETag; una zona no tiene versión independiente. La paginación comienza en cero, con tamaño predeterminado 20 y máximo 100, y utiliza un orden estable por createdAt e id. No se exponen operaciones DELETE.

**Resources**

| Resource (`record`) | Contenido |
|---|---|
| RegisterBuildingResource | buildingCode, name, description?, address |
| UpdateBuildingDetailsResource | name, description?, address |
| ChangeBuildingAdministrativeStatusResource | administrativeStatus |
| AddZoneToBuildingResource | zoneCode, name, description?, floorLabel? |
| UpdateZoneResource | name, description?, floorLabel? |
| ChangeZoneAdministrativeStatusResource | administrativeStatus |
| BuildingAddressResource | streetAddress, district, city, countryCode |
| BuildingResource | id, organizationId, buildingCode, name, description?, address, administrativeStatus, zones, createdAt, updatedAt, version |
| ZoneResource | id, buildingId, zoneCode, name, description?, floorLabel?, administrativeStatus, availableForAssignment, createdAt, updatedAt |
| BuildingPageResource | items: List\<BuildingResource\>, page, size, totalElements, totalPages |
| ZonePageResource | items: List\<ZoneResource\>, page, size, totalElements, totalPages |
| ErrorResource | code, message, fieldErrors?, traceId |

`availableForAssignment` se calcula con el estado de Building y Zone; no se almacena como columna. Los filtros de estado de zonas se refieren a su estado propio. Los recursos de entrada no aceptan organizationId, IDs generados, fechas ni versión como campos editables. Todas las salidas, incluidas las zonas anidadas y los totales, respetan el alcance autorizado.

**Assemblers**

| Assembler | Responsabilidad |
|---|---|
| RegisterBuildingCommandFromResourceAssembler | Construye RegisterBuildingCommand con el recurso y la organización autorizada. |
| UpdateBuildingDetailsCommandFromResourceAssembler | Construye UpdateBuildingDetailsCommand con el recurso, buildingId y versión esperada. |
| ChangeBuildingAdministrativeStatusCommandFromResourceAssembler | Construye ChangeBuildingAdministrativeStatusCommand. |
| AddZoneToBuildingCommandFromResourceAssembler | Construye AddZoneToBuildingCommand usando la versión de Building. |
| UpdateZoneCommandFromResourceAssembler | Construye UpdateZoneCommand con buildingId, zoneId y versión esperada. |
| ChangeZoneAdministrativeStatusCommandFromResourceAssembler | Construye ChangeZoneAdministrativeStatusCommand. |
| BuildingQueriesFromRequestAssembler | Convierte parámetros de ruta y consulta en las cuatro consultas del dominio. |
| BuildingResourceFromEntityAssembler | Convierte Building y las zonas visibles en BuildingResource. |
| ZoneResourceFromEntityAssembler | Convierte Zone y el estado de su Building en ZoneResource. |
| BuildingPageResourceFromPageAssembler | Construye BuildingPageResource. |
| ZonePageResourceFromPageAssembler | Construye ZonePageResource. |

**Contrato de errores**

| Código HTTP | Situación |
|---|---|
| 400 | Identificadores vacíos, campos, estados o paginación inválidos. |
| 401 | Identidad ausente o inválida. |
| 403 | Falta permiso para registrar o modificar la ubicación. |
| 404 | Edificación o zona no encontrada dentro del ámbito visible, incluida una zona que no pertenece a la edificación indicada. |
| 409 | Código duplicado; creación o activación de una zona en una edificación inactiva. |
| 412 | La versión de Building ya cambió. |
| 428 | Falta If-Match al modificar un agregado existente. |
| 503 | No puede completarse una validación de autorización obligatoria. |


**Fachada de integración**

`BuildingsContextFacade` expone `ValidateAssignment(organizationId, buildingId, zoneId?)` a contextos autorizados. Utiliza `IBuildingQueryService` para comprobar organización, existencia, pertenencia de la zona y disponibilidad administrativa. Devuelve `BuildingAssignmentValidation` con organizationId, buildingId, zoneId, buildingVersion y availableForAssignment; no entrega entidades persistentes. Una ubicación inexistente o no visible responde como no encontrada y una ubicación inactiva no se considera disponible. Device traduce la respuesta a su contrato local `ValidatedAssignment`. Esta fachada completa el componente ya representado en el diagrama.

#### 4.2.3.3. Application Layer

`BuildingCommandServiceImpl`

**Descripción:** Implementa IBuildingCommandService. Verifica permisos, carga el agregado, aplica sus reglas y persiste Building, sus zonas y el mensaje outbox en una transacción local.

| Método | Descripción |
|---|---|
| Handle(RegisterBuildingCommand) | Comprueba permiso de creación en la organización y código disponible; registra la edificación activa con versión 1. |
| Handle(UpdateBuildingDetailsCommand) | Verifica acceso y versión; actualiza nombre, descripción y dirección. |
| Handle(ChangeBuildingAdministrativeStatusCommand) | Cambia el estado de Building sin eliminar zonas ni modificar sus estados propios. |
| Handle(AddZoneToBuildingCommand) | Verifica acceso, versión y edificación activa; agrega una zona con código único dentro del agregado. |
| Handle(UpdateZoneCommand) | Comprueba que la zona pertenece al Building y es editable por el solicitante; actualiza sus datos descriptivos. |
| Handle(ChangeZoneAdministrativeStatusCommand) | Cambia el estado propio de la zona; exige Building activo para activarla. |

Toda modificación de Zone incrementa la versión de Building. Una escritura compara expectedVersion con la versión almacenada y revierte la transacción completa ante conflicto. Las restricciones únicas de MySQL también protegen frente a registros simultáneos. Una edificación o zona inactiva puede conservar y corregir sus datos descriptivos.

`BuildingQueryServiceImpl`

**Descripción:** Implementa IBuildingQueryService sin modificar datos. Aplica los filtros y el alcance de IAM antes de paginar o calcular los totales.

| Método | Descripción |
|---|---|
| Handle(GetBuildingByIdQuery) | Obtiene una edificación dentro de la organización y el alcance del solicitante. |
| Handle(GetBuildingsQuery) | Lista las edificaciones visibles por estado administrativo. |
| Handle(GetZonesByBuildingIdQuery) | Lista las zonas visibles de la edificación indicada. |
| Handle(GetZoneByIdQuery) | Obtiene una zona comprobando su edificación, organización y alcance autorizado. |

**Puertos de aplicación e integración**

| Puerto | Métodos principales | Responsabilidad |
|---|---|---|
| IBuildingAccessGateway | RequirePermission(action, organizationId, buildingId?, zoneId?); GetReadScope(organizationId): BuildingReadScope | Valida permisos de IAM para la organización y ubicación. La creación de una edificación exige permiso a nivel de organización. |
| IBuildingOutboxRepository | Append(message); FindPending(batchSize); MarkPublished(eventId); RecordFailure(eventId, nextAttemptAt) | Conserva los mensajes de integración y su estado de publicación. |
| IBuildingEventPublisher | Publish(message) | Entrega mensajes a los consumidores mediante el transporte configurado. |

`BuildingIntegrationEventMapper` construye el mensaje con la instantánea del agregado. `BuildingOutboxDispatcher` publica mensajes pendientes y reintenta los fallidos. Los consumidores deduplican por eventId y aplican únicamente versiones superiores a la conocida. Un fallo de publicación posterior al commit conserva el mensaje pendiente.

**Coordinación con Device Management**

Buildings conserva los identificadores de edificaciones y zonas, incluso cuando están inactivas. Esta entrega utiliza desactivación reversible; no incorpora retiro definitivo ni eliminación física. Devices consulta la fachada al registrar, reasignar o activar un equipo. Desactivar una ubicación bloquea futuras validaciones, pero no borra dispositivos ni altera mediciones o incidentes anteriores.

La validación describe la disponibilidad en el momento de la consulta. Si una asignación y una desactivación se ejecutan simultáneamente en servicios separados, la consulta por sí sola no garantiza atomicidad entre contextos. La integración deberá revalidar o reconciliar esa asignación ante cambios concurrentes; no se interpreta una respuesta válida como una reserva permanente. Las instantáneas históricas conservadas por Monitoring e Incident Management no se reescriben al renombrar una ubicación.

#### 4.2.3.4. Infrastructure Layer

**Persistencia del agregado**

`IBuildingRepository` / `RelationalBuildingRepository`

**Descripción:** IBuildingRepository define el contrato del dominio. RelationalBuildingRepository guarda el agregado y consulta sus zonas en MySQL. No se publica un repositorio de escritura independiente para Zone.

| Método del puerto | Tipo de retorno | Descripción |
|---|---|---|
| FindByIdAndOrganizationId(buildingId, organizationId) | Building? | Recupera Building con sus zonas dentro de una organización; la aplicación verifica además el alcance de acceso. |
| FindPage(organizationId, filters, readScope, page, size) | PagedResult\<Building\> | Consulta edificaciones visibles y aplica el filtro de estado. |
| FindZonesPage(organizationId, buildingId, filters, readScope, page, size) | PagedResult\<Zone\> | Consulta zonas mediante su relación con Building y aplica el alcance antes de paginar. |
| FindZoneById(organizationId, buildingId, zoneId) | Zone? | Busca una zona que pertenezca a la edificación y organización indicadas. |
| ExistsByOrganizationIdAndBuildingCode(organizationId, buildingCode) | bool | Detecta códigos de edificación repetidos. |
| Save(building, expectedVersion?) | Building | Inserta o actualiza Building y sus zonas de forma atómica, con control de versión. |

La unicidad del código de zona se verifica dentro del agregado y mediante UNIQUE(building_id, zone_code). Las consultas de zonas siempre se restringen por la organización del Building; no se acepta zoneId como prueba suficiente de acceso.

**Adaptadores**

| Componente | Puerto implementado | Descripción |
|---|---|---|
| IamBuildingAccessAdapter | IBuildingAccessGateway | Adapta los permisos y el alcance de IAM. |
| RelationalBuildingOutboxRepository | IBuildingOutboxRepository | Persiste mensajes en la misma transacción y base de datos del agregado. |
| BuildingEventPublisherAdapter | IBuildingEventPublisher | Publica mensajes mediante el transporte de integración elegido. |
| BuildingPersistenceMapper | No aplica | Convierte Building, Zone y sus value objects hacia y desde registros relacionales. |


#### 4.2.3.5. Bounded Context Software Architecture Component Level Diagrams

![Diagrama de componentes de Building Management](../assets/images/chapter-04-solution-software-design/buildings-components.png)

Web y Mobile son contenedores separados y consumen BuildingsController. Los servicios de aplicación coordinan reglas de Building y Zone y persistencia en MySQL. Device valida ubicaciones mediante BuildingsContextFacade. La vista muestra el flujo principal; los adaptadores de IAM y publicación outbox se detallan en las capas anteriores para mantener el diagrama simple.

#### 4.2.3.6. Bounded Context Software Architecture Code Level Diagrams

##### 4.2.3.6.1. Bounded Context Domain Layer Class Diagrams

![Diagrama UML del agregado Building](../assets/images/chapter-04-solution-software-design/buildings-domain-model.png)
![Diagrama UML de contratos de Building Management](../assets/images/chapter-04-solution-software-design/buildings-domain-contracts.png)

Building es la raíz y contiene cero o más zonas, cada una perteneciente a una única edificación. Los value objects encapsulan códigos y dirección; los contratos de comandos, consultas y repositorio operan sobre esa estructura. Renombrar una zona mantiene su identidad y referencias, en correspondencia con US22, AC2.

##### 4.2.3.6.2. Bounded Context Database Design Diagram

![Diagrama relacional de Building Management](../assets/images/chapter-04-solution-software-design/buildings-database.png)

`zones.building_id` referencia a `buildings.id`. Los códigos son únicos por organización o edificación, respectivamente. `building_outbox` conserva los mensajes de integración en la misma transacción que el agregado; es una tabla técnica. `organization_id` es una referencia externa, sin FK hacia otro bounded context. La versión de Building también controla los cambios en sus zonas.

### 4.2.4. Bounded Context: Device Management

Device conserva el catálogo de equipos, capacidades, estado administrativo y asignación. Atiende **US23 — Asociar un dispositivo con una zona** (EP05) y aporta el mapeo de **US33 — Asociar dispositivos externos con su contexto** (EP07). Su registro de equipos es una operación de apoyo necesaria para esas historias. Conectividad (denominado «Connectividad» en el informe) coordina mecanismos de conexión, recepción y pruebas de integración de US30–US32; Monitoring mantiene las mediciones y disponibilidad operativa. Registrar una referencia externa no demuestra por sí solo que una integración funciona.

#### 4.2.4.1. Domain Layer

**Aggregates**

`Device`

Raíz del aggregate que representa un equipo IoT registrado en una organización. Controla sus características, capacidades y asignación física. Un mismo equipo puede medir varias variables y ejecutar acciones; por ello se utiliza una colección de capacidades en lugar de exigir que sea exclusivamente sensor o actuador.

| Atributo | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| id | Guid | Private | Identificador interno e inmutable del dispositivo. |
| organizationId | Guid | Private | Identificador de la organización propietaria del registro; no representa al usuario que lo creó. |
| deviceCode | DeviceCode | Private | Código estable y único dentro de la organización. |
| name | string | Private | Nombre visible del equipo; obligatorio, de 1 a 120 caracteres. |
| description | string? | Private | Descripción administrativa opcional, hasta 500 caracteres. |
| specifications | DeviceSpecifications | Private | Fabricante, modelo y número de serie, cuando se conocen. |
| assignment | DeviceAssignment | Private | Edificación obligatoria y zona opcional donde está instalado. |
| externalReference | ExternalDeviceReference? | Private | Correspondencia opcional con un equipo de un sistema externo. |
| administrativeStatus | DeviceAdministrativeStatus | Private | Estado administrativo del registro. |
| capabilities | List\<DeviceCapability\> | Private | Capacidades de medición y actuación que pertenecen al agregado. |
| createdAt | DateTimeOffset | Private | Fecha y hora UTC del registro. |
| updatedAt | DateTimeOffset | Private | Fecha y hora UTC de la última modificación. |
| version | long | Private | Versión para controlar modificaciones concurrentes y ordenar eventos. |

| Método | Tipo de retorno | Descripción |
|---|---|---|
| Register(...) | Device | Crea el agregado en estado `INACTIVE` con al menos una capacidad válida. |
| UpdateDetails(name, description, specifications) | void | Modifica datos descriptivos sin alterar la identidad del equipo. |
| ReplaceCapabilities(capabilityDefinitions) | void | Sustituye las capacidades de un dispositivo inactivo; conserva el ID de las capacidades cuyo código no cambia. |
| AssignTo(assignment) | void | Cambia la edificación o zona de un dispositivo inactivo, previa validación externa de la ubicación. |
| ChangeAdministrativeStatus(status) | void | Aplica una transición válida del ciclo de vida administrativo. |

**Entities**

`DeviceCapability`

**Descripción:** Capacidad individual de un dispositivo. Tiene identidad propia dentro del agregado y solo se modifica a través de `Device`; no tiene repositorio ni controlador independiente.

| Atributo | Tipo de dato | Visibilidad | Descripción |
|---|---|---|---|
| id | Guid | Private | Identificador de la capacidad. |
| code | string | Private | Código estable, de 1 a 80 caracteres, único dentro del dispositivo; por ejemplo, `ambient_temperature` o `close_valve`. |
| kind | CapabilityKind | Private | `MEASUREMENT` o `ACTUATION`. |
| unit | string? | Private | Unidad de una medición, hasta 30 caracteres; no aplica a capacidades de actuación. |

Las capacidades describen lo que el equipo puede hacer. No contienen valores medidos, reglas, parámetros de ejecución, resultados de acciones ni datos de conexión. Los ejemplos de códigos son ilustrativos; no constituyen un catálogo de hardware ya seleccionado.

**Value Objects**

| Value Object (`record`) | Atributos | Validación y significado |
|---|---|---|
| DeviceCode | value: string | Entre 1 y 64 caracteres; espacios exteriores eliminados y conversión a mayúsculas. Se propone admitir letras ASCII, números, guion y guion bajo. |
| DeviceSpecifications | manufacturer: string?, model: string?, serialNumber: string? | Metadatos opcionales de hasta 100 caracteres cada uno. El número de serie no sustituye al identificador interno ni se presume único entre fabricantes. |
| DeviceAssignment | buildingId: Guid, zoneId: Guid? | Siempre exige una edificación. Si existe zona, esta debe pertenecer a esa edificación y a la misma organización. La comprobación de existencia se coordina desde Application Layer. |
| ExternalDeviceReference | sourceSystem: string, externalDeviceId: string | Ambos valores son obligatorios si se proporciona la referencia, de hasta 80 y 120 caracteres. Identifican al equipo en una instancia de integración dentro de la organización. |
| CapabilityDefinition | code: string, kind: CapabilityKind, unit: string? | Entrada inmutable para crear o reemplazar capacidades; aplica las mismas reglas que `DeviceCapability`, sin aceptar su ID desde el cliente. |

`sourceSystem` identifica una **instancia** de integración, por ejemplo `bms-campus-norte`, y no solo el nombre del fabricante. Se normaliza a minúsculas y admite letras ASCII, números, guion y guion bajo; `externalDeviceId` conserva mayúsculas y minúsculas y se compara exactamente tras quitar espacios exteriores. La referencia externa y `deviceCode` son inmutables en esta propuesta; sustituir físicamente el equipo requiere registrar otro `Device` y retirar el anterior.

**Enumerations**

| Enumeración | Valores | Significado |
|---|---|---|
| DeviceAdministrativeStatus | INACTIVE, ACTIVE, RETIRED | Registrado y deshabilitado administrativamente; habilitado administrativamente; retirado de manera definitiva. |
| CapabilityKind | MEASUREMENT, ACTUATION | Capacidad para producir una medición o para recibir una acción. |

El ciclo administrativo propuesto admite INACTIVE → ACTIVE, ACTIVE → INACTIVE e INACTIVE → RETIRED. RETIRED es terminal; retirar un equipo activo exige desactivarlo primero. Estos estados no equivalen a conectado/desconectado ni al resultado de una prueba de integración. Las modificaciones de ubicación o capacidades solo se permiten en INACTIVE; un equipo retirado permanece consultable y no editable.

**Commands**

Los comandos representan intenciones de modificación. `organizationId` se obtiene del contexto autorizado del solicitante. `expectedVersion` se obtiene de `If-Match` para impedir que una edición sobrescriba cambios más recientes.

| Command (`record`) | Datos |
|---|---|
| RegisterDeviceCommand | organizationId, deviceCode, name, description?, specifications, assignment, externalReference?, capabilities: List\<CapabilityDefinition\> |
| UpdateDeviceDetailsCommand | organizationId, deviceId, name, description?, specifications, expectedVersion |
| ReplaceDeviceCapabilitiesCommand | organizationId, deviceId, capabilities: List\<CapabilityDefinition\>, expectedVersion |
| AssignDeviceToLocationCommand | organizationId, deviceId, buildingId, zoneId?, expectedVersion |
| ChangeDeviceAdministrativeStatusCommand | organizationId, deviceId, administrativeStatus, expectedVersion |

**Queries**

| Query (`record`) | Datos | Resultado |
|---|---|---|
| GetDeviceByIdQuery | organizationId, deviceId | Device? |
| GetDevicesQuery | organizationId, buildingId?, zoneId?, administrativeStatus?, page, size | PagedResult\<Device\> |
| GetDeviceByExternalReferenceQuery | organizationId, sourceSystem, externalDeviceId | Device? |

**Services**

| Interfaz | Métodos | Tipo de retorno |
|---|---|---|
| IDeviceCommandService | Handle(RegisterDeviceCommand) | Device |
| IDeviceCommandService | Handle(UpdateDeviceDetailsCommand) | Device |
| IDeviceCommandService | Handle(ReplaceDeviceCapabilitiesCommand) | Device |
| IDeviceCommandService | Handle(AssignDeviceToLocationCommand) | Device |
| IDeviceCommandService | Handle(ChangeDeviceAdministrativeStatusCommand) | Device |
| IDeviceQueryService | Handle(GetDeviceByIdQuery) | Device? |
| IDeviceQueryService | Handle(GetDevicesQuery) | PagedResult\<Device\> |
| IDeviceQueryService | Handle(GetDeviceByExternalReferenceQuery) | Device? |

`IDeviceRepository` es el puerto de persistencia del agregado, declarado en el dominio. Su implementación se describe en Infrastructure Layer. Los servicios anteriores son contratos; `DeviceCommandServiceImpl` y `DeviceQueryServiceImpl` son sus implementaciones de aplicación. La separación de comandos y consultas no exige bases de datos diferentes.

Los contratos auxiliares `DeviceReadScope` y `DeviceFilters` contienen identificadores de ubicaciones autorizadas y filtros de consulta, respectivamente; no dependen de clases de IAM, del framework web ni de la infraestructura. `PagedResult<T>` contiene `Items`, `Page`, `Size`, `TotalElements` y `TotalPages`. Las propiedades públicas de records en C# siguen PascalCase; los nombres camelCase de las tablas de entrada y salida corresponden a su representación JSON. Los identificadores obligatorios rechazan `Guid.Empty`.

**Domain Events**

| Evento | Se produce cuando |
|---|---|
| DeviceRegistered | Se registra un dispositivo. |
| DeviceDetailsUpdated | Cambian sus datos descriptivos. |
| DeviceCapabilitiesReplaced | Cambia su conjunto de capacidades. |
| DeviceAssignedToLocation | Cambia su asignación física. |
| DeviceAdministrativeStatusChanged | Se aplica una transición administrativa. |

Los eventos se producen únicamente ante cambios efectivos. La aplicación los convierte en mensajes de integración con `eventId`, `eventType`, `schemaVersion`, `organizationId`, `deviceId`, `aggregateVersion`, `occurredAt` y una instantánea del catálogo del dispositivo. El evento de asignación incluye también la asignación anterior. La instantánea contiene metadatos, capacidades, estado y asignación; no contiene mediciones ni credenciales. Permite que Monitoring y Alert & Response Management actualicen su referencia del equipo sin acceder a las tablas de Devices.

#### 4.2.4.2. Interface Layer

**REST Controllers**

`DevicesController`

**Descripción:** Recibe solicitudes autenticadas, valida su forma, construye comandos o consultas y transforma los resultados en recursos REST. Las reglas del agregado permanecen en Domain Layer y la coordinación de permisos, ubicación y persistencia se ejecuta en Application Layer.

| Método | Ruta | Descripción | Respuesta exitosa |
|---|---|---|---|
| RegisterDevice() | POST /api/v1/devices | Registra el equipo con sus capacidades y ubicación inicial. | 201, DeviceResource, Location y ETag |
| GetDevices() | GET /api/v1/devices | Lista los dispositivos visibles para el solicitante; admite buildingId, zoneId, administrativeStatus, page y size. | 200, DevicePageResource |
| GetDeviceById() | GET /api/v1/devices/{deviceId} | Consulta un dispositivo de la organización autorizada. | 200, DeviceResource y ETag |
| GetDeviceByExternalReference() | GET /api/v1/devices/by-external-reference?sourceSystem=...&externalDeviceId=... | Resuelve un identificador de una integración. | 200, DeviceResource y ETag |
| UpdateDeviceDetails() | PUT /api/v1/devices/{deviceId}/details | Sustituye sus datos descriptivos. | 200, DeviceResource y ETag |
| ReplaceDeviceCapabilities() | PUT /api/v1/devices/{deviceId}/capabilities | Sustituye el conjunto de capacidades de un equipo inactivo. | 200, DeviceResource y ETag |
| AssignDeviceToLocation() | PUT /api/v1/devices/{deviceId}/assignment | Asigna o reasigna un equipo inactivo a una edificación y, opcionalmente, una zona. | 200, DeviceResource y ETag |
| ChangeDeviceAdministrativeStatus() | PUT /api/v1/devices/{deviceId}/administrative-status | Habilita, deshabilita o retira administrativamente el equipo. | 200, DeviceResource y ETag |

Las modificaciones con `PUT` requieren `If-Match` con el ETag obtenido al consultar el recurso, derivado de `version`. Se propone paginación desde cero, tamaño predeterminado 20, máximo 100 y orden estable por `createdAt` e `id`. Las consultas sin filtros tampoco devuelven dispositivos fuera del ámbito autorizado. Los dispositivos retirados siguen siendo consultables; el filtro administrativo permite excluirlos. No se expone eliminación física.

**Resources**

| Resource (`record`) | Contenido |
|---|---|
| RegisterDeviceResource | deviceCode, name, description?, specifications, assignment, externalReference?, capabilities |
| UpdateDeviceDetailsResource | name, description?, specifications |
| ReplaceDeviceCapabilitiesResource | capabilities: List\<CapabilityDefinitionResource\> |
| AssignDeviceToLocationResource | buildingId, zoneId? |
| ChangeDeviceAdministrativeStatusResource | administrativeStatus |
| DeviceSpecificationsResource | manufacturer?, model?, serialNumber? |
| DeviceAssignmentResource | buildingId, zoneId? |
| ExternalDeviceReferenceResource | sourceSystem, externalDeviceId |
| CapabilityDefinitionResource | code, kind, unit? |
| DeviceCapabilityResource | id, code, kind, unit? |
| DeviceResource | id, organizationId, deviceCode, name, description?, specifications, assignment, externalReference?, administrativeStatus, capabilities, createdAt, updatedAt, version |
| DevicePageResource | items: List\<DeviceResource\>, page, size, totalElements, totalPages |
| ErrorResource | code, message, fieldErrors?, traceId |

Los recursos de entrada no aceptan `organizationId`, IDs internos de capacidades, fechas ni versión como campos editables. La organización activa se obtiene de un contexto de acceso validado; en usuarios con varias organizaciones, IAM verifica la selección. No se exponen credenciales de equipos o integraciones.

**Assemblers**

| Assembler | Responsabilidad |
|---|---|
| RegisterDeviceCommandFromResourceAssembler | Construye RegisterDeviceCommand con el recurso y la organización autorizada. |
| UpdateDeviceDetailsCommandFromResourceAssembler | Construye UpdateDeviceDetailsCommand con el recurso, deviceId, organización y versión esperada. |
| ReplaceDeviceCapabilitiesCommandFromResourceAssembler | Construye ReplaceDeviceCapabilitiesCommand. |
| AssignDeviceToLocationCommandFromResourceAssembler | Construye AssignDeviceToLocationCommand. |
| ChangeDeviceAdministrativeStatusCommandFromResourceAssembler | Construye ChangeDeviceAdministrativeStatusCommand. |
| DeviceQueriesFromRequestAssembler | Convierte parámetros de ruta y consulta en las tres consultas del dominio. |
| DeviceResourceFromEntityAssembler | Convierte Device y sus objetos anidados en DeviceResource. |
| DevicePageResourceFromPageAssembler | Convierte una página de agregados en DevicePageResource. |

**Contrato de errores**

| Código HTTP | Situación |
|---|---|
| 400 | Campos, tipos, enumeraciones, capacidades o parámetros de paginación inválidos; falta una parte de la referencia externa. |
| 401 | Identidad ausente o inválida. |
| 403 | Solicitante autenticado sin permiso para la operación o la ubicación seleccionada. |
| 404 | Dispositivo no encontrado dentro del ámbito visible, o ubicación inexistente dentro del ámbito autorizado. |
| 409 | Código o referencia externa duplicados; transición prohibida; edición de un equipo retirado o cambio de ubicación/capacidades de un equipo activo; zona incompatible con la edificación. |
| 412 | If-Match no coincide con la versión vigente. |
| 428 | Falta If-Match en una modificación que lo requiere. |
| 503 | No puede completarse una validación obligatoria contra IAM o Buildings; no se registra el cambio. |

Las lecturas de IDs ajenos al ámbito visible responden 404 sin revelar metadatos de otras organizaciones. Los errores de infraestructura no se convierten en permisos concedidos ni en ubicaciones válidas.

**Fachada de integración**

`DevicesContextFacade` expone `GetDeviceCatalogEntry(organizationId, deviceId)` para consultas entre contextos autorizados. Devuelve `DeviceCatalogEntry` con identidad, ubicación, capacidades, estado y versión, sin entidades persistentes ni tablas compartidas. Utiliza `IDeviceQueryService`; las identidades de servicio también tienen permisos limitados. Esta fachada permite consultar el catálogo inicial o recuperar información, mientras los eventos comunican cambios posteriores.

#### 4.2.4.3. Application Layer

`DeviceCommandServiceImpl`

**Descripción:** Implementa IDeviceCommandService y coordina los casos de uso. Comprueba autorización y alcance, consulta Buildings cuando corresponde, carga el agregado, invoca sus métodos y guarda el resultado junto con los mensajes pendientes de integración en una misma transacción local.

| Método | Descripción |
|---|---|
| Handle(RegisterDeviceCommand) | Valida permiso sobre la edificación y zona, comprueba duplicados, verifica la ubicación, crea Device inactivo y persiste DeviceRegistered. |
| Handle(UpdateDeviceDetailsCommand) | Carga el dispositivo dentro del ámbito autorizado, verifica la versión y modifica sus datos descriptivos. |
| Handle(ReplaceDeviceCapabilitiesCommand) | Comprueba versión y estado inactivo; valida la colección completa, conserva IDs para códigos existentes y reemplaza las capacidades mediante el agregado. |
| Handle(AssignDeviceToLocationCommand) | Exige permisos tanto sobre la ubicación actual como sobre la de destino; valida la nueva relación organización–edificación–zona y cambia la asignación del equipo inactivo. |
| Handle(ChangeDeviceAdministrativeStatusCommand) | Comprueba versión y transición. Al activar, revalida la ubicación; al desactivar o retirar, conserva identidad y referencias históricas. |

La comprobación previa de duplicados mejora el mensaje al usuario, pero las restricciones únicas de la base de datos resuelven también los registros simultáneos. Una escritura usa comparación de versión; si otro proceso modificó el agregado, se revierte toda la transacción y se responde 412. La versión inicial es 1 y aumenta una vez por cambio efectivo. El estado guardado y la instantánea del evento corresponden a la misma versión.

`DeviceQueryServiceImpl`

**Descripción:** Implementa IDeviceQueryService sin modificar el agregado.

| Método | Descripción |
|---|---|
| Handle(GetDeviceByIdQuery) | Recupera un equipo filtrando por organización y alcance de acceso del solicitante. |
| Handle(GetDevicesQuery) | Aplica los filtros solicitados y el alcance autorizado antes de paginar y contar los resultados. |
| Handle(GetDeviceByExternalReferenceQuery) | Resuelve una referencia externa únicamente dentro de la organización y ubicaciones visibles. |

**Puertos de aplicación e integración**

| Puerto | Métodos principales | Responsabilidad |
|---|---|---|
| IBuildingContextGateway | ValidateAssignment(organizationId, buildingId, zoneId?): ValidatedAssignment | Consulta el contrato de Buildings y comprueba existencia, pertenencia y disponibilidad administrativa para la asignación. |
| IDeviceAccessGateway | RequirePermission(action, organizationId, buildingId, zoneId?); GetReadScope(organizationId): DeviceReadScope | Obtiene de IAM el permiso de operación y las restricciones de visibilidad del solicitante. |
| IOutboxRepository | Append(message); FindPending(batchSize); MarkPublished(eventId); RecordFailure(eventId, nextAttemptAt) | Almacena y gestiona mensajes de integración pendientes. |
| IIntegrationEventPublisher | Publish(message) | Entrega un mensaje al transporte de integración elegido. |

`ValidatedAssignment` es una respuesta local del adaptador, no la entidad `Building`. `DeviceReadScope` representa las ubicaciones visibles para una identidad autenticada y se aplica también a los totales de paginación. Los puertos ocultan si la comunicación entre contextos ocurre en el mismo proceso o mediante API.

`DeviceIntegrationEventMapper` convierte los eventos del dominio en mensajes con la instantánea del catálogo. `DeviceOutboxDispatcher` obtiene mensajes pendientes, los publica y registra el resultado. La publicación puede repetirse si el proceso falla entre enviar y marcar; los consumidores deduplican por `eventId` y solo aplican instantáneas con `aggregateVersion` mayor que la conocida. La transmisión es al menos una vez; no se presupone entrega exactamente una vez ni orden global.

**Coordinación con Building Management, Conectividad y el Edge**

Buildings conserva identificadores estables y utiliza desactivación reversible, según 4.2.3; esta entrega no implementa retiro definitivo ni eliminación física de ubicaciones. Device valida la disponibilidad al registrar, reasignar o activar. La validación previa no constituye una transacción distribuida: si asignación y desactivación concurren, se requiere revalidación o reconciliación entre contextos. No se presupone que la validación reserve la ubicación.

Para US23, AC2 y US33, AC1–AC2, Device proporciona una asignación validada y versionada. Monitoring conserva la ubicación correspondiente al momento de cada medición, sin recalcular el historial con la ubicación actual. Si el equipo no tiene zona confirmada, los consumidores lo muestran como no localizado a nivel de zona; no infieren una zona a partir de su nombre o edificio. Una reasignación conserva el origen histórico y se aplica a las nuevas mediciones una vez incorporada la nueva versión del catálogo. El contrato temporal para eventos retrasados o sincronizados debe acordarse con Monitoring y Conectividad antes de implementar el flujo completo.

Conectividad reconoce la fuente y comprueba los datos antes de habilitar su integración operativa (US31–US32). Device conserva `sourceSystem` y `externalDeviceId` para mapear esa identidad a un equipo y ubicación (US33). La habilitación de una integración depende tanto de la prueba satisfactoria como de un contexto válido; `DeviceAdministrativeStatus.ACTIVE` no sustituye la prueba. La definición de ese intercambio pertenece al Domain Message Flow entre los contextos y debe coordinarse con sus responsables.

Un cambio administrativo es un cambio del catálogo; **no confirma que el equipo físico haya ejecutado una orden ni que el Edge haya recibido la actualización**. Risk Detection evalúa condiciones, Alert & Response Management coordina respuestas, Conectividad participa en transporte y recuperación de eventos, y Monitoring conserva mediciones y disponibilidad. La ejecución local en Edge permite atender US28–US29 con esos colaboradores. La outbox del catálogo de Device no sustituye el almacenamiento local de eventos durante una interrupción de Internet.

#### 4.2.4.4. Infrastructure Layer

**Persistencia del agregado**

`IDeviceRepository` / `RelationalDeviceRepository`

**Descripción:** IDeviceRepository define el contrato del dominio y RelationalDeviceRepository lo implementa mediante el mecanismo de persistencia relacional elegido. La infraestructura mapea los value objects a columnas, carga las capacidades y aplica transacciones, restricciones de unicidad y control de versión.

| Método del puerto | Tipo de retorno | Descripción |
|---|---|---|
| FindByIdAndOrganizationId(deviceId, organizationId) | Device? | Carga un agregado dentro de una organización; la aplicación verifica además el alcance sobre su ubicación. |
| FindByExternalReference(organizationId, sourceSystem, externalDeviceId) | Device? | Busca por referencia externa y organización. |
| FindPage(organizationId, filters, readScope, page, size) | PagedResult\<Device\> | Filtra por organización, ubicación, estado y alcance de acceso antes de paginar. |
| ExistsByOrganizationIdAndDeviceCode(organizationId, deviceCode) | bool | Detecta un código administrativo ya registrado. |
| ExistsByExternalReference(organizationId, sourceSystem, externalDeviceId) | bool | Detecta una referencia externa ya registrada. |
| Save(device, expectedVersion?) | Device | Inserta un nuevo agregado o actualiza uno existente comparando su versión; guarda sus capacidades en la misma transacción. |

El repositorio no publica un método de eliminación física del agregado. Las capacidades no tienen repositorio público: se insertan, conservan o eliminan como parte de la actualización de Device. La eliminación de una capacidad del catálogo actual no borra los datos históricos que otros contextos ya registraron con su identidad y significado.

**Adaptadores**

| Componente | Puerto implementado | Descripción |
|---|---|---|
| BuildingContextAdapter | IBuildingContextGateway | Consume la fachada o API de Buildings y traduce su respuesta a ValidatedAssignment. |
| IamDeviceAccessAdapter | IDeviceAccessGateway | Adapta el contexto de identidad y las decisiones de autorización de IAM. |
| RelationalOutboxRepository | IOutboxRepository | Persiste mensajes pendientes en la misma base de datos y transacción del agregado. |
| IntegrationEventPublisherAdapter | IIntegrationEventPublisher | Publica mensajes mediante el transporte configurado. El diseño no presupone un producto de mensajería. |
| DevicePersistenceMapper | No aplica | Convierte Device, DeviceCapability y sus value objects hacia y desde los registros relacionales. |


#### 4.2.4.5. Bounded Context Software Architecture Component Level Diagrams

![Diagrama de componentes de Devices](../assets\images\chapter-04-solution-software-design\DevicesComponents-dark.png)

#### 4.2.4.6. Bounded Context Software Architecture Code Level Diagrams

##### 4.2.4.6.1. Bounded Context Domain Layer Class Diagrams

![Diagrama UML del agregado Device](../assets/images/chapter-04-solution-software-design/devices-domain-model.png)


![Diagrama UML de contratos de Devices](../assets/images/chapter-04-solution-software-design/devices-domain-contracts.png)

##### 4.2.4.6.2. Bounded Context Database Design Diagram

![Diagrama relacional de Devices](../assets/images/chapter-04-solution-software-design/devices-database.png)


