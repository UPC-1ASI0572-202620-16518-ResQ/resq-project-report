# Capítulo I: Introducción

> Imágenes del capítulo:
> `assets/images/chapter-01-introduction/`

## 1.1. Startup Profile

### 1.1.1. Descripción de la Startup
[COMPLETAR]

### 1.1.2. Perfiles de integrantes del equipo
[COMPLETAR]

## 1.2. Solution Profile

### 1.2.1. Antecedentes y problemática
[COMPLETAR]

### 1.2.2. Lean UX Process

#### 1.2.2.1. Lean UX Problem Statements
El estado actual de la seguridad y gestión de emergencias en edificios se ha enfocado principalmente en el uso de sistemas independientes y de propósito único; como detectores de humo, alarmas de gas o protocolos de evacuación manuales. Estos mecanismos son utilizados por administradores y responsables de seguridad de los edificios para identificar situaciones de riesgo; sin embargo, en muchos casos requieren de la intervención humana para coordinar una respuesta adecuada y reducir los posibles daños sobre las personas y la infraestructura.

Lo que las soluciones existentes no suelen resolver de manera integrada es la coordinación de la información entre la detección de una emergencia y la ejecución de una respuesta física ante ella. Esto dificulta centralizar la información obtenida, emitir alertas precisas, identificar el tipo de emergencia, ubicar la zona afectada y activar respuestas diferenciadas de acuerdo con las caracterísiticas y el nivel de gravedad del evento. Asimismo, muchos sistemas dependen de mecanismos de monitoreo o comunicación centralizados, lo que puede limitar su capacidad de respuesta cuando se pierde temporalmente la conectividad a Internet durante una emergencia.

Nuestra solución abordará esta brecha mediante una plataforma IoT capaz de monitorear variables ambientales y fisicas del edificio, procesar localmente la información obtenida de los sensores mediante Edge Computing, clasificar el tipo y grado de la emergencia y ejecutar acciones automáticas a través de actuadores (alarmas, luces de evacuación, ventilación, cierre de válvula) mientras reporta el evento y el estado del edificio en tiempo real.

Nuestro enfoque inicial estará dirigido a los administradores y responsables de la seguridad de edificios que requieren supervisar las condiciones de la infraestructura para responder oportunamente ante situaciones de riesgo, contribuyendo a la seguridad de los ocupantes.

Sabremos que hemos tenido éxito cuando los administradores y responsables de seguridad utilicen la aplicación para monitorear el estado del edificio, identificar alertas por zona en tiempo real, y verifiquen la activación automática de respuestas adecuadas de los actuadores en cuestión de segundos tras superar el umbral de riesgo. Asimismo, consideraremos que los ocupantes puedan reconocer fácilmente las alertas y comprendan las indicaciones de evacuación asociadas al tipo de emergencia.

#### 1.2.2.2. Lean UX Assumptions

**Business Assumptions:**

1. Creemos que existe una demanda insatisfecha en el mercado de administración de edificios por soluciones que centralicen monitoreo y respuesta ante emergencias, actualmente cubierta solo parcialmente por sistemas aislados.
2. Creemos que existe una oportunidad para integrar en una única solución IoT la detección, clasificación, localización y respuesta automática ante situaciones de riesgo dentro de edificios.
3. Creemos que las organizaciones responsables de la administración de edificios estarán dispuestas a adoptar una solución que complemente sus mecanismos actuales de seguridad mediante monitoreo y automatización.
4. Creemos que la capacidad de ejecutar respuestas críticas localmente, sin depender permanentemente de la conectividad a Internet, constituirá un elemento diferenciador de la propuesta frente a sistemas que requieren comunicación constante con servicios externos.
5. Creemos que un modelo de servicio orientado a edificios permitirá escalar progresivamente la solución mediante la incorporación de nuevos sensores, actuadores, zonas y dispositivos IoT según las necesidades de cada organización.
6. Creemos que las organizaciones estarán dispuestas a asumir un costo por una solución que contribuya al monitoreo continuo, la trazabilidad de eventos y la automatización de determinadas respuestas de seguridad.

**Business Outcome Assumptions:**

1. Creemos que demostrar una solución integrada de monitoreo y respuesta ante emergencias incrementará el interés de potenciales clientes en adoptar la plataforma frente al uso exclusivo de mecanismos independientes o manuales.
2. Creemos que al garantizar que las respuestas automáticas y del monitoreo sean las adecuadas, estas incrementarán la confiabilidad y por consecuencia; la intención de permanencia y renovación de nuestro servicio por parte de las organizaciones, reduciendo potencialmente la tasa de cancelación.
3. Creemos que reducir el esfuerzo requerido para supervisar manualmente las condiciones de seguridad del edificio incrementará el valor percibido de la plataforma y la disposición de las organizaciones a pagar por el servicio.
4. Creemos que la disponibilidad de registros históricos sobre eventos detectados, mediciones y respuestas ejecutadas incrementará el uso recurrente de la plataforma para actividades de supervisión y seguimiento.
5. Creemos que la posibilidad de incorporar progresivamente nuevas zonas, sensores y actuadores permitirá incrementar el alcance del servicio, expandiendo nuestra solución a nuevas necesidades.
6. Creemos que una implementación satisfactoria del MVP permitirá validar el interés de potenciales clientes y justificar la evolución de la solución hacia una mayor cantidad de dispositivos, tipos de emergencia y capacidades de respuesta.

**User Assumptions:**
1. Creemos que los administradores y responsables de seguridad de edificios constituyen los principales usuarios encargados de supervisar las condiciones de seguridad y coordinar las acciones frente a situaciones de emergencia.
2. Creemos que los administradores y responsables de seguridad necesitan conocer continuamente el estado general del edificio y de las diferentes zonas bajo su supervisión.
3. Creemos que los administradores y responsables de seguridad requieren identificar rápidamente qué tipo de emergencia está ocurriendo, cuál es su nivel de riesgo y en qué zona se ha producido.
4. Creemos que los responsables de seguridad necesitan conocer qué acciones automáticas fueron ejecutadas por el sistema durante una situación de riesgo para comprender la respuesta aplicada.
5. Creemos que los administradores necesitan consultar posteriormente información sobre los eventos ocurridos para realizar actividades de seguimiento y análisis.
6. Creemos que los administradores y responsables de seguridad cuentan con acceso habitual a dispositivos digitales, como smartphones o computadoras, y están familiarizados con el uso de aplicaciones para tareas de supervisión.
7. Creemos que los ocupantes del edificio necesitan recibir alertas comprensibles que les permitan reconocer rápidamente la existencia de una situación de emergencia.
8. Creemos que los ocupantes estarán dispuestos a seguir señalizaciones e indicaciones automatizadas de seguridad o evacuación cuando estas sean claras, reconocibles y fáciles de comprender.

**User Outcome and Benefit Assumptions:**
1. Creemos que los administradores y responsables de seguridad podrán comprender con mayor rapidez el estado del edificio al contar con la información de los sensores y alertas centralizada en una misma plataforma.
2. Creemos que los responsables de seguridad podrán tomar decisiones con mayor rapidez al conocer el tipo de emergencia, el nivel de riesgo y la zona afectada.
3. Creemos que los administradores tendrán mayor visibilidad sobre la respuesta del sistema al poder verificar qué actuadores fueron activados durante cada evento.
4. Creemos que los responsables de seguridad podrán realizar un mejor seguimiento de las emergencias mediante el acceso al historial de eventos, mediciones y acciones ejecutadas por el sistema.
5. Creemos que los ocupantes podrán reconocer con mayor facilidad una situación de emergencia mediante alertas sonoras y visuales diferenciadas.
6. Creemos que los ocupantes podrán reaccionar de manera más adecuada ante una emergencia al recibir señalización e indicaciones relacionadas con la situación detectada.
7. Creemos que los administradores y responsables de seguridad tendrán mayor confianza en la continuidad de la respuesta del sistema al mantener las acciones críticas de manera local aun cuando se pierda temporalmente la conexión a Internet.

**Feature Assumptions:**

1. Creemos que una funcionalidad de **monitoreo del estado del edificio y sus zonas** permitirá a los administradores y responsables de seguridad conocer las condiciones actuales y detectar rápidamente la existencia de una situación de riesgo.
2. Creemos que una funcionalidad de **detección y clasificación local de emergencias mediante sensores y Edge Computing** permitirá identificar el tipo y nivel de riesgo sin depender permanentemente de servicios externos.
3. Creemos que una funcionalidad de **respuesta automática mediante actuadores** permitirá ejecutar acciones de seguridad apropiadas según el tipo y nivel de riesgo detectado.
4. Creemos que una funcionalidad de **alertas y señalización diferenciadas** permitirá comunicar a administradores, responsables de seguridad y ocupantes, la existencia y naturaleza de una situación de emergencia.
5. Creemos que una funcionalidad de **identificación de la zona afectada** permitirá a los responsables de seguridad localizar con mayor rapidez el origen del evento y orientar adecuadamente la respuesta.
6. Creemos que una funcionalidad de **registro e historial de eventos** permitirá consultar posteriormente las emergencias detectadas, las mediciones registradas y las respuestas ejecutadas por el sistema.

#### 1.2.2.3. Lean UX Hypothesis Statements

1. Creemos que lograremos incrementar el valor percibido de la plataforma y la disposición de las organizaciones a pagar por el servicio si los administradores y responsables de seguridad de edificios logran comprender con mayor rapidez el estado del edificio y de sus diferentes zonascon una funcionalidad de monitoreo del estado del edificio y sus zonas.
2. Creemos que lograremos incrementar la confiabilidad percibida de la plataforma y, como consecuencia, la intención de permanencia y renovación del servicio si los administradores y responsables de seguridad pueden identificar oportunamente el tipo y nivel de riesgo de una emergencia y mantener la capacidad de respuesta aun frente a una pérdida temporal de conectividad a Internet mediante una funcionalidad de detección y clasificación local basada en sensores y Edge Computing.
3. Creemos que lograremos incrementar el valor percibido de la plataforma y la disposición de las organizaciones a adoptar el servicio si los administradores y responsables de seguridad obtienen mayor confianza y visibilidad sobre la respuesta ante una emergencia mediante una funcionalidad que ejecute automáticamente acciones de seguridad apropiadas a través de actuadores según el tipo y nivel de riesgo detectado.
4. Creemos que lograremos incrementar el interés y valor percibido de la plataforma si los administradores y responsables de seguridad pueden reconocer oportunamente la existencia y naturaleza de una emergencia, y los ocupantes pueden identificar con mayor facilidad la situación de riesgo y reaccionar de manera adecuada, mediante una funcionalidad de alertas sonoras y visuales y señalización diferenciada según el evento detectado.
5. Creemos que lograremos incrementar el valor percibido de la plataforma para las actividades de supervisión y respuesta si los administradores y responsables de seguridad pueden tomar decisiones con mayor rapidez al conocer dónde se ha producido una situación de riesgo mediante una funcionalidad de identificación de la zona afectada.
6. Creemos que lograremos incrementar el uso recurrente de la plataforma para actividades de supervisión y seguimiento si los administradores y responsables de seguridad pueden analizar posteriormente las emergencias ocurridas mediante una funcionalidad de registro e historial de los eventos detectados, las mediciones registradas y las respuestas ejecutadas por el sistema.

#### 1.2.2.4. Lean UX Canvas
[INSERTAR ARTEFACTO + EXPLICACIÓN]

## 1.3. Segmentos objetivo
[COMPLETAR]
