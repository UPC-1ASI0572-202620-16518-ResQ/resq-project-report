# Capítulo IV: Solution Software Design

> Imágenes del capítulo:
> `assets/images/chapter-04-solution-software-design/`
>
> Fuentes editables de diagramas:
> `assets/diagram-sources/chapter-04-solution-software-design/`

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

### 4.2.4. Bounded Context: Device Management

#### 4.2.4.1. Domain Layer

**Aggregates**

`Device`

**Descripción:** Raíz del agregado que representa un equipo IoT registrado en una organización. Controla sus características, capacidades y asignación física. Un mismo equipo puede medir varias variables y ejecutar acciones; por ello se utiliza una colección de capacidades en lugar de exigir que sea exclusivamente sensor o actuador.

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

**Coordinación con Building Management y el Edge**

Buildings debe conservar identificadores estables y evitar eliminar físicamente edificaciones o zonas referenciadas. Se propone acordar con ese contexto un bloqueo de nuevas asignaciones antes de su retiro y una comprobación coordinada de los dispositivos asociados. La validación previa de una asignación no constituye una transacción distribuida: si los contextos se despliegan separados, deberán acordar un protocolo de retiro y reconciliación que resuelva modificaciones concurrentes. Este contrato requiere coordinación con el diseño posterior de Buildings.

Un cambio administrativo es un cambio del catálogo; **no confirma que el equipo físico haya ejecutado una orden ni que el Edge haya recibido la actualización**. Las políticas locales de seguridad, confirmaciones y continuidad sin Internet pertenecen a los contextos de monitoreo y respuesta y a su ejecución en Edge. Esa diferencia evita interpretar una respuesta REST exitosa como una actuación física completada.

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

El dispatcher procesa lotes con exclusión entre trabajadores o reclamación de filas, reintenta fallos y registra intentos. Un fallo de publicación posterior al commit mantiene el mensaje pendiente y no deshace el registro ya confirmado al usuario. Las migraciones crean índices y restricciones; se propone MySQL con tablas InnoDB, Guid almacenados como CHAR(36), instantes UTC como DATETIME(6) y payloads como JSON. La aplicación convierte DateTimeOffset a UTC al persistir y recupera el offset cero al leer.

#### 4.2.4.5. Bounded Context Software Architecture Component Level Diagrams

![Diagrama de componentes de Devices](../assets\images\chapter-04-solution-software-design\DevicesComponents-dark.png)
#### 4.2.4.6. Bounded Context Software Architecture Code Level Diagrams

##### 4.2.4.6.1. Bounded Context Domain Layer Class Diagrams

![Diagrama UML del agregado Device](../assets/images/chapter-04-solution-software-design/devices-domain-model.png)


![Diagrama UML de contratos de Devices](../assets/images/chapter-04-solution-software-design/devices-domain-contracts.png)


##### 4.2.4.6.2. Bounded Context Database Design Diagram

![Diagrama relacional de Devices](../assets/images/chapter-04-solution-software-design/devices-database.png)

