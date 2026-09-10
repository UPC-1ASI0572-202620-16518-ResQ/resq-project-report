# Capítulo II: Requirements Elicitation & Analysis

> Imágenes del capítulo:
> `assets/images/chapter-02-requirements-elicitation-analysis/`
>
> Fuentes editables de diagramas:
> `assets/diagram-sources/chapter-02-requirements-elicitation-analysis/`

## 2.1. Competidores

### 2.1.1. Análisis competitivo
[COMPLETAR]

### 2.1.2. Estrategias y tácticas frente a competidores
[COMPLETAR]

## 2.2. Entrevistas

### 2.2.1. Diseño de entrevistas
[COMPLETAR]

### 2.2.2. Registro de entrevistas
[COMPLETAR]

### 2.2.3. Análisis de entrevistas
[COMPLETAR]

## 2.3. Needfinding

### 2.3.1. User Personas

Los User Personas representan los dos segmentos objetivo de ResQ: propietarios y administradores de edificaciones, y empresas e instituciones con infraestructura propia. Permiten relacionar las responsabilidades de quienes supervisan la seguridad con sus objetivos, dificultades y condiciones de uso de una solución IoT.

**Segmento objetivo #1: Propietarios y administradores de edificaciones — Carlos Mendoza**

Carlos Mendoza, de 37 años, representa al administrador de un edificio residencial que coordina seguridad y mantenimiento tanto desde la oficina como fuera de la instalación. Es organizado y preventivo, pero depende de llamadas, mensajes y sistemas separados para comprender una alerta. Su necesidad principal consiste en conocer el tipo de riesgo, su ubicación y evolución, y quién está atendiendo el evento. Para ResQ, este perfil orienta el monitoreo remoto por zonas, las alertas comprensibles y la consulta de las respuestas ejecutadas por el sistema.

IMAGEN

**Segmento objetivo #2: Empresas e instituciones con infraestructura propia — Daniela Rojas**

Daniela Rojas, de 34 años, representa a los responsables de seguridad institucional que coordinan varios edificios y equipos de trabajo. Como jefa de Seguridad y Prevención de una universidad, necesita identificar el ambiente afectado y compartir información precisa con seguridad, mantenimiento y brigadistas. Su principal dificultad es reconstruir la situación a partir de fuentes distribuidas mientras protege a una población numerosa. Este perfil orienta a ResQ hacia la supervisión por zonas, la trazabilidad de eventos y la comunicación diferenciada según las responsabilidades de cada usuario.

IMAGEN

### 2.3.2. User Task Matrix

La User Task Matrix organiza las principales tareas de cada User Persona según su frecuencia y severidad. La frecuencia indica qué tan seguido se realiza una actividad, mientras que la severidad representa el impacto que tendría no ejecutarla correctamente. Ambas dimensiones se clasifican como alta, media o baja.

**Segmento objetivo #1: Carlos Mendoza — Propietarios y administradores de edificaciones**

| Tarea | Frecuencia | Severidad |
|---|---|---|
| Revisar novedades y condiciones de seguridad del edificio | Alta | Alta |
| Identificar el tipo de alerta, su ubicación y gravedad | Media | Alta |
| Coordinar la verificación y respuesta con vigilancia y mantenimiento | Media | Alta |
| Dar seguimiento a incidentes cuando se encuentra fuera del edificio | Media | Alta |
| Verificar el funcionamiento de los equipos de seguridad | Alta | Alta |
| Coordinar el mantenimiento preventivo de los equipos | Media | Alta |
| Registrar los incidentes y las acciones ejecutadas | Media | Alta |
| Consultar antecedentes de incidentes por fecha, tipo o zona | Media | Media |
| Evaluar nuevas alternativas de seguridad y presentarlas a la junta | Baja | Media |

**Segmento objetivo #2: Daniela Rojas — Empresas e instituciones con infraestructura propia**

| Tarea | Frecuencia | Severidad |
|---|---|---|
| Revisar reportes e incidentes del campus | Alta | Alta |
| Localizar el ambiente afectado y comprender el tipo de riesgo | Media | Alta |
| Coordinar a seguridad, mantenimiento y brigadas según el protocolo | Media | Alta |
| Evaluar el alcance del incidente y la necesidad de evacuación | Media | Alta |
| Supervisar la evolución del incidente hasta su control | Media | Alta |
| Coordinar inspecciones de las zonas e instalaciones | Alta | Alta |
| Coordinar mantenimientos y simulacros | Media | Alta |
| Analizar incidentes y tiempos de atención | Media | Media |
| Evaluar soluciones con infraestructura, TI y compras | Baja | Media |

La comparación muestra que ambos perfiles asignan una severidad alta a la identificación del riesgo, la coordinación de la respuesta y la verificación de los sistemas de seguridad. Carlos requiere supervisar un edificio incluso cuando se encuentra fuera de él, mientras que Daniela debe coordinar distintas áreas y zonas dentro de una infraestructura extensa. Las tareas de evaluación tecnológica tienen una frecuencia baja porque se realizan de manera ocasional, aunque apoyan la mejora continua de la seguridad.

### 2.3.3. User Journey Mapping

Los User Journey Maps describen la experiencia actual planteada en los guiones, desde la recepción de una alerta hasta el registro posterior. Se utiliza un recorrido **As-Is** para distinguir las acciones y canales actuales de las oportunidades propuestas para ResQ. Las emociones son interpretaciones cualitativas del escenario; no representan resultados de una evaluación de satisfacción ni mejoras ya comprobadas.

**Segmento objetivo #1: Carlos Mendoza — Atención de una alerta de humo en el sótano**

El recorrido presenta a Carlos fuera del edificio cuando recibe una llamada por una alerta de humo. Su objetivo es comprender la ubicación y gravedad del problema, coordinar con el personal y seguir la atención. El punto de mayor incertidumbre aparece mientras vigilancia revisa el sótano y las cámaras sin una vista unificada. Este escenario procede del guion 1 y permite explorar cómo ResQ podría disminuir la fragmentación de información durante la respuesta.

IMAGEN

**Segmento objetivo #2: Daniela Rojas — Atención de una alerta en un laboratorio universitario**

El recorrido de Daniela aborda una alerta de humo asociada con el sobrecalentamiento de un equipo de laboratorio. Su objetivo es identificar el ambiente afectado, coordinar a seguridad y mantenimiento, y dar seguimiento a la respuesta sin generar confusión entre los ocupantes. La dificultad principal consiste en ubicar el laboratorio exacto y reunir información de varias áreas. El escenario del guion 4 orienta las oportunidades de ResQ hacia una localización precisa y un registro compartido de la evolución del evento.

IMAGEN

Los dos recorridos sitúan la mayor incertidumbre entre el aviso inicial y la comprensión del evento. ResQ debería facilitar la identificación de la zona y mostrar las mediciones y respuestas automáticas pertinentes. La continuidad local propuesta en el capítulo I debe distinguirse de la disponibilidad del acceso remoto: si se pierde conectividad, la interfaz no debería presentar datos antiguos como actuales. Las decisiones de coordinación y evacuación permanecen sujetas a los protocolos y responsabilidades de cada instalación.

### 2.3.4. Empathy Mapping

Los mapas de empatía complementan los perfiles y recorridos al relacionar lo que cada responsable necesita hacer con lo que ve, escucha, dice, piensa y siente. Su contenido sintetiza los guiones y explicita interpretaciones de diseño; no representa observaciones de campo realizadas por el equipo. Los bloques de dificultades y beneficios esperados permiten traducir esas perspectivas en necesidades que deberán validarse.

**Segmento objetivo #1: Carlos Mendoza — Propietarios y administradores de edificaciones**

El mapa de Carlos refleja la tensión entre su intención de prevenir incidentes y la dependencia de otras personas para reunir información durante una alerta. Aunque dispone de cámaras y alarmas, necesita comprender lo que ocurre cuando no está presente. La oportunidad para ResQ consiste en ofrecer información contextualizada y trazable que le permita coordinar con mayor claridad y conocer qué respuesta ha ejecutado el sistema.

IMAGEN

**Segmento objetivo #2: Daniela Rojas — Empresas e instituciones con infraestructura propia**

El mapa de Daniela muestra que la confianza en una respuesta depende de que los distintos equipos comprendan el mismo evento y sus responsabilidades. La dispersión de información aumenta la presión al coordinar una instalación concurrida. Para ResQ, este perfil plantea la necesidad de localizar el riesgo con precisión, facilitar el seguimiento y comunicar la información adecuada a cada rol, sin asumir que una alarma por sí sola resuelve la coordinación.

IMAGEN


Ambos mapas sugieren que centralizar información aporta valor cuando ayuda a comprender el riesgo y la respuesta. Carlos necesita mantener visibilidad a distancia; Daniela necesita coordinar áreas y zonas distintas. En ambos casos, la confianza en la automatización requiere conocer qué ocurrió y por qué se ejecutó una acción. Las alertas para ocupantes también deben ser comprensibles y considerar a quienes requieren asistencia, sin limitar la comunicación a una sola señal sonora.

## 2.4. Big Picture EventStorming
[INSERTAR DIAGRAMA + EXPLICACIÓN]

## 2.5. Ubiquitous Language

| Término | Definición |
|---|---|
| [Term in English] | [Definición] |
