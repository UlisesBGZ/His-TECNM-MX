# SPEC Requisitos

## Proposito
Definir el alcance funcional y tecnico del MVP para residentes nuevos, mantenimiento e IA de soporte.

## Base starter
- Este documento se mantiene alineado con el backend HAPI FHIR JPA Starter usado por el proyecto.
- Superficie base del starter: `/api/auth`, `/api/users`, `/fhir` y flujo virtual EHR sobre el mismo backend.
- El alcance del MVP agrega extensiones sobre esa base sin contradecirla.

## Fuente de referencia
- Base tecnica alineada con `backend/documentacion_tecnica/DOCUMENTACION_TECNICA_RESIDENCIA.md` (SDD tecnico del proyecto).

## Tecnologias y versiones (baseline actual)
- Backend framework: Spring Boot 3.5.9.
- Motor interoperable: HAPI FHIR 8.6.1 (FHIR R4).
- Lenguaje backend: Java 17+ (recomendado 21 LTS para el equipo).
- Seguridad: JJWT 0.12.6 + jBCrypt 0.4.
- Persistencia SQL: PostgreSQL 16 (`postgres:16-alpine`).
- Integracion openEHR: openEHR SDK 2.30.0 + EHRbase 2.6.0 (`ehrbase/ehrbase:2.6.0`) + PostgreSQL EHRbase (`ehrbase/ehrbase-v2-postgres:16.2`).
- Cliente frontend: Flutter (objetivo documentado: 3.27.3) + Dart (objetivo: 3.6.1; pubspec permite `>=3.0.0 <4.0.0`).
- Estado frontend: Provider ^6.1.1.
- Cliente HTTP frontend: http ^1.2.0.
- Infra local: Docker + Docker Compose.

## Requisitos funcionales base del starter
- RF-01: Iniciar sesion con JWT.
- RF-02: Control de acceso por rol (Admin, Usuario).
- RF-03: Administracion de usuarios (listar, eliminar, activar/desactivar) para Admin.
- RF-04: Gestion clinica sobre recursos FHIR R4 (Patient, Practitioner, Appointment, Observation).
- RF-05: Operacion desde frontend Flutter web.

## Extensiones del MVP sobre el starter
- RF-06: Registro universal de pacientes, independiente del medico tratante.
- RF-07: Orquestacion virtual EHR (creacion paciente FHIR + vinculo EHRbase).
- RF-08: Creacion y seguimiento de encuentros con estatus pendiente, activa y finalizada.
- RF-09: Captura de antecedentes demograficos y clinicos base conforme a las pantallas aprobadas.

## Alcance minimo de captura del paciente
- Identificacion: CURP o identificador institucional.
- Datos personales: nombre(s), apellido paterno, apellido materno, sexo y fecha de nacimiento.
- Contacto: telefono, correo electronico y direccion.
- Datos clinicos base: tipo de sangre y antecedentes clinicos relevantes.
- Antecedentes clinicos generales.

## Requisitos no funcionales
- RNF-01 Interoperabilidad: API compatible con HL7 FHIR R4.
- RNF-02 Seguridad: JWT + BCrypt + validacion de permisos por endpoint.
- RNF-03 Persistencia: PostgreSQL 16 para FHIR/Auth y PostgreSQL dedicado para EHRbase.
- RNF-04 Portabilidad: ejecucion en Docker Compose (modo completo o servicios base).
- RNF-05 Mantenibilidad: separacion por capas/modulos y documentacion operativa.
- RNF-06 Cumplimiento normativo: campos de captura alineados a la NOM-024-SSA3-2012 para expediente clinico electronico.
- RNF-07 Trazabilidad de receta: toda prescripcion debe conservar fecha, prescriptor y estado de ciclo de vida.

## Reglas de negocio criticas
- RB-01: Un paciente existe una sola vez en el sistema y puede ser consultado por cualquier especialista autorizado.
- RB-02: Un paciente no pertenece a un solo doctor; pertenece al expediente institucional.
- RB-03: Todo encuentro debe tener un estado definido y visible.
- RB-04: Los datos clinicos viven en EHRbase; los datos estructurados/demograficos viven en FHIR.
- RB-05: El ID generado por EHRbase debe vincularse al paciente FHIR dentro del flujo virtual EHR.
- RB-06: Los formularios deben separar datos demograficos, contacto y antecedentes generales.

## Criterios minimos de cumplimiento
- RF-01/RF-02: login valido devuelve token y restringe rutas por rol.
- RF-03: endpoints de usuarios responden solo para admin.
- RF-04: recursos FHIR disponibles en `/fhir`.
- RF-06/RF-07: alta unificada retorna identificadores FHIR/EHR o error controlado.
- RF-08: encuentros no pueden quedar sin estado.
- RF-09: la captura respeta el formato definido por el arquetipo y la NOM-024-SSA3-2012.
- RNF-02: password no se almacena en texto plano; token obligatorio en rutas protegidas.

## Requisitos tecnicos minimos
- Docker Desktop.
- Java 17+ (recomendado 21 LTS para el equipo).
- Flutter SDK 3.x.
- Chrome (frontend web).

## Puertos operativos
- 8080: Backend (FHIR + `/api/auth` + `/api/users` + virtual EHR).
- 8081: EHRbase.
- 5432: PostgreSQL FHIR/Auth.
- 5434: PostgreSQL EHRbase.

## Fuera de alcance (MVP)
- Alta disponibilidad en cluster.
- Escalado horizontal automatico.
- Integracion con HIS externo productivo.
