# SPEC Spring

## Stack
- Spring Boot 3.5.9
- HAPI FHIR 8.6.1
- Maven Wrapper
- PostgreSQL
- JWT (JJWT) + BCrypt

## Modulos principales
- auth:
  - login/signup/create-admin/validate token
  - servicio de usuarios y roles
- users:
  - endpoints administrativos protegidos por rol admin
- fhir:
  - servidor FHIR R4 bajo /fhir
- virtualehr:
  - orquestacion con EHRbase/openEHR

## API base
- /api/auth
- /api/users
- /fhir
- /api/virtual-ehr

## Reglas backend
- Respuestas en JSON en endpoints REST custom.
- Validacion de token Bearer antes de operaciones protegidas.
- Restriccion por rol en endpoints de administracion.

## Ejecucion
- Windows: .\mvnw.cmd spring-boot:run -Pboot
- Tests: .\mvnw.cmd test

## Integracion infraestructura
- docker-compose para Postgres FHIR, EHRbase y Postgres EHRbase.
- Variables de entorno para URLs/credenciales entre servicios.
