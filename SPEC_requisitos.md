# SPEC Requisitos

## Objetivo
Documentar que necesita el sistema para ejecutarse y que funcionalidades cubre.

## Requisitos funcionales (actuales)
- Autenticacion de usuarios con JWT.
- Roles de acceso: Admin y Usuario.
- Gestion de usuarios (listar, eliminar, activar/desactivar) para Admin.
- Gestion clinica usando recursos FHIR R4 (Patient, Practitioner, Appointment, Observation).
- Frontend web para operacion diaria hospitalaria.
- Integracion de virtual EHR con EHRbase para orquestacion de pacientes.

## Requisitos no funcionales
- Interoperabilidad: HL7 FHIR R4.
- Seguridad: JWT + validacion de token + hashing de passwords (BCrypt).
- Persistencia: PostgreSQL 16.
- Portabilidad: Docker Compose para servicios base.
- Mantenibilidad: separacion backend/frontend y documentacion de arranque.

## Requisitos tecnicos minimos
- Docker Desktop (para BD y servicios auxiliares).
- Java 17+ (recomendado 21 en entorno local del proyecto).
- Flutter SDK 3.x.
- Navegador Chrome.

## Nota de version de Java
- Version recomendada para el equipo: Java 21 LTS (base estable de desarrollo).

## Puertos usados
- 8080: Backend HAPI FHIR + API auth/users.
- 8081: EHRbase.
- 5432: PostgreSQL FHIR.
- 5434: PostgreSQL EHRbase.
