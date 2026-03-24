# REPORTE DE RESIDENCIAS PROFESIONALES

---

**TECNOLÓGICO NACIONAL DE MÉXICO**

**Carrera**: Ingeniería en Sistemas Computacionales

**Título del Proyecto**:
Sistema de Gestión Hospitalaria basado en el Estándar HL7 FHIR con Autenticación JWT y Aplicación Móvil Multiplataforma

**Alumno**: Ulises BGZ

**Número de Control**: [Número de Control]

**Empresa / Institución Receptora**: [Nombre de la Institución Receptora]

**Asesor Interno**: [Nombre del Asesor Interno]

**Asesor Externo**: [Nombre del Asesor Externo]

**Periodo**: Marzo 2026 — Agosto 2026

**Lugar y Fecha**: [Ciudad], [Estado], Marzo de 2026

---

---

# ÍNDICE GENERAL

1. [Introducción](#capítulo-1--introducción)
2. [Marco Teórico](#capítulo-2--marco-teórico)
3. [Planteamiento del Problema](#capítulo-3--planteamiento-del-problema)
4. [Objetivos](#capítulo-4--objetivos)
5. [Metodología](#capítulo-5--metodología)
6. [Desarrollo del Proyecto](#capítulo-6--desarrollo-del-proyecto)
7. [Resultados](#capítulo-7--resultados)
8. [Conclusiones](#capítulo-8--conclusiones)
9. [Recomendaciones](#recomendaciones)
10. [Referencias Bibliográficas](#referencias-bibliográficas)

---

---

## CAPÍTULO 1 — INTRODUCCIÓN

### 1.1 Contexto General

El sector salud atraviesa actualmente una transformación digital profunda y acelerada. La gestión eficiente de la información clínica representa uno de los principales desafíos a los que se enfrentan los hospitales, clínicas y centros de salud en todo el mundo. Durante décadas, la información de los pacientes se registró en expedientes físicos en papel, lo que generaba problemas de acceso, duplicación de datos, pérdida de información y dificultades para compartir datos entre distintos establecimientos de salud. Con el avance de la tecnología de la información, se ha hecho necesario desarrollar soluciones digitales que permitan administrar esta información de manera eficiente, segura e interoperable.

En este contexto, los Sistemas de Información Hospitalaria (SIH) han cobrado una relevancia fundamental. Estos sistemas permiten gestionar de forma integral los procesos clínicos y administrativos de una institución de salud, desde la gestión de pacientes, consultas y citas médicas, hasta la generación de reportes estadísticos y el almacenamiento seguro del expediente clínico electrónico. Sin embargo, uno de los problemas más importantes en esta área es la falta de interoperabilidad, es decir, la capacidad de diferentes sistemas para intercambiar y utilizar información de forma correcta y comprensible.

### 1.2 Importancia de los Sistemas de Información en el Sector Salud

La digitalización de los servicios de salud no es únicamente un tema tecnológico, sino que tiene un impacto directo en la calidad de la atención médica que reciben los pacientes. Un sistema de información hospitalaria bien diseñado permite a los médicos acceder de manera inmediata al historial clínico del paciente, reducir errores en la prescripción de medicamentos, coordinar mejor la atención entre distintos especialistas y agilizar la administración del hospital en general.

Organismos internacionales como la Organización Mundial de la Salud (OMS) y la Organización Panamericana de la Salud (OPS) han señalado reiteradamente que la adopción de sistemas digitales en salud es un factor clave para mejorar los indicadores de salud pública, especialmente en países en vías de desarrollo. En México, la Comisión Nacional de Protección Social en Salud y la Secretaría de Salud han promovido la adopción del expediente clínico electrónico como parte de la estrategia de modernización del sistema de salud pública.

Dentro de este panorama, los estándares de interoperabilidad en salud juegan un papel central. El estándar HL7 FHIR (Fast Healthcare Interoperability Resources) se ha posicionado como la referencia internacional más actualizada y adoptada para el intercambio de información clínica entre sistemas de salud. Desarrollar un sistema hospitalario que implemente este estándar representa una oportunidad real de alinearse con las mejores prácticas internacionales y de contribuir a la modernización del sector salud en México.

### 1.3 Descripción del Proyecto

El proyecto desarrollado durante el período de residencias profesionales consiste en la implementación de un Sistema de Gestión Hospitalaria que utiliza el estándar HL7 FHIR como base para el manejo de información clínica. El sistema está compuesto por dos grandes componentes: un servidor backend desarrollado con Java y el framework Spring Boot, el cual implementa el servidor FHIR mediante la librería HAPI FHIR 8.6.1; y una aplicación frontend desarrollada con Flutter, un framework multiplataforma para dispositivos móviles y web, que proporciona la interfaz gráfica de usuario.

El sistema permite gestionar información de pacientes, médicos y citas médicas siguiendo los lineamientos del estándar FHIR, garantizando así la interoperabilidad con otros sistemas de salud que adopten el mismo estándar. Adicionalmente, se implementó un sistema de autenticación segura basado en tokens JWT (JSON Web Tokens) que protege el acceso a la información clínica mediante roles de usuario diferenciados.

El proyecto fue desarrollado como parte de las residencias profesionales en la carrera de Ingeniería en Sistemas Computacionales del Tecnológico Nacional de México, y representa una implementación real de tecnologías de vanguardia aplicadas a la solución de un problema concreto del sector salud.

### 1.4 Objetivo General del Trabajo

El objetivo principal de este trabajo fue desarrollar un sistema de gestión hospitalaria funcional basado en el estándar HL7 FHIR, que permita la administración eficiente de pacientes, médicos y citas médicas, incorporando mecanismos de seguridad robustos, una interfaz de usuario moderna y multiplataforma, y una infraestructura desplegable mediante tecnologías de contenedores, todo ello orientado a mejorar la gestión de la información clínica en un entorno hospitalario.

### 1.5 Organización del Documento

El presente reporte se encuentra organizado en ocho capítulos. El Capítulo 2 presenta el marco teórico con los conceptos necesarios para comprender el proyecto. El Capítulo 3 desarrolla el planteamiento del problema. El Capítulo 4 define los objetivos del proyecto. El Capítulo 5 describe la metodología de trabajo utilizada. El Capítulo 6 detalla el desarrollo del proyecto por fases. El Capítulo 7 presenta los resultados obtenidos. Finalmente, los Capítulos 8 y 9 presentan las conclusiones y recomendaciones respectivamente.

---

---

## CAPÍTULO 2 — MARCO TEÓRICO

### 2.1 Sistemas de Información Hospitalaria (SIH)

Un Sistema de Información Hospitalaria (SIH), también conocido por sus siglas en inglés HIS (Hospital Information System), es un sistema informático diseñado para gestionar los aspectos administrativos, clínicos y financieros de una institución de salud. Su función principal es recopilar, almacenar, procesar y distribuir la información necesaria para la operación eficiente del hospital o clínica.

Los SIH modernos integran múltiples módulos funcionales que cubren diferentes áreas del hospital, incluyendo la gestión de admisiones y altas, la administración del expediente clínico electrónico, la gestión de citas y consultas, el control de medicamentos e inventarios farmacéuticos, la facturación y cobro, y la generación de reportes estadísticos para la toma de decisiones. La integración de todos estos módulos en una sola plataforma permite eliminar la redundancia de datos y mejorar la coordinación entre los distintos departamentos de la institución.

Según la Organización Panamericana de la Salud, un HIS bien implementado puede reducir el tiempo promedio de atención al paciente entre un 20% y un 40%, disminuir los errores médicos relacionados con la prescripción de medicamentos en un 55%, y mejorar la disponibilidad del expediente clínico del paciente en tiempo real para todos los profesionales de la salud involucrados en su atención (OPS, 2018).

### 2.2 Expediente Clínico Electrónico (ECE)

El Expediente Clínico Electrónico (ECE), también denominado Historia Clínica Electrónica (HCE) o en inglés Electronic Health Record (EHR), es la versión digital del expediente clínico del paciente. Contiene el registro integral y longitudinal de la información clínica del paciente, incluyendo su historial médico, diagnósticos, tratamientos recibidos, resultados de laboratorio y estudios de imagen, alergias conocidas, medicamentos prescritos y notas de evolución de los médicos tratantes.

A diferencia de los expedientes en papel, el ECE permite el acceso simultáneo desde múltiples puntos de atención, la búsqueda eficiente de información, la integración con sistemas de apoyo a la decisión clínica, y el intercambio seguro de información entre distintos establecimientos de salud. En México, la Norma Oficial Mexicana NOM-024-SSA3-2012 establece los criterios técnicos y funcionales para la implementación del expediente clínico electrónico, señalando que debe garantizar la confidencialidad, integridad y disponibilidad de la información clínica.

### 2.3 Interoperabilidad en Sistemas de Salud

La interoperabilidad se define como la capacidad de dos o más sistemas para intercambiar información y utilizar esa información de manera efectiva y comprensible. En el ámbito de la salud, la interoperabilidad es especialmente crítica porque la atención al paciente frecuentemente involucra a múltiples instituciones, especialistas y sistemas de información que deben compartir datos clínicos de forma segura y precisa.

El Consorcio de Interoperabilidad en Salud (IHC por sus siglas en inglés) define cuatro niveles de interoperabilidad: técnica (la conexión física y lógica entre sistemas), sintáctica (el uso de formatos y protocolos comunes), semántica (el uso de terminologías y vocabularios compartidos) y organizacional (los marcos legales y de negocio que permiten el intercambio de datos). Los estándares de salud modernos como HL7 FHIR buscan abordar todos estos niveles simultáneamente.

### 2.4 Estándar HL7 FHIR

**Historia y Contexto
**

HL7 (Health Level Seven International) es una organización sin fines de lucro fundada en 1987, dedicada al desarrollo de estándares para el intercambio de información en el sector salud. Ha sido responsable de varios estándares, entre ellos HL7 v2 (ampliamente utilizado en los años 90 y 2000), HL7 v3 y CDA (Clinical Document Architecture). Sin embargo, fue FHIR (Fast Healthcare Interoperability Resources), publicado inicialmente en 2012 y en su versión R4 en 2019, el estándar que revolucionó la forma en que los sistemas de salud intercambian información.

**¿Qué es FHIR?
**

FHIR es un estándar para el intercambio de información clínica y administrativa en el sector salud basado en tecnologías web modernas. Su diseño está orientado hacia la facilidad de implementación, la flexibilidad y la interoperabilidad. A diferencia de sus predecesores, FHIR utiliza formatos de datos ampliamente conocidos como JSON y XML, y protocolos estándar de internet como HTTP y REST, lo que lo hace accesible para cualquier desarrollador de software con conocimientos web.

El elemento central de FHIR es el concepto de **recurso** (Resource). Un recurso es una unidad de información clínica o administrativa que representa un concepto específico del mundo de la salud. Por ejemplo, el recurso `Patient` representa un paciente y contiene su información básica como nombre, fecha de nacimiento, género e identificadores. El recurso `Observation` representa una observación clínica como los resultados de un análisis de laboratorio. El recurso `Appointment` representa una cita médica. FHIR R4 define más de 150 recursos diferentes que cubren prácticamente todos los aspectos de la atención médica.

**FHIR en el Contexto del Proyecto
**

En el proyecto desarrollado durante las residencias, FHIR R4 fue implementado mediante la librería HAPI FHIR 8.6.1 sobre Spring Boot. Esta implementación proporciona automáticamente el servidor FHIR con todos los endpoints RESTful estándar, permitiendo operaciones como:

- `GET /fhir/Patient` — Búsqueda de pacientes
- `POST /fhir/Patient` — Creación de nuevo paciente
- `PUT /fhir/Patient/{id}` — Actualización de paciente
- `DELETE /fhir/Patient/{id}` — Eliminación de paciente
- `GET /fhir/metadata` — Consulta del CapabilityStatement (descripción de capacidades del servidor)

Cada recurso FHIR se almacena en la base de datos PostgreSQL mediante el mecanismo ORM de HAPI FHIR, que traduce automáticamente entre la representación JSON/XML del recurso y las tablas relacionales de la base de datos.

### 2.5 Estándar openEHR

openEHR es otro estándar internacional para la representación y almacenamiento de información clínica en expedientes de salud electrónicos. Fue desarrollado por la Fundación openEHR y se centra en la representación formal del conocimiento clínico mediante estructuras llamadas **Arquetipos** y **Plantillas**. Mientras que FHIR se enfoca en el intercambio de información entre sistemas, openEHR se especializa en la modelización y almacenamiento a largo plazo del expediente clínico, con especial énfasis en la semántica clínica.

La principal diferencia entre ambos estándares radica en su enfoque: FHIR es más accesible para los desarrolladores web y facilita la interoperabilidad mediante APIs REST, mientras que openEHR ofrece un modelo de datos más rico y expresivo para la representación del pensamiento clínico. En la práctica, muchas implementaciones modernas combinan ambos estándares, utilizando FHIR para el intercambio de datos y openEHR para el almacenamiento y modelización del expediente clínico a largo plazo. Para el proyecto de residencias, se optó por FHIR como estándar principal dado su mayor adopción a nivel internacional y su integración nativa con tecnologías web modernas.

### 2.6 Desarrollo de Software y Metodologías Ágiles

**Metodología de Desarrollo Ágil
**

El desarrollo de software moderno se apoya en metodologías ágiles que permiten entregar valor al cliente de forma iterativa e incremental, adaptándose rápidamente a los cambios de requerimientos. El Manifiesto Ágil, publicado en 2001 por 17 expertos en desarrollo de software, establece cuatro valores fundamentales: los individuos y sus interacciones por encima de los procesos y las herramientas; el software funcionando por encima de la documentación exhaustiva; la colaboración con el cliente por encima de la negociación contractual; y la respuesta al cambio por encima del seguimiento de un plan rígido.

**Scrum
**

Scrum es el marco de trabajo ágil más utilizado en la industria del software. Organiza el trabajo en ciclos de tiempo fijo llamados **sprints**, generalmente de 1 a 4 semanas, al final de los cuales se entrega un incremento funcional del producto. Los roles principales en Scrum son el Product Owner (dueño del producto, responsable de la visión estratégica y la priorización del trabajo), el Scrum Master (facilitador del proceso) y el Equipo de Desarrollo (responsable de la implementación técnica).

En el contexto de las residencias profesionales, se adoptó un enfoque basado en Scrum adaptado a un equipo de desarrollo individual, organizando el trabajo en iteraciones semanales con tareas claramente priorizadas y entregables funcionales al final de cada ciclo.

### 2.7 Arquitectura de Software

**Arquitectura en Capas
**

La arquitectura en capas es un patrón de diseño que organiza el sistema en niveles horizontales, donde cada capa tiene una responsabilidad específica y se comunica únicamente con las capas adyacentes. En el backend del proyecto se implementó una arquitectura de tres capas:

- **Capa de Presentación (Controllers)**: Maneja las solicitudes HTTP entrantes, valida los datos de entrada y retorna las respuestas al cliente.
- **Capa de Negocio (Services)**: Contiene la lógica de negocio del sistema, procesa los datos y coordina las operaciones entre diferentes componentes.
- **Capa de Acceso a Datos (Repositories)**: Gestiona la comunicación con la base de datos mediante Spring Data JPA.

**Arquitectura Cliente-Servidor
**

El sistema sigue una arquitectura cliente-servidor donde el backend (servidor) expone una API REST que el frontend (cliente) consume mediante peticiones HTTP. Esta separación de responsabilidades permite que ambos componentes evolucionen de forma independiente y que el mismo backend pueda ser consumido por múltiples clientes (web, móvil, otros sistemas).

**API REST
**

REST (Representational State Transfer) es un estilo arquitectónico para el diseño de APIs web que utiliza el protocolo HTTP y sus métodos estándar (GET, POST, PUT, DELETE, PATCH) para realizar operaciones sobre recursos identificados por URLs. Una API REST bien diseñada es intuitiva, escalable y fácil de consumir desde cualquier plataforma cliente. FHIR utiliza REST como su protocolo de comunicación principal, lo que hace que la API del sistema developed sea completamente estándar e interoperable.

### 2.8 Tecnologías Utilizadas en el Proyecto

**Java y Spring Boot
**

Java es uno de los lenguajes de programación más utilizados en el desarrollo de aplicaciones empresariales a nivel mundial. Su filosofía "write once, run anywhere" (escribe una vez, ejecuta en cualquier lugar) lo hace altamente portátil. Spring Boot es un framework que facilita el desarrollo de aplicaciones Java eliminando la necesidad de configuraciones complejas y proporcionando configuración automática inteligente. La versión utilizada en el proyecto es Spring Boot 3.5.9, que corre sobre Java 21.

**Flutter y Dart
**

Flutter es un framework de desarrollo de aplicaciones multiplataforma creado por Google que permite desarrollar aplicaciones para móvil (Android e iOS), web y escritorio desde una única base de código escrita en Dart. Flutter utiliza su propio motor de renderizado basado en la librería gráfica Skia, lo que garantiza una apariencia visual consistente en todas las plataformas. Material Design 3 es el sistema de diseño utilizado en la interfaz del proyecto.

**PostgreSQL
**

PostgreSQL es un sistema de gestión de bases de datos relacional de código abierto, reconocido por su robustez, conformidad con el estándar SQL, capacidad para manejar grandes volúmenes de datos y sus características avanzadas como soporte para tipos de datos JSON, transacciones completas ACID y extensibilidad. En el proyecto se utilizó PostgreSQL 16 desplegado mediante Docker.

**Docker y Docker Compose
**

Docker es una plataforma de contenedorización que permite empaquetar una aplicación junto con todas sus dependencias en un contenedor aislado, garantizando que funcione de forma idéntica en cualquier entorno. Docker Compose es una herramienta que permite definir y ejecutar aplicaciones multi-contenedor mediante un archivo de configuración YAML. En el proyecto, Docker Compose se utiliza para desplegar PostgreSQL 16 de forma reproducible y sin necesidad de instalación manual.

**JSON Web Tokens (JWT)
**

JWT es un estándar abierto (RFC 7519) para la creación de tokens de acceso que permiten la autenticación y autorización en aplicaciones web. Un JWT está compuesto por tres partes codificadas en Base64: el encabezado (header), el payload con los datos del usuario y la firma digital que garantiza la integridad del token. En el proyecto se implementó autenticación basada en JWT con BCrypt para el almacenamiento seguro de contraseñas.

**Maven y Maven Wrapper
**

Apache Maven es una herramienta de gestión de proyectos y construcción de software para Java que permite declarar las dependencias del proyecto en un archivo `pom.xml` y automatiza su descarga, compilación y empaquetado. Maven Wrapper es una versión portable de Maven que se incluye dentro del propio proyecto, eliminando la necesidad de instalación global y garantizando que todos los desarrolladores usen exactamente la misma versión de Maven.

**Control de Versiones con Git y GitHub
**

Git es el sistema de control de versiones distribuido más utilizado en la industria del software. Permite registrar y gestionar el historial de cambios del código fuente, trabajar en múltiples características en paralelo mediante ramas (branches) y colaborar de forma eficiente entre varios desarrolladores. GitHub es la plataforma de alojamiento de repositorios Git más popular del mundo, que además ofrece herramientas para la revisión de código, gestión de issues y automatización mediante GitHub Actions.

---

---

## CAPÍTULO 3 — PLANTEAMIENTO DEL PROBLEMA

### 3.1 Identificación del Problema

La gestión de la información clínica en las instituciones de salud en México y América Latina presenta múltiples deficiencias que impactan directamente en la calidad de la atención médica y la eficiencia operativa de los hospitales. A pesar del avance tecnológico de las últimas décadas, muchos establecimientos de salud medianos y pequeños siguen dependiendo de expedientes físicos en papel o de sistemas informáticos obsoletos, propietarios y no interoperables que no cumplen con los estándares internacionales de gestión de información clínica.

Entre los problemas más frecuentes identificados se encuentran los siguientes. En primer lugar, la duplicación de información: cuando un paciente es atendido en diferentes establecimientos de salud, su información clínica se registra de forma independiente en cada uno, generando redundancia y posibles inconsistencias. En segundo lugar, la inaccesibilidad de la información: los expedientes en papel no pueden consultarse de forma simultánea desde múltiples puntos de atención, lo que dificulta la coordinación entre especialistas. En tercer lugar, la ausencia de interoperabilidad: los sistemas propietarios generalmente no pueden comunicarse entre sí ni exportar la información en formatos estándar, lo que crea "islas de información" que obstaculizan la continuidad de la atención médica.

Adicionalmente, la falta de sistemas de autenticación robustos en muchas aplicaciones de salud representa un riesgo significativo para la privacidad y confidencialidad de los datos clínicos de los pacientes, un derecho fundamental reconocido en la Ley Federal de Protección de Datos Personales en Posesión de los Particulares y en la NOM-024-SSA3-2012.

### 3.2 Justificación

El desarrollo de un sistema de gestión hospitalaria basado en el estándar HL7 FHIR se justifica desde múltiples perspectivas. Desde el punto de vista técnico, FHIR representa la evolución más avanzada de los estándares de interoperabilidad en salud, con adopción creciente en países como Estados Unidos, donde la regulación federal (21st Century Cures Act) exige su implementación en sistemas de salud financiados con fondos federales. Adoptar este estándar desde el inicio del desarrollo es una decisión estratégica que garantiza la compatibilidad futura del sistema con otros estándares e implementaciones.

Desde el punto de vista académico, el proyecto representa una oportunidad única para aplicar conceptos avanzados de ingeniería de software, arquitectura de sistemas, desarrollo web y móvil, seguridad informática e interoperabilidad en un contexto real y de alto impacto social. La implementación de un servidor FHIR funcional, un sistema de autenticación JWT completo, una aplicación Flutter multiplataforma y una suite de pruebas automatizadas de 48 casos de prueba constituye un ejercicio integral de ingeniería de software que pocas implementaciones estudiantiles logran alcanzar.

Desde el punto de vista institucional, el proyecto proporciona una base tecnológica sólida sobre la cual una institución de salud podría construir y expandir su infraestructura de información clínica, alineada con los estándares internacionales y con una arquitectura escalable que permite la incorporación de nuevos módulos y funcionalidades.

### 3.3 Alcance

**Lo que incluye el proyecto
**

El sistema desarrollado durante las residencias profesionales comprende los siguientes componentes y funcionalidades:

- Un servidor FHIR R4 completamente funcional basado en HAPI FHIR 8.6.1, con soporte para las operaciones CRUD estándar sobre recursos de pacientes, médicos y citas médicas.
- Un sistema de autenticación personalizado con registro de usuarios, inicio de sesión seguro, generación y validación de tokens JWT, y gestión de roles (Administrador y Usuario).
- Una aplicación frontend multiplataforma desarrollada en Flutter, ejecutable en navegadores web y dispositivos Android, con una interfaz moderna basada en Material Design 3, animaciones de transición, y actualización instantánea de datos en pantalla.
- Una infraestructura de base de datos basada en PostgreSQL 16 desplegada mediante Docker Compose.
- Una suite completa de pruebas unitarias con 23 casos de prueba para el backend (JUnit 5 + Mockito) y 25 casos de prueba para el frontend (flutter_test), con 100% de casos pasando.
- Scripts de automatización para el inicio, gestión y detención del sistema completo en entornos Windows.
- Documentación técnica completa organizada jerárquicamente en READMEs para la raíz del proyecto, el backend y el frontend.
- Control de versiones con Git y repositorio público en GitHub.

**Limitaciones del proyecto
**

El proyecto presenta las siguientes limitaciones que definen su alcance actual:

- El sistema está diseñado para un entorno de desarrollo local; el despliegue en producción en un entorno de nube o servidor físico requeriría configuraciones adicionales de seguridad, HTTPS, y gestión de certificados.
- La implementación actual cubre los recursos FHIR de pacientes, médicos y citas; otros recursos clínicos como diagnósticos, resultados de laboratorio y prescripciones médicas quedan fuera del alcance de las residencias, pero están planificados como trabajo futuro.
- La integración con otros sistemas de información hospitalaria externos no fue implementada, aunque la arquitectura basada en FHIR la facilita en futuras iteraciones.
- No se implementó un módulo de reportes estadísticos ni de análisis de datos clínicos.

---

---

## CAPÍTULO 4 — OBJETIVOS

### 4.1 Objetivo General

Desarrollar un sistema de gestión hospitalaria funcional y completo basado en el estándar internacional HL7 FHIR R4, que permita la administración eficiente y segura de la información clínica de pacientes, médicos y citas médicas, mediante la integración de un servidor backend desarrollado con Java Spring Boot y HAPI FHIR, una aplicación frontend multiplataforma desarrollada con Flutter, y un sistema de autenticación segura basado en tokens JWT, desplegado sobre una infraestructura de base de datos PostgreSQL 16 en contenedores Docker.

### 4.2 Objetivos Específicos

1. **Analizar** los estándares de interoperabilidad en salud, particularmente HL7 FHIR R4, para fundamentar las decisiones de diseño e implementación del sistema y garantizar su conformidad con las mejores prácticas internacionales.

2. **Diseñar** la arquitectura del sistema en tres capas (controlador, servicio, repositorio) siguiendo principios de separación de responsabilidades, bajo acoplamiento y alta cohesión, que permita la escalabilidad y el mantenimiento del sistema a largo plazo.

3. **Desarrollar** el servidor backend con Spring Boot y HAPI FHIR 8.6.1 que implemente todos los endpoints RESTful estándar del protocolo FHIR para la gestión de pacientes, médicos y citas médicas, con soporte para las operaciones de creación, lectura, actualización y eliminación de recursos.

4. **Implementar** un sistema de autenticación y autorización seguro basado en JSON Web Tokens (JWT) y cifrado BCrypt, con gestión diferenciada de roles de usuario, que proteja el acceso a la información clínica y cumpla con los principios de confidencialidad establecidos en la normativa mexicana e internacional.

5. **Desarrollar** la aplicación frontend multiplataforma con Flutter y Material Design 3, que proporcione una experiencia de usuario moderna, responsiva e intuitiva para la gestión de la información clínica, con soporte tanto para navegadores web como para dispositivos Android.

6. **Evaluar** la calidad y el correcto funcionamiento del sistema mediante la implementación de una suite completa de pruebas automatizadas con JUnit 5 y flutter_test, garantizando que los 48 casos de prueba definidos pasen exitosamente en cada compilación del proyecto.

---

---

## CAPÍTULO 5 — METODOLOGÍA

El desarrollo del proyecto de residencias profesionales se llevó a cabo siguiendo una metodología de desarrollo ágil adaptada a las condiciones del entorno de trabajo. A continuación se describen los principales componentes metodológicos que guiaron el proceso.

### 5.1 Marco de Trabajo Scrum

Se adoptó Scrum como marco de trabajo principal, adaptando sus ceremonias y artefactos a un equipo de desarrollo individual. El trabajo se organizó en iteraciones semanales (sprints) con una duración de cinco días hábiles. Cada sprint comenzaba con una planificación donde se identificaban las tareas a realizar durante la semana, se estimaba su complejidad y se priorizaban según su impacto en el avance del proyecto. Al final de cada sprint se realizaba una revisión de los avances obtenidos y se ajustaba el plan para la siguiente iteración.

El backlog del producto fue construido desde el inicio del proyecto con base en el análisis de los requerimientos funcionales y no funcionales del sistema. Las tareas se clasificaron en épicas (grandes bloques de funcionalidad), historias de usuario (descripciones de funcionalidades desde la perspectiva del usuario) y tareas técnicas (trabajo de implementación, configuración y pruebas).

[Insertar imagen del tablero de tareas con backlog, en progreso y completadas]

### 5.2 Planificación y Organización del Proyecto

La planificación del proyecto se realizó en dos niveles. A nivel macro se definieron las fases principales del desarrollo: análisis e investigación de tecnologías, diseño de la arquitectura, implementación del backend, implementación del frontend, integración de componentes, pruebas y validación, documentación y control de versiones. A nivel micro, dentro de cada sprint, se definían tareas específicas con criterios de aceptación claros.

Para el seguimiento del progreso se utilizaron registros detallados en el diario de residencias, donde se documentaban las actividades realizadas cada día, los problemas encontrados, las soluciones implementadas y las lecciones aprendidas. Esta bitácora constituyó la fuente principal de información para la elaboración del presente reporte.

### 5.3 Investigación y Análisis de Tecnologías

Antes de iniciar el desarrollo, se realizó un proceso de investigación y análisis de las tecnologías candidatas para cada componente del sistema. Este proceso incluyó la revisión de documentación oficial, comparación de alternativas, lectura de casos de uso similares y evaluación de criterios como madurez de la tecnología, tamaño de la comunidad, facilidad de integración y rendimiento.

Los principales temas investigados fueron:

- Estándar HL7 FHIR R4, su especificación completa y los recursos relevantes para el proyecto.
- HAPI FHIR como librería de referencia para implementar servidores FHIR en Java, incluyendo la revisión de su documentación oficial y ejemplos de implementación.
- Spring Boot 3 como framework backend, revisando las mejores prácticas de configuración con HAPI FHIR.
- Flutter y el ecosistema Dart para el desarrollo del frontend multiplataforma.
- JWT y BCrypt para la implementación del sistema de autenticación segura.
- Docker y Docker Compose para la gestión de la infraestructura de base de datos.
- JUnit 5, Mockito y flutter_test para el diseño y ejecución de pruebas automatizadas.

[Insertar imagen del entorno de desarrollo con VS Code y extensiones instaladas]

### 5.4 Diseño de la Arquitectura del Sistema

El diseño de la arquitectura del sistema fue una de las etapas más críticas del proyecto. Se tomaron decisiones fundamentales sobre la separación de responsabilidades entre el backend y el frontend, la estructura interna de cada componente, los mecanismos de comunicación entre ellos y la forma en que la información se almacenaría y recuperaría de la base de datos.

La arquitectura resultante sigue un patrón de tres capas en el backend:

**Capa de Controladores (Controllers)**: Recibe las solicitudes HTTP del cliente, valida los datos de entrada y delega el procesamiento a la capa de servicios. Los controladores implementados incluyen `AuthController.java` (gestión de autenticación: registro, inicio de sesión y validación de token) y `UserController.java` (gestión CRUD de usuarios).

**Capa de Servicios (Services)**: Implementa la lógica de negocio del sistema. Esta capa es responsable de orquestar las operaciones necesarias para cumplir con los requerimientos del negocio, coordinando la comunicación con la capa de repositorios y aplicando las reglas de negocio correspondientes.

**Capa de Repositorios (Repositories)**: Gestiona el acceso a la base de datos mediante Spring Data JPA, abstrayendo los detalles del almacenamiento y proporcionando métodos de consulta y persistencia sobre las entidades del dominio.

El frontend Flutter se diseñó también con una separación clara de responsabilidades mediante el patrón Provider para la gestión del estado de la aplicación.

[Insertar imagen de la arquitectura del sistema mostrando las tres capas]

### 5.5 Desarrollo de Prototipos Funcionales

El desarrollo se llevó a cabo mediante entregas incrementales. Primero se implementó la funcionalidad básica del servidor FHIR, verificando que los endpoints respondían correctamente. Posteriormente se implementó el sistema de autenticación, la lógica de negocio y las operaciones CRUD completas. En paralelo, el frontend comenzó con un prototipo de baja fidelidad que fue refinándose iterativamente hasta alcanzar el diseño final con Material Design 3.

Cada incremento funcional fue validado manualmente antes de avanzar al siguiente, y las pruebas unitarias se escribieron en paralelo con el código de producción siguiendo, en la medida de lo posible, la práctica de desarrollo dirigido por pruebas (TDD: Test Driven Development).

### 5.6 Configuración del Entorno de Desarrollo

El entorno de desarrollo fue configurado cuidadosamente para garantizar la reproducibilidad y la portabilidad del proyecto. Las herramientas principales instaladas y configuradas fueron:

- **Java 21.0.10 (OpenJDK)**: Entorno de ejecución y compilación del backend.
- **Maven Wrapper 3.3.2**: Herramienta de construcción incluida en el proyecto, eliminando la dependencia de instalación global de Maven.
- **Flutter 3.27.3 / Dart 3.6.1 (canal estable)**: SDK para el desarrollo del frontend.
- **Docker Desktop**: Motor de contenedores para el despliegue de PostgreSQL 16.
- **Visual Studio Code**: Editor de código principal, con extensiones para Java, Spring Boot, Flutter, Dart y GitHub Copilot.
- **Git 2.x**: Sistema de control de versiones.

[Insertar imagen de terminal mostrando versiones de herramientas instaladas]

Para facilitar el inicio y gestión del sistema, se desarrollaron cuatro scripts de Windows Batch (.bat) que automatizan el proceso completo de arranque y detención del sistema, reduciendo el tiempo de inicio de entre cinco y diez minutos a aproximadamente treinta segundos.

### 5.7 Control de Versiones

Se utilizó Git para el control de versiones del código fuente, con el repositorio alojado en GitHub bajo el nombre `His-TECNM-MX`. La estrategia de control de versiones siguió la convención de "Conventional Commits", que estandariza los mensajes de commit con un prefijo que indica el tipo de cambio: `feat` para nuevas funcionalidades, `docs` para cambios en documentación, `fix` para corrección de errores y `refactor` para reestructuraciones de código.

El historial de commits al momento de este reporte cuenta con más de 35 commits, que representan un registro detallado de la evolución del proyecto desde su inicio. Cada commit incluye una descripción clara de los cambios realizados, facilitando la trazabilidad y el auditoría del desarrollo.

### 5.8 Pruebas y Validación del Sistema

La validación del sistema se realizó mediante una combinación de pruebas unitarias automatizadas y pruebas manuales de los flujos de usuario completos. Las pruebas unitarias garantizan que cada componente individual del sistema funciona correctamente de forma aislada, mientras que las pruebas manuales verifican el comportamiento del sistema completo desde la perspectiva del usuario.

Para el backend, se implementaron 23 casos de prueba en JUnit 5 con Mockito como librería de simulación (mocking). Para el frontend, se implementaron 25 casos de prueba en flutter_test. Todos estos casos de prueba se ejecutan automáticamente como parte del proceso de construcción del proyecto, garantizando que cualquier cambio en el código no introduzca regresiones en funcionalidades previamente validadas.

---

---

## CAPÍTULO 6 — DESARROLLO DEL PROYECTO

El desarrollo del proyecto se llevó a cabo de forma iterativa durante el periodo de residencias profesionales. A continuación se describe detalladamente el trabajo realizado, organizado por fases de desarrollo.

### 6.1 Fase 1: Configuración Inicial e Investigación de Tecnologías

**Selección y Evaluación del Stack Tecnológico
**

La primera fase del proyecto se dedicó a la investigación y selección de las tecnologías más adecuadas para implementar el sistema. Tras analizar múltiples alternativas, se optó por el siguiente stack tecnológico:

Para el backend, se seleccionó **HAPI FHIR JPA Server** sobre **Spring Boot** como la solución más completa y madura para implementar un servidor FHIR en Java. HAPI FHIR es la implementación de referencia de FHIR en Java, mantenida activamente por la comunidad internacional y utilizada en implementaciones de producción en hospitales de todo el mundo. La versión 8.6.1 utilizada ofrece soporte completo para FHIR R4, el International Patient Summary (IPS) y las operaciones CDS Hooks para soporte a la decisión clínica.

La elección de **PostgreSQL 16** como sistema de base de datos se fundamentó en su reconocida estabilidad, su capacidad para manejar grandes volúmenes de datos, su soporte nativo para JSON (relevante para el almacenamiento de recursos FHIR) y la disponibilidad de un dialecto Hibernate especializado en HAPI FHIR que optimiza significativamente el rendimiento de las consultas FHIR (`HapiFhirPostgresDialect`).

Para el frontend, se eligió **Flutter** por su capacidad de generar aplicaciones nativas de alto rendimiento tanto para dispositivos Android como para navegadores web desde una única base de código escrita en Dart. Esta característica es especialmente valiosa en el contexto hospitalario, donde los usuarios pueden necesitar acceder al sistema desde dispositivos móviles durante las rondas médicas o desde computadoras de escritorio en la consulta.

**Configuración del Repositorio y Ambiente de Desarrollo
**

Se creó el repositorio en GitHub bajo el nombre `His-TECNM-MX` y se configuró la estructura básica del proyecto con las carpetas `backend/` y `frontend/`. Se estableció el archivo `.gitignore` para excluir archivos compilados, dependencias descargadas y configuraciones locales del control de versiones.

El ambiente de desarrollo fue configurado con Java 21, Maven Wrapper, Flutter 3.27.3 y Docker Desktop. Se verificó el correcto funcionamiento de cada herramienta ejecutando los comandos de diagnóstico correspondientes.

[Insertar imagen del explorador de VS Code mostrando la estructura del proyecto]

### 6.2 Fase 2: Implementación del Servidor FHIR y Sistema de Autenticación

**Configuración del Servidor HAPI FHIR
**

El servidor FHIR fue configurado como una aplicación Spring Boot que extiende las capacidades del HAPI FHIR JPA Server. La configuración se realizó principalmente a través del archivo `application.yaml`, donde se especificaron los parámetros clave del servidor:

```yaml
hapi:
  fhir:
    fhir_version: R4
    server_address: http://localhost:8080/fhir
    default_page_size: 20
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fhirdb
    username: fhiruser
    password: fhirpass
  jpa:
    properties:
      hibernate:
        dialect: ca.uhn.fhir.jpa.model.dialect.HapiFhirPostgresDialect
```

La infraestructura de base de datos fue definida en el archivo `docker-compose.yml`, que especifica un contenedor PostgreSQL 16 con Alpine Linux, volúmenes persistentes para los datos y las variables de entorno necesarias para la conexión.

[Insertar imagen del endpoint /fhir/metadata mostrando el CapabilityStatement del servidor FHIR]

**Implementación del Sistema de Autenticación JWT
**

Uno de los aportes más significativos del proyecto fue la implementación de un sistema de autenticación personalizado sobre HAPI FHIR, ya que la librería por defecto no incluye un sistema de autenticación para aplicaciones personalizadas. Este sistema se desarrolló como un módulo independiente dentro del paquete `ca.uhn.fhir.jpa.starter.auth/`, con la siguiente estructura:

**Entidad de Usuario (`User.java`)**: Representa un usuario del sistema en la base de datos. Almacena el nombre de usuario, la contraseña cifrada con BCrypt, el correo electrónico, el rol (ADMIN o USER), el estado de la cuenta y las fechas de creación y última actualización.

**Controlador de Autenticación (`AuthController.java`)**: Expone los endpoints REST para el registro de nuevos usuarios (`POST /api/auth/signup`), el inicio de sesión (`POST /api/auth/login`) y la validación de tokens (`GET /api/auth/validate`).

**Controlador de Usuarios (`UserController.java`)**: Proporciona operaciones CRUD completas para la gestión de usuarios, incluyendo listado, creación, actualización, cambio de estado (activar/desactivar) y eliminación.

**Servicio de Autenticación (`AuthService.java`)**: Implementa la lógica de negocio del sistema de autenticación, incluyendo la verificación de credenciales, el cifrado de contraseñas con BCrypt y la generación de tokens JWT.

**Utilidad JWT (`JwtUtil.java`)**: Encapsula la generación, firma y validación de tokens JWT usando la librería JJWT 0.12.6. Los tokens incluyen el nombre de usuario, el rol y una fecha de expiración configurable.

La implementación siguió las mejores prácticas de seguridad: las contraseñas nunca se almacenan en texto plano (siempre cifradas con BCrypt con factor de costo 10), los tokens JWT se firman con una clave secreta configurada como variable de entorno, y las rutas protegidas verifican la validez del token antes de permitir el acceso a los recursos FHIR.

**Pruebas Unitarias del Backend
**

Para garantizar el correcto funcionamiento del sistema de autenticación, se implementó una suite de pruebas unitarias con JUnit 5 y Mockito:

**AuthControllerTest.java** (12 casos de prueba):
- Prueba de registro exitoso con datos válidos
- Prueba de registro fallido por usuario duplicado
- Prueba de inicio de sesión exitoso con credenciales correctas
- Prueba de inicio de sesión fallido por contraseña incorrecta
- Prueba de inicio de sesión fallido por usuario inexistente
- Prueba de validación de token válido
- Prueba de validación de token expirado
- Prueba de validación de token malformado
- Pruebas de validación de campos requeridos en registro
- Prueba de inicio de sesión con usuario desactivado

**UserControllerTest.java** (11 casos de prueba):
- Prueba de listado de usuarios como administrador
- Prueba de acceso denegado como usuario regular
- Prueba de creación de nuevo usuario
- Prueba de actualización de datos de usuario
- Prueba de activación y desactivación de usuario
- Prueba de eliminación de usuario
- Pruebas de manejo de errores para IDs inexistentes

[Insertar imagen del terminal mostrando la ejecución de mvnw.cmd test con BUILD SUCCESS]

### 6.3 Fase 3: Desarrollo del Frontend con Flutter

**Arquitectura del Frontend
**

La aplicación Flutter fue desarrollada siguiendo el patrón de arquitectura **Provider**, que es la solución recomendada por el equipo de Flutter para la gestión del estado de aplicaciones de tamaño mediano. La estructura del proyecto frontend se organizó de la siguiente manera:

- `lib/config/api_config.dart`: Gestiona la configuración dinámica de las URLs del backend, detectando automáticamente si la aplicación corre en un navegador web (usando `localhost`) o en un dispositivo móvil (usando la IP de red local del servidor).
- `lib/providers/auth_provider.dart`: Gestiona el estado de autenticación de la aplicación, incluyendo el token JWT actual, los datos del usuario autenticado y los cambios de estado de sesión.
- `lib/services/auth_service.dart`: Cliente HTTP para los endpoints de autenticación del backend.
- `lib/services/fhir_service.dart`: Cliente HTTP para los endpoints FHIR del backend, incluyendo la gestión de pacientes, médicos y citas.
- `lib/models/`: Contiene los modelos de datos Dart que representan los recursos FHIR (paciente, cita médica).
- `lib/screens/`: Contiene las pantallas de la aplicación.

[Insertar imagen de la aplicación Flutter mostrando la pantalla de inicio de sesión]

**Diseño de la Interfaz de Usuario
**

La interfaz fue diseñada siguiendo Material Design 3, el sistema de diseño más reciente de Google. La pantalla de inicio de sesión presenta un diseño moderno con un fondo degradado en tonos morado y azul, y una tarjeta central con efecto glassmórfico que contiene el formulario de autenticación. Este diseño proporciona una apariencia profesional y atractiva que transmite confianza al usuario.

Las animaciones de entrada implementadas en la pantalla de inicio de sesión utilizan `FadeTransition` (fundido de entrada en 1200 milisegundos) y `SlideTransition` (desplazamiento suave desde abajo) para crear una primera impresión positiva. La pantalla principal utiliza `ScaleTransition` escalonada (1500 milisegundos) para presentar gradualmente los elementos de la interfaz.

La pantalla de gestión de pacientes (`PatientListScreen`) proporciona las siguientes funcionalidades:
- Listado de todos los pacientes registrados en el servidor FHIR
- Búsqueda en tiempo real por nombre o identificador del paciente
- Formulario de creación y edición de pacientes con campos validados
- Actualización instantánea de la lista al crear un nuevo paciente, sin necesidad de recargar manualmente
- Notificación visual (SnackBar) de confirmación cuando se crea exitosamente un nuevo paciente

[Insertar imagen de la lista de pacientes mostrando el SnackBar de confirmación]

**Configuración Dinámica de Red
**

Un desafío técnico identificado durante el desarrollo fue la necesidad de que la aplicación Flutter funcione correctamente tanto en navegador web (donde el backend se accede como `localhost`) como en dispositivos Android (donde el backend se accede mediante la IP de red local del servidor, por ejemplo `192.168.1.x`). 

La solución implementada detecta automáticamente la plataforma en tiempo de ejecución mediante la constante `kIsWeb` de Flutter y ajusta la URL base del backend correspondiente. Para facilitar la actualización de la IP de red al trabajar en diferentes entornos de desarrollo, se creó el script PowerShell `update-ip.ps1` que modifica automáticamente el archivo de configuración con la IP actual del equipo.

**Pruebas Unitarias del Frontend
**

Se implementaron 25 casos de prueba para el frontend usando el framework `flutter_test` y `mockito` para Dart:

**auth_service_test.dart** (12 casos de prueba):
- Login exitoso retorna token JWT válido
- Login fallido con credenciales incorrectas lanza excepción
- Registro de nuevo usuario exitoso
- Registro fallido por usuario duplicado
- Validación de token válido retorna true
- Validación de token inválido retorna false
- Manejo de timeout en petición de login
- Manejo de error de conexión (backend no disponible)
- Cierre de sesión limpia el token almacenado
- Renovación de token antes de expiración
- Prueba de serialización/deserialización de AuthResponse
- Prueba de manejo de respuesta HTTP 500

**fhir_service_test.dart** (11 casos de prueba):
- Obtención de lista de pacientes exitosa
- Creación de paciente FHIR con datos válidos
- Actualización de datos de paciente existente
- Eliminación de paciente existente
- Búsqueda de pacientes por nombre
- Manejo de búsqueda sin resultados
- Creación de cita médica exitosa
- Obtención de citas por paciente
- Manejo de error 404 para recurso inexistente
- Manejo de error de autenticación (401 Unauthorized)
- Prueba de paginación de resultados

**widget_test.dart** (2 casos de prueba):
- Renderizado correcto del widget de tarjeta de paciente
- Renderizado correcto del formulario de login con campos vacíos

[Insertar imagen del terminal mostrando flutter test con "All tests passed!"]

### 6.4 Fase 4: Automatización del Entorno de Desarrollo

**Scripts de Iniciación Automática
**

Durante el desarrollo se identificó que el proceso de inicio manual del sistema era tedioso y propenso a errores, requiriendo abrir múltiples terminales, ejecutar comandos en un orden específico, esperar tiempos precisos entre pasos y gestionar manualmente los conflictos de puertos. Para resolver este problema se desarrollaron cuatro scripts de automatización en formato Windows Batch:

**`iniciar-sistema.bat`** (script maestro de 50 líneas):
Este script gestiona el inicio completo del sistema en el orden correcto. Primero verifica si existe algún contenedor Docker activo en el puerto 8080 que pudiera generar conflictos (en particular el contenedor `ehrbase-server` de un proyecto anterior) y ofrece al usuario la opción de detenerlo automáticamente. Luego inicia el contenedor de PostgreSQL 16 mediante Docker Compose si no está activo, espera 10 segundos para que la base de datos esté lista, abre una nueva ventana de terminal con el servidor Spring Boot ejecutándose, espera 20 segundos adicionales para que el backend compile e inicie, y finalmente abre el frontend Flutter en el navegador Chrome.

**`iniciar-backend.bat`** (40 líneas):
Gestiona exclusivamente el inicio del backend, incluyendo la detección de conflictos en el puerto 8080, la iniciación de PostgreSQL y la ejecución del servidor Spring Boot en modo desarrollo con hot-reload habilitado.

**`iniciar-frontend.bat`** (35 líneas):
Verifica que el backend esté respondiendo (mediante una solicitud HTTP al endpoint `/fhir/metadata`) antes de iniciar el frontend, mostrando un mensaje de error informativo si el backend no está disponible.

**`detener-sistema.bat`** (45 líneas):
Detiene ordenadamente todos los componentes del sistema: primero los procesos Java (backend), luego los procesos Dart (frontend) y finalmente ejecuta `docker-compose down` para detener y eliminar el contenedor de PostgreSQL.

**Resolución de Problemas Técnicos en Scripts
**

Durante el desarrollo de los scripts se encontraron dos problemas técnicos importantes. El primero fue la incompatibilidad de caracteres Unicode (emojis) con el intérprete de comandos `cmd.exe` de Windows, que usa una codificación heredada (CP437/CP850) que no puede procesar correctamente los bytes UTF-8 de los emojis, causando el error "No se esperaba ... en este momento". La solución fue eliminar todos los caracteres no-ASCII de los scripts, usando únicamente texto ASCII puro.

El segundo problema fue la sintaxis de la plantilla de formato de Docker (`{{.Names}}`), que el intérprete de batch interpretaba incorrectamente. La solución fue ajustar la sintaxis del comando para evitar el conflicto con los delimitadores de variables de batch.

La implementación de estos scripts redujo el tiempo de inicio del sistema de entre cinco y diez minutos a aproximadamente treinta segundos automáticos, mejorando significativamente la experiencia de desarrollo.

### 6.5 Fase 5: Consolidación de la Documentación Técnica

**Problema con la Documentación Preexistente
**

Al analizar la estructura de documentación del proyecto, se identificó que había más de veinte archivos Markdown dispersos en el repositorio, muchos de ellos con información redundante, desactualizada o que se solapaba con otros documentos. Esta situación dificultaba significativamente la navegación y comprensión del proyecto para cualquier nuevo desarrollador.

**Estrategia de Consolidación
**

Se aplicó el principio DRY (Don't Repeat Yourself) a la documentación, consolidando toda la información en tres documentos centrales organizados jerárquicamente:

**`README.md` (350 líneas)**: Documento raíz del proyecto que proporciona una visión general del sistema, el stack tecnológico completo, la guía de inicio rápido con los scripts automáticos, los principales endpoints de la API, las credenciales de desarrollo, la cobertura de pruebas, los requisitos del sistema y la guía de troubleshooting.

**`backend/README.md` (280 líneas)**: Documentación específica del backend que incluye la arquitectura de tres capas, la estructura detallada del código Java, la documentación completa de la API REST, la configuración de Spring Boot y PostgreSQL, los 23 tests unitarios y la guía de seguridad con JWT y BCrypt.

**`frontend/README.md` (250 líneas)**: Documentación del frontend Flutter con la arquitectura basada en Provider, los detalles de configuración dinámica de red, la estructura de screens, services y models, los 25 tests funcionales y la guía para la construcción de Android y Web.

Esta consolidación resultó en la eliminación de dieciséis archivos redundantes y la reducción de 8,548 líneas innecesarias, produciendo una documentación más clara, coherente y fácil de mantener.

[Insertar imagen del explorador de archivos mostrando la estructura de documentación organizada]

### 6.6 Fase 6: Mejoras en la Experiencia de Usuario del Frontend

**Problema de Actualización de la Lista de Pacientes
**

Se identificó que al crear un nuevo paciente desde la pantalla de formulario, la lista de pacientes en la pantalla principal no se actualizaba automáticamente, requiriendo que el usuario presionara manualmente el botón de refrescar para ver el nuevo registro. Este comportamiento generaba confusión y una mala experiencia de usuario.

**Análisis Técnico del Problema
**

El análisis del código reveló que el método `_navigateToForm()` de la clase `PatientListScreen` tenía un flujo inadecuado: al recibir el resultado del formulario, llamaba a `setState()` para agregar el nuevo paciente a la lista, y dentro de ese mismo `setState()` llamaba al método `_filterPatients()`, el cual a su vez llamaba a otro `setState()` internamente. Este patrón de `setState()` anidado es incorrecto en Flutter y genera warnings en la consola de depuración, además de posibles inconsistencias en la actualización de la interfaz.

**Solución Implementada
**

La solución consistió en refactorizar la lógica de actualización para eliminar el `setState()` anidado. El nuevo flujo modifica primero los datos (`_patients.add(result)`) fuera de cualquier llamada a `setState()`, y posteriormente invoca `_filterPatients()` una sola vez, el cual contiene el único `setState()` necesario para actualizar la interfaz. Adicionalmente, se implementó una copia correcta de la lista usando `List.from()` en lugar de una simple asignación por referencia, que podría causar comportamientos inesperados al modificar la lista original.

Como mejora adicional de experiencia de usuario, se implementó un `SnackBar` de color verde que aparece brevemente en la parte inferior de la pantalla con un mensaje de confirmación como "✓ Juan Pérez García agregado a la lista", proporcionando retroalimentación visual inmediata al usuario sobre el resultado de su acción.

El resultado fue una actualización completamente instantánea de la lista (sin delay perceptible), código más limpio y predecible, y una experiencia de usuario significativamente mejorada.

---

---

## CAPÍTULO 7 — RESULTADOS

### 7.1 Sistema Completamente Funcional

Al concluir el período de residencias, el sistema de gestión hospitalaria se encuentra completamente funcional con todos sus componentes integrados y operativos. El sistema puede ser iniciado mediante el script `iniciar-sistema.bat` y proporciona las siguientes funcionalidades verificadas:

- **Gestión de pacientes**: El sistema permite crear, consultar, actualizar y eliminar pacientes siguiendo el estándar FHIR R4. Cada paciente se almacena como un recurso FHIR `Patient` en la base de datos PostgreSQL, garantizando la conformidad con el estándar internacional.

- **Autenticación segura**: Los usuarios pueden registrarse, iniciar sesión y gestionar su cuenta de forma segura. Las contraseñas están cifradas con BCrypt y el acceso se controla mediante tokens JWT firmados digitalmente.

- **Interfaz multiplataforma**: La aplicación Flutter funciona correctamente tanto en el navegador web Chrome como en dispositivos Android con Android 16 (API 36), proporcionando una experiencia de usuario consistente en ambas plataformas.

- **API REST FHIR estándar**: El servidor expone todos los endpoints RESTful del protocolo FHIR R4, incluyendo el `CapabilityStatement` accesible en `GET /fhir/metadata` que describe todas las capacidades del servidor.

[Insertar imagen del sistema funcionando en el navegador web mostrando la lista de pacientes]

### 7.2 Suite de Pruebas Automatizadas

Uno de los resultados más significativos del proyecto es la suite de pruebas automatizadas completamente operativa:

| Componente | Framework | Casos de Prueba | Estado |
|---|---|---|---|
| Backend - AuthController | JUnit 5 + Mockito | 12 | 100% exitosos |
| Backend - UserController | JUnit 5 + Mockito | 11 | 100% exitosos |
| Frontend - auth_service | flutter_test | 12 | 100% exitosos |
| Frontend - fhir_service | flutter_test | 11 | 100% exitosos |
| Frontend - Widgets | flutter_test | 2 | 100% exitosos |
| **TOTAL** | | **48** | **100% exitosos** |

La ejecución de las pruebas del backend mediante el comando `.\mvnw.cmd test` arroja el resultado: `Tests run: 23, Failures: 0, Errors: 0, Skipped: 0, BUILD SUCCESS`. Para el frontend, el comando `flutter test` produce: `00:00 +25: All tests passed!`.

Esta cobertura de pruebas significa que cualquier desarrollador puede realizar cambios en el sistema y verificar inmediatamente si su modificación ha introducido alguna regresión en la funcionalidad existente, lo que da una sólida confianza para el mantenimiento y evolución futura del sistema.

[Insertar imagen del terminal mostrando BUILD SUCCESS del backend]

### 7.3 Infraestructura Automatizada

Los scripts de automatización desarrollados representan una mejora sustancial en la experiencia de desarrollo:

| Métrica | Antes (proceso manual) | Después (scripts automáticos) |
|---|---|---|
| Tiempo de inicio del sistema | 5-10 minutos | ~30 segundos |
| Pasos manuales necesarios | 8-12 pasos | 1 solo clic |
| Probabilidad de errores | Alta | Muy baja |
| Gestión de conflictos de puerto | Manual | Automática |

La reducción del tiempo de inicio de diez minutos a treinta segundos representa un ahorro estimado de 22.5 minutos por día de desarrollo (considerando cinco sesiones de inicio por día), lo que equivale a 7.5 horas de tiempo ahorrado mensualmente.

### 7.4 Calidad de la Documentación

La consolidación de la documentación produjo los siguientes resultados cuantificables:

- Reducción de 20+ archivos Markdown a 8 archivos esenciales (reducción del 60%)
- Eliminación de 8,548 líneas de documentación redundante
- Creación de 1,256 líneas de documentación nueva y actualizada
- Estructura jerárquica clara que permite a un nuevo desarrollador comprender el proyecto en aproximadamente 30 minutos (estimación reducida de 2 horas previas)

### 7.5 Control de Versiones y Trazabilidad

El proyecto cuenta con un historial completo de más de 35 commits en GitHub, organizados con mensajes descriptivos que facilitan la comprensión de la evolución del proyecto. Los dos commits más representativos del trabajo de residencias son:

- `3841f5c` — "feat: Scripts de iniciacion automaticos y actualizacion instantanea" (+371 líneas, -37 líneas, 8 archivos)
- `0e466d4` — "docs: Consolidar documentacion en 3 READMEs principales" (+885 líneas, -8,548 líneas, 19 archivos modificados)

### 7.6 Competencias Técnicas Desarrolladas

A lo largo del proyecto se desarrollaron y consolidaron competencias técnicas en las siguientes áreas:

- Desarrollo backend con Spring Boot y arquitectura en capas
- Implementación de servidores FHIR con la librería HAPI FHIR
- Desarrollo frontend multiplataforma con Flutter y Dart
- Autenticación segura con JWT y BCrypt
- Bases de datos relacionales con PostgreSQL y JPA/Hibernate
- Testing unitario con JUnit 5 y flutter_test
- Contenedorización con Docker y Docker Compose
- Control de versiones con Git y GitHub
- Automatización con Windows Batch Scripts y PowerShell
- Documentación técnica estructurada

---

---

## CAPÍTULO 8 — CONCLUSIONES

**Primera conclusión — Viabilidad de los estándares internacionales en implementaciones académicas**

El desarrollo del Sistema de Gestión Hospitalaria demostró que es completamente viable implementar estándares internacionales de vanguardia como HL7 FHIR R4 en el contexto de un proyecto académico de residencias profesionales, siempre que se cuente con las herramientas adecuadas (en este caso, la librería HAPI FHIR) y con una disciplina metodológica rigurosa. Esto rompe la percepción de que los estándares de interoperabilidad en salud son territorio exclusivo de grandes empresas o proyectos con presupuestos millonarios, y demuestra que un estudiante de ingeniería en sistemas con dedicación y metodología puede contribuir significativamente a la digitalización del sector salud desde un proyecto universitario.

**Segunda conclusión — Importancia de las pruebas automatizadas como herramienta de calidad**

La implementación de 48 casos de prueba automatizados (23 backend + 25 frontend) fue una de las decisiones más acertadas del proyecto. Durante el desarrollo de las mejoras y refactorizaciones, las pruebas actuaron como una red de seguridad que alertó inmediatamente cuando algún cambio introdujo una inconsistencia en el comportamiento esperado del sistema. Esta experiencia práctica confirmó que las pruebas automatizadas no son una actividad opcional o separada del desarrollo, sino un componente integral de la ingeniería de software de calidad. Además, las pruebas constituyen la forma más precisa y siempre actualizada de documentar el comportamiento esperado del sistema.

**Tercera conclusión — Valor de la automatización en el proceso de desarrollo**

Los scripts de automatización desarrollados para el inicio y gestión del sistema ilustran perfectamente el principio de que el tiempo invertido en automatizar tareas repetitivas siempre produce retornos positivos. La reducción del tiempo de inicio del sistema de diez minutos a treinta segundos puede parecer trivial en una sola sesión de trabajo, pero acumulada a lo largo de semanas y meses de desarrollo representa horas de tiempo recuperado para actividades de mayor valor. Este principio es aplicable en cualquier área de la ingeniería de software y constituye una habilidad profesional fundamental.

**Cuarta conclusión — La interoperabilidad como base del futuro de la salud digital**

El trabajo realizado confirmó que la interoperabilidad no es un lujo técnico, sino una necesidad fundamental para cualquier sistema de información hospitalaria moderno. Un sistema que implementa FHIR puede, en principio, intercambiar información con cualquier otro sistema FHIR en el mundo, independientemente del lenguaje de programación, la base de datos o la plataforma en que esté implementado. Esta característica es especialmente relevante en el contexto mexicano, donde la fragmentación del sistema de salud (IMSS, ISSSTE, SSA, sector privado) hace que la interoperabilidad entre sistemas sea una necesidad urgente para mejorar la continuidad de la atención médica de los pacientes.

**Quinta conclusión — Desarrollo multiplataforma como estrategia de alcance**

La elección de Flutter como framework para el frontend demostró ser acertada. La capacidad de desarrollar una sola aplicación que funciona correctamente en navegadores web y en dispositivos Android desde una única base de código en Dart reduce significativamente el esfuerzo de desarrollo y mantenimiento. En el contexto hospitalario, donde los usuarios incluyen tanto personal administrativo que trabaja en computadoras de escritorio como médicos y enfermeras que usan tabletas o teléfonos inteligentes durante sus rondas, la capacidad multiplataforma no es un lujo sino una necesidad práctica.

**Sexta conclusión — Impacto del aprendizaje experiencial en la formación profesional**

Las residencias profesionales representaron una experiencia de aprendizaje cualitativamente diferente a la formación en aula. La necesidad de tomar decisiones técnicas reales con consecuencias concretas, resolver problemas que no tienen una solución preestablecida en un libro de texto, gestionar el tiempo y las prioridades de forma autónoma, y documentar el trabajo de manera que pueda ser comprendido y continuado por otros profesionales, son competencias que solo se desarrollan en la práctica. El proyecto desarrollado es evidencia tangible de las competencias adquiridas durante la carrera y de la capacidad del egresado para contribuir al desarrollo tecnológico del país.

---

---

## RECOMENDACIONES

**Primera recomendación — Implementar certificados HTTPS para despliegue en producción**

El sistema actual está desarrollado y probado para un entorno de desarrollo local (localhost) y no incluye configuración de HTTPS. Antes de cualquier despliegue en un entorno de producción accesible desde internet, es indispensable configurar certificados TLS/SSL para cifrar todas las comunicaciones entre el cliente y el servidor. Esto protege la información clínica de los pacientes de posibles interceptaciones durante la transmisión y es un requisito legal bajo la Ley Federal de Protección de Datos Personales en Posesión de los Particulares. Se recomienda utilizar Let's Encrypt para obtener certificados gratuitos y renovables automáticamente, integrados con un proxy inverso como NGINX.

**Segunda recomendación — Expandir el modelo de datos FHIR con recursos clínicos adicionales**

En su estado actual, el sistema gestiona recursos de tipo `Patient`, `Practitioner` y `Appointment`. Sin embargo, un sistema hospitalario completo requiere muchos otros recursos FHIR, como `Observation` (para registrar signos vitales y resultados de laboratorio), `MedicationRequest` (para la prescripción de medicamentos), `AllergyIntolerance` (para el registro de alergias), `Condition` (para el registro de diagnósticos) y `DiagnosticReport` (para informes de estudios de imagen y laboratorio). La expansión hacia estos recursos, siguiendo la misma arquitectura y patrones de código ya establecidos, permitiría convertir el sistema en un expediente clínico electrónico completo.

**Tercera recomendación — Implementar un pipeline de integración y despliegue continuos (CI/CD)**

Para asegurar la calidad del código de forma sistemática y facilitar el proceso de despliegue, se recomienda configurar GitHub Actions para implementar un pipeline de CI/CD. Este pipeline ejecutaría automáticamente la suite completa de pruebas (backend y frontend) cada vez que se hace un commit al repositorio, y en caso de que todos los tests pasen, podría desplegar automáticamente la nueva versión del sistema al entorno de staging o producción. Esto eleva significativamente el nivel de profesionalismo del proyecto y adopta una práctica estándar en la industria del software.

**Cuarta recomendación — Agregar paginación y filtros avanzados en la interfaz de usuario**

A medida que el número de pacientes registrados en el sistema crezca, la carga y visualización de toda la lista de pacientes en una sola pantalla se volverá ineficiente. Se recomienda implementar paginación en el endpoint de listado de pacientes (FHIR ya tiene soporte nativo para esto mediante el parámetro `_count` y los bundles de tipo `searchset`) y en la interfaz Flutter para que el usuario reciba los datos en páginas manejables. Adicionalmente, se recomienda agregar filtros avanzados por rango de fechas de nacimiento, género, estado del paciente y otros parámetros FHIR estándar.

**Quinta recomendación — Evaluar la integración con sistemas FHIR externos para pruebas de interoperabilidad**

Una de las principales ventajas del estándar FHIR es precisamente la interoperabilidad con otros sistemas que lo implementan. Se recomienda realizar pruebas de integración con servidores FHIR públicos de referencia, como el sandbox de HL7 FHIR (`https://hapi.fhir.org`) o el servidor de Google Healthcare API, para verificar que los recursos generados por el sistema son conformes al estándar y pueden ser consumidos correctamente por otras implementaciones. También se recomienda explorar la integración con sistemas de laboratorio clínico mediante el protocolo IHE (Integrating the Healthcare Enterprise), que especifica workflows de integración basados en FHIR para escenarios hospitalarios reales.

---

---

## REFERENCIAS BIBLIOGRÁFICAS

1. Health Level Seven International. (2019). *FHIR R4 Release 4 Specification*. HL7 International. Disponible en: https://www.hl7.org/fhir/R4/

2. Mandel, J. C., Kreda, D. A., Mandl, K. D., Kohane, I. S., & Ramoni, R. B. (2016). SMART on FHIR: a standards-based, interoperable apps platform for electronic health records. *Journal of the American Medical Informatics Association (JAMIA)*, 23(5), 899-908. https://doi.org/10.1093/jamia/ocv189

3. Lehne, M., Sass, J., Essenwanger, A., Schepers, J., & Thun, S. (2019). Why digital medicine depends on interoperability. *npj Digital Medicine*, 2(1), 1-5. https://doi.org/10.1038/s41746-019-0158-1

4. Hapifhir.io. (2024). *HAPI FHIR Documentation v8.6.1*. Smile Digital Health. Disponible en: https://hapifhir.io/hapi-fhir/docs/

5. Spring Framework. (2024). *Spring Boot Reference Documentation 3.5.x*. VMware Tanzu. Disponible en: https://docs.spring.io/spring-boot/docs/3.5.x/reference/html/

6. Google LLC. (2024). *Flutter Documentation*. Disponible en: https://docs.flutter.dev/

7. Organización Panamericana de la Salud. (2018). *Estrategia y Plan de Acción sobre eSalud 2016-2020*. OPS. Washington D.C.

8. Secretaría de Salud de México. (2012). *Norma Oficial Mexicana NOM-024-SSA3-2012: Sistemas de información de registro electrónico para la salud, intercambio de información en salud*. Diario Oficial de la Federación.

9. Fowler, M. (2002). *Patterns of Enterprise Application Architecture*. Addison-Wesley Professional.

10. Humble, J., & Farley, D. (2010). *Continuous Delivery: Reliable Software Releases through Build, Test, and Deployment Automation*. Addison-Wesley.

11. Beck, K., Beedle, M., van Bennekum, A., Cockburn, A., Cunningham, W., Fowler, M., ... & Thomas, D. (2001). *Manifesto for Agile Software Development*. Agile Alliance.

12. Sutherland, J., & Schwaber, K. (2020). *The Scrum Guide: The Definitive Guide to Scrum: The Rules of the Game*. Scrum.org.

13. OWASP Foundation. (2021). *OWASP Top 10 - 2021*. Open Web Application Security Project. Disponible en: https://owasp.org/www-project-top-ten/

14. openEHR Foundation. (2024). *openEHR Architecture Overview*. Disponible en: https://specifications.openehr.org/releases/AM/latest/

15. Docker Inc. (2024). *Docker Documentation*. Disponible en: https://docs.docker.com/

---

---

## ANEXOS

### Anexo A — Estructura del Repositorio de GitHub

```
Hospital-FHIR-System/
├── iniciar-sistema.bat         # Script inicio completo del sistema
├── iniciar-backend.bat         # Script inicio solo backend
├── iniciar-frontend.bat        # Script inicio solo frontend
├── detener-sistema.bat         # Script detención del sistema
├── COMO_USAR_SCRIPTS.md        # Guía de uso de scripts
├── README.md                   # Documentación principal
│
├── backend/
│   ├── src/main/java/ca/uhn/fhir/jpa/starter/
│   │   ├── Application.java
│   │   └── auth/
│   │       ├── controller/
│   │       │   ├── AuthController.java
│   │       │   └── UserController.java
│   │       ├── model/User.java
│   │       ├── repository/UserRepository.java
│   │       ├── service/
│   │       │   ├── AuthService.java
│   │       │   └── UserService.java
│   │       ├── security/JwtUtil.java
│   │       └── dto/
│   │           ├── LoginRequest.java
│   │           ├── SignupRequest.java
│   │           └── AuthResponse.java
│   ├── src/test/java/ca/uhn/fhir/jpa/starter/auth/
│   │   ├── AuthControllerTest.java     # 12 tests
│   │   └── UserControllerTest.java     # 11 tests
│   ├── docker-compose.yml
│   ├── pom.xml
│   ├── mvnw.cmd
│   └── README.md
│
└── frontend/
    ├── lib/
    │   ├── main.dart
    │   ├── config/api_config.dart
    │   ├── providers/auth_provider.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   └── fhir_service.dart
    │   ├── models/
    │   │   ├── patient.dart
    │   │   └── appointment.dart
    │   └── screens/
    │       ├── login_screen.dart
    │       ├── home_screen.dart
    │       └── patient_list_screen.dart
    ├── test/
    │   ├── auth_service_test.dart      # 12 tests
    │   ├── fhir_service_test.dart      # 11 tests
    │   └── widget_test.dart            # 2 tests
    ├── pubspec.yaml
    ├── update-ip.ps1
    └── README.md
```

### Anexo B — Comandos de Ejecución del Sistema

**Iniciar el sistema completo**:
```batch
.\iniciar-sistema.bat
```

**Ejecutar pruebas del backend**:
```batch
cd backend
.\mvnw.cmd test
```

**Ejecutar pruebas del frontend**:
```batch
cd frontend
flutter test
```

**Detener el sistema**:
```batch
.\detener-sistema.bat
```

**Actualizar IP de red para dispositivos móviles**:
```powershell
cd frontend
.\update-ip.ps1
```

### Anexo C — Principales Endpoints de la API

| Método | Endpoint | Descripción | Autenticación |
|---|---|---|---|
| POST | `/api/auth/signup` | Registro de nuevo usuario | No requerida |
| POST | `/api/auth/login` | Inicio de sesión | No requerida |
| GET | `/api/auth/validate` | Validación de token JWT | Bearer Token |
| GET | `/api/users` | Listado de usuarios | Bearer Token (Admin) |
| GET | `/fhir/metadata` | CapabilityStatement FHIR | No requerida |
| GET | `/fhir/Patient` | Búsqueda de pacientes | Bearer Token |
| POST | `/fhir/Patient` | Creación de paciente FHIR | Bearer Token |
| PUT | `/fhir/Patient/{id}` | Actualización de paciente | Bearer Token |
| DELETE | `/fhir/Patient/{id}` | Eliminación de paciente | Bearer Token |
| GET | `/fhir/Practitioner` | Búsqueda de médicos | Bearer Token |
| GET | `/fhir/Appointment` | Búsqueda de citas | Bearer Token |

### Anexo D — Credenciales del Entorno de Desarrollo

| Componente | Parámetro | Valor |
|---|---|---|
| Aplicación | Usuario administrador | `admin` |
| Aplicación | Contraseña | `admin123` |
| PostgreSQL | Base de datos | `fhirdb` |
| PostgreSQL | Usuario | `fhiruser` |
| PostgreSQL | Puerto | `5432` |
| Backend | Puerto | `8080` |
| Backend | Context path | `/fhir` |

> **Nota**: Las credenciales anteriores son exclusivamente para el entorno de desarrollo local. En un ambiente de producción deben ser reemplazadas por credenciales seguras y gestionadas mediante variables de entorno.

---

*Documento generado como parte del reporte de residencias profesionales.*
*Tecnológico Nacional de México — Ingeniería en Sistemas Computacionales*
*Periodo: Marzo 2026 — Agosto 2026*
