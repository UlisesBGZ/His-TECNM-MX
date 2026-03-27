# SPEC Requisitos

## Proposito
Definir el alcance funcional y tecnico del MVP para residentes nuevos, mantenimiento e IA de soporte.

## Fuente de referencia
- Base tecnica alineada con `backend/documentacion_tecnica/DOCUMENTACION_TECNICA_RESIDENCIA.md` (SDD tecnico del proyecto).

## Tecnologias y versiones (baseline actual)
- Backend framework: Spring Boot 3.5.9.
- Motor interoperable: HAPI FHIR 8.6.1 (FHIR R4).
- Lenguaje backend: Java 17+ (recomendado 21 LTS para el equipo).
- Seguridad: JJWT 0.12.6 + jBCrypt 0.4.
- Persistencia SQL: PostgreSQL 16 (`postgres:16-alpine`).
- Integracion openEHR: openEHR SDK 2.30.0 + EHRbase (`ehrbase/ehrbase:next`).
- Cliente frontend: Flutter (objetivo documentado: 3.27.3) + Dart (objetivo: 3.6.1; pubspec permite `>=3.0.0 <4.0.0`).
- Estado frontend: Provider ^6.1.1.
- Cliente HTTP frontend: http ^1.2.0.
- Infra local: Docker + Docker Compose.

## Requisitos funcionales (MVP)
- RF-01: Iniciar sesion con JWT.
- RF-02: Control de acceso por rol (Admin, Usuario).
- RF-03: Administracion de usuarios (listar, eliminar, activar/desactivar) para Admin.
- RF-04: Gestion clinica sobre recursos FHIR R4 (Patient, Practitioner, Appointment, Observation).
- RF-05: Operacion desde frontend Flutter web.
- RF-06: Orquestacion virtual EHR (creacion paciente FHIR + vinculo EHRbase).

## Requisitos no funcionales
- RNF-01 Interoperabilidad: API compatible con HL7 FHIR R4.
- RNF-02 Seguridad: JWT + BCrypt + validacion de permisos por endpoint.
- RNF-03 Persistencia: PostgreSQL 16 para FHIR/Auth y PostgreSQL dedicado para EHRbase.
- RNF-04 Portabilidad: ejecucion en Docker Compose (modo completo o servicios base).
- RNF-05 Mantenibilidad: separacion por capas/modulos y documentacion operativa.

## Criterios minimos de cumplimiento
- RF-01/RF-02: login valido devuelve token y restringe rutas por rol.
- RF-03: endpoints de usuarios responden solo para admin.
- RF-04: recursos FHIR disponibles en `/fhir`.
- RF-06: alta unificada retorna identificadores FHIR/EHR o error controlado.
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
