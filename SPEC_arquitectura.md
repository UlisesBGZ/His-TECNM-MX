# SPEC Arquitectura

## Proposito
Describir la arquitectura ejecutable del proyecto en formato corto para desarrollo, soporte e incorporacion de residentes.

## Referencia SDD
- Alineado con `backend/documentacion_tecnica/DOCUMENTACION_TECNICA_RESIDENCIA.md`.

## Stack arquitectonico y versiones
- Frontend: Flutter (objetivo 3.27.3) + Dart (objetivo 3.6.1).
- Backend: Spring Boot 3.5.9 + HAPI FHIR 8.6.1.
- Seguridad: JWT (JJWT 0.12.6) + BCrypt 0.4.
- Datos: PostgreSQL 16 + EHRbase (imagen `next`) con PostgreSQL 16.2 dedicado.
- Integracion openEHR: openEHR SDK 2.30.0.

## Vista de contenedores
- C1 Frontend: Flutter web (UI, estado, consumo de APIs).
- C2 Backend: Spring Boot + HAPI FHIR (logica, auth, FHIR, virtual EHR).
- C3 Datos FHIR/Auth: PostgreSQL 16.
- C4 Capa openEHR: EHRbase + PostgreSQL dedicado.

## Vista de capas (backend)
- Controller: expone `/api/auth`, `/api/users`, `/api/virtual-ehr` y `/fhir`.
- Service: reglas de negocio, autenticacion y orquestacion.
- Repository/Persistencia: acceso a datos y almacenamiento.
- Integracion: clientes FHIR/openEHR para flujo virtual EHR.

## Bloques principales
- Frontend:
  - Provider para estado de autenticacion.
  - Servicios HTTP para `/api/auth`, `/api/users`, `/fhir`, `/api/virtual-ehr`.
- Backend:
  - REST custom: auth y usuarios.
  - FHIR R4 server en `/fhir`.
  - Integracion con EHRbase para linkage de paciente.
- Persistencia:
  - PostgreSQL principal para backend FHIR/auth.
  - PostgreSQL secundario para EHRbase.

## Flujo principal de autenticacion
1. Frontend envia credenciales a `/api/auth/login`.
2. Backend emite JWT.
3. Frontend guarda token y lo envia en `Authorization: Bearer`.
4. Backend valida token/rol.
5. Se habilitan operaciones protegidas.

## Flujo virtual EHR
1. Frontend solicita alta unificada.
2. Backend crea Patient en FHIR.
3. Backend crea EHR en EHRbase.
4. Si falla EHRbase, aplica compensacion (rollback funcional de Patient).

## Decisiones de arquitectura
- Mantener API REST custom separada de API FHIR para simplificar seguridad y UX.
- Usar JWT stateless para evitar sesion servidor tradicional.
- Usar Docker Compose para reproducibilidad local.
- Aplicar compensacion en integraciones distribuidas para reducir inconsistencia funcional.

## Convenciones de despliegue
- Modo A: backend local + Docker para BD/EHRbase.
- Modo B: Docker completo.
- Regla: no mezclar modos (evita conflicto en 8080).
