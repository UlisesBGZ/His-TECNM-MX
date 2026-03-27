# SPEC Spring

## Proposito
Definir el alcance del backend Spring/HAPI y sus reglas operativas para desarrollo y mantenimiento.

## Stack base
- Spring Boot 3.5.9.
- HAPI FHIR 8.6.1 (FHIR R4).
- Java 17+ (recomendado 21 LTS).
- Maven Wrapper (build local sin Maven global).
- PostgreSQL driver 42.7.9 + motor PostgreSQL 16.
- JWT: JJWT 0.12.6 (`jjwt-api`, `jjwt-impl`, `jjwt-jackson`).
- Hash de password: jBCrypt 0.4.
- openEHR SDK 2.30.0.

## Modulos
- `auth`: login, signup, create-admin, validate token.
- `users`: administracion de usuarios por rol admin.
- `fhir`: endpoints estandar FHIR en `/fhir`.
- `virtualehr`: orquestacion FHIR + EHRbase.

## Superficie API
- `/api/auth`
- `/api/users`
- `/fhir`
- `/api/virtual-ehr`

## Reglas backend
- Endpoints REST custom devuelven JSON.
- Endpoints protegidos requieren `Authorization: Bearer`.
- Operaciones administrativas requieren rol admin.
- En virtual EHR, aplicar compensacion ante falla parcial.
- CORS habilitado para consumo desde frontend web.

## Ejecucion
- Run (Windows): `.\mvnw.cmd spring-boot:run -Pboot`.
- Tests: `.\mvnw.cmd test`.

## Integracion infraestructura
- Docker Compose para PostgreSQL FHIR/Auth + EHRbase + PostgreSQL EHRbase.
- Variables de entorno para URLs, credenciales y JWT secret/expiracion.

## Calidad minima esperada
- Compilacion sin errores.
- Tests unitarios en verde.
- Health de servicios dependientes operativo antes de pruebas funcionales.

## Criterios de aceptacion tecnicos
- CA-SPR-01: login retorna JWT valido y claims esperados.
- CA-SPR-02: `/api/users` bloquea acceso sin rol admin.
- CA-SPR-03: `/fhir/metadata` responde correctamente.
- CA-SPR-04: flujo virtual EHR crea linkage o compensa ante falla.
