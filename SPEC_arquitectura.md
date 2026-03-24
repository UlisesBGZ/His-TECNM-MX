# SPEC Arquitectura

## Vista general
Arquitectura modular con 2 bloques principales:
- Backend Java (Spring Boot + HAPI FHIR).
- Frontend Flutter (web/android).

## Componentes
- Frontend:
  - UI en Flutter.
  - Estado con Provider.
  - Servicios HTTP para auth, users y FHIR.
- Backend:
  - API REST personalizada (/api/auth, /api/users).
  - Servidor FHIR R4 en /fhir.
  - Capa auth JWT propia (sin Spring Security clasico).
  - Integracion virtual EHR con EHRbase.
- Datos:
  - PostgreSQL para persistencia principal.
  - EHRbase + su PostgreSQL dedicado para openEHR.

## Flujo principal
1. Usuario inicia sesion en frontend.
2. Backend emite JWT.
3. Frontend guarda token y lo envia como Bearer.
4. Backend valida token y rol.
5. Operaciones de negocio/FHIR se ejecutan.

## Convenciones de despliegue
- Modo A: backend local + Docker para BD/EHRbase.
- Modo B: Docker completo.
- No mezclar modos para evitar conflicto de puerto 8080.
