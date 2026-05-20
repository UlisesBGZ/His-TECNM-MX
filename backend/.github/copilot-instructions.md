# GitHub Copilot — Instrucciones del Proyecto

## Contexto del Proyecto

**Proyecto**: Sistema de Gestión Hospitalaria — La Clemencia  
**Estado**: Funcional (MVP activo)  
**Stack**: Spring Boot 3.5.9 + HAPI FHIR 8.6.1 + EHRbase 2.6.0 + Flutter 3.27.3 + PostgreSQL 16

## Arquitectura

El sistema implementa escritura dual: los datos demográficos viven en HAPI FHIR (PostgreSQL:5432) y los datos clínicos estructurados viven en EHRbase (PostgreSQL:5434). El frontend Flutter se conecta exclusivamente al backend Spring Boot.

```
Flutter App  →  Spring Boot :8080  →  PostgreSQL :5432  (FHIR + Auth)
                                   →  EHRbase    :8081  →  PostgreSQL :5434
```

## Estructura Clave del Backend

```
src/main/java/ca/uhn/fhir/jpa/starter/
├── auth/
│   ├── controller/AuthController.java      # POST /api/auth/login, /signup, /admin
│   ├── controller/UserController.java      # CRUD usuarios (solo admin)
│   ├── model/User.java
│   ├── repository/UserRepository.java
│   ├── service/AuthService.java
│   └── security/JwtUtil.java
└── virtualehr/
    ├── controller/VirtualEhrPatientController.java  # /api/virtual-ehr/patients
    ├── service/PatientOrchestratorService.java      # Crea FHIR Patient + EHR
    ├── service/EhrbaseCompositionService.java       # Guarda encuentros en EHRbase
    ├── service/EhrbaseAntecedentesService.java      # Guarda antecedentes en EHRbase
    ├── service/FullPatientRecordService.java        # Agrega FHIR + AQL EHRbase
    ├── config/EhrbaseTemplateUploader.java          # Carga .opt al iniciar
    └── dto/  (CreatePatientRequestDto, SaveEncounterCompositionRequestDto, etc.)
```

## Estructura Clave del Frontend

```
frontend/lib/
├── config/api_config.dart
├── services/fhir_service.dart          # Todos los llamados HTTP (JWT incluido)
├── providers/auth_provider.dart
└── screens/
    ├── login_screen.dart
    ├── home_screen.dart
    ├── patient_list_screen.dart
    ├── patient_form_screen.dart
    ├── patient_clinical_view_screen.dart   # Expediente clínico completo
    ├── encounter_list_screen.dart
    ├── encounter_form_screen.dart
    └── antecedent_form_dialog.dart
```

## Endpoints Principales

```
POST /api/auth/login                                       — Login, devuelve JWT
POST /api/auth/signup                                      — Registro de usuario

POST   /api/virtual-ehr/patients                           — Crear paciente (FHIR + EHRbase)
GET    /api/virtual-ehr/patients/{id}/linkage              — Verificar vínculo FHIR–EHRbase
POST   /api/virtual-ehr/patients/{id}/ehr-composition      — Guardar encuentro en EHRbase
POST   /api/virtual-ehr/patients/{id}/antecedentes-composition — Guardar antecedente
GET    /api/virtual-ehr/patients/{id}/full-record          — Expediente completo

GET/POST /fhir/Patient      — Recursos FHIR R4 estándar
GET/POST /fhir/Encounter
```

## Credenciales de Desarrollo

- **Admin**: `admin` / `admin123`
- **BD FHIR**: `admin` / `admin` (localhost:5432/fhirdb)
- **EHRbase**: `ehrbase` / `ehrbase` (localhost:8081)

## Puertos Operativos

- 8080: Backend Spring Boot
- 8081: EHRbase
- 5432: PostgreSQL (FHIR + Auth)
- 5434: PostgreSQL (EHRbase)

## Inicio del Sistema

El sistema se inicia **exclusivamente** con los scripts `.bat` en la raíz del proyecto:

```
.\iniciar-backend.bat   # Inicia Docker Compose + Spring Boot
.\detener-sistema.bat   # Detiene todo
```

**Nunca ejecutar** `.\mvnw.cmd spring-boot:run` directamente.

## Notas al Desarrollar

- El `ehrId` del paciente se almacena como extensión FHIR con URL `http://hospital.com/fhir/StructureDefinition/ehr-id`
- Los templates openEHR (.opt) están en `src/main/resources/openehr/templates/` y se cargan automáticamente
- JWT: sin Spring Security; validación manual en filtro de autenticación
- Las contraseñas se almacenan hasheadas con jBCrypt 0.4

## Documentación

- `backend/documentacion_tecnica/ARQUITECTURA_INTEGRACION.md` — Arquitectura detallada con flujos completos
- `SPEC_requisitos.md` — Requisitos funcionales del MVP
- `SPEC_arquitectura.md` — Decisiones de arquitectura
- `postman/CONSULTAS_EHRBASE.md` — Guía de consultas AQL a EHRbase
