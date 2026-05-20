# Arquitectura de Integración — Sistema Hospitalario La Clemencia

**Proyecto**: Residencia Profesional — Ingeniería en Sistemas  
**Autor**: Ulises Bedolla González  
**Última actualización**: Mayo 2026  

---

## Stack tecnológico (versiones en producción)

| Componente | Tecnología | Versión |
|---|---|---|
| Frontend | Flutter / Dart | 3.27.3 / 3.6.1 |
| Estado frontend | Provider | 6.1.1 |
| HTTP frontend | http (Dart) | 1.2.0 |
| Backend framework | Spring Boot | 3.5.9 |
| Motor FHIR | HAPI FHIR JPA Server | 8.6.1 |
| Estándar clínico | HL7 FHIR R4 | R4 |
| Integración openEHR | openEHR SDK | 2.30.0 |
| Servidor openEHR | EHRbase | 2.6.0 |
| Seguridad | JJWT + jBCrypt | 0.12.6 / 0.4 |
| Base de datos FHIR/Auth | PostgreSQL | 16 (postgres:16-alpine) |
| Base de datos EHRbase | PostgreSQL especializado | ehrbase/ehrbase-v2-postgres:16.2 |
| Infraestructura local | Docker + Docker Compose | — |

---

## Puertos operativos

| Puerto | Servicio |
|---|---|
| 8080 | Backend Spring Boot (FHIR + /api/auth + /api/users + virtual EHR) |
| 8081 | EHRbase (API openEHR REST) |
| 5432 | PostgreSQL — datos FHIR y autenticación |
| 5434 | PostgreSQL — datos clínicos EHRbase |

---

## Visión general de la arquitectura

El sistema está compuesto por cuatro capas principales que se comunican en cadena. El frontend Flutter se conecta exclusivamente al backend Spring Boot. El backend Spring Boot actúa como orquestador y se comunica con dos sistemas de persistencia independientes: HAPI FHIR para los datos administrativos y demográficos, y EHRbase para los datos clínicos estructurados bajo el estándar openEHR. Cada sistema de persistencia tiene su propia base de datos PostgreSQL aislada.

```
Flutter App
    │
    │  HTTP + JWT (puerto 8080)
    ▼
Spring Boot (HAPI FHIR JPA Server)
    │                    │
    │ FHIR R4 JPA        │ openEHR SDK / REST
    ▼                    ▼
PostgreSQL:5432     EHRbase:8081
(FHIR + Auth)           │
                         │ JDBC
                         ▼
                    PostgreSQL:5434
                    (EHRbase)
```

---

## Archivos clave por capa

### Frontend

| Archivo | Responsabilidad |
|---|---|
| `frontend/lib/services/fhir_service.dart` | Única clase que realiza todas las llamadas HTTP al backend. Gestiona el token JWT y detecta la plataforma (web/móvil) para usar la URL correcta. |
| `frontend/lib/screens/encounter_form_screen.dart` | Pantalla de registro de encuentro clínico. Dispara el guardado FHIR y la escritura dual a EHRbase. |
| `frontend/lib/screens/antecedent_form_dialog.dart` | Diálogo de captura de antecedentes. Envía los datos a FHIR y a EHRbase según el tipo de antecedente. |
| `frontend/lib/screens/patient_form_screen.dart` | Formulario de registro de paciente nuevo. |
| `frontend/lib/screens/patient_clinical_view_screen.dart` | Vista del expediente clínico completo del paciente. |
| `frontend/lib/screens/encounter_list_screen.dart` | Lista de encuentros clínicos con filtros por estado. |

### Backend — Controlador

| Archivo | Responsabilidad |
|---|---|
| `backend/.../virtualehr/controller/VirtualEhrPatientController.java` | Único punto de entrada REST para el flujo virtual EHR. Expone todos los endpoints bajo `/api/virtual-ehr/patients`. |

### Backend — Servicios

| Archivo | Responsabilidad |
|---|---|
| `backend/.../virtualehr/service/PatientOrchestratorService.java` | Orquesta la creación del paciente: crea el recurso Patient en FHIR y el EHR en EHRbase, vinculando ambos IDs. |
| `backend/.../virtualehr/service/EhrbaseCompositionService.java` | Construye y envía composiciones de tipo `consulta_clinica` (encuentros clínicos) a EHRbase. |
| `backend/.../virtualehr/service/EhrbaseAntecedentesService.java` | Construye y envía composiciones de tipo `antecedentes_clinicos` (heredofamiliar, no patológico, gineco-obstétrico) a EHRbase. |
| `backend/.../virtualehr/service/FullPatientRecordService.java` | Agrega datos de FHIR y EHRbase en un solo DTO para el expediente completo del paciente. Ejecuta consultas AQL contra EHRbase. |
| `backend/.../virtualehr/config/EhrbaseTemplateUploader.java` | Carga automáticamente los templates openEHR (.opt) en EHRbase al iniciar el servidor. |

### DTOs de comunicación

| DTO | Uso |
|---|---|
| `CreatePatientRequestDto` | Datos del paciente nuevo desde Flutter. |
| `SaveEncounterCompositionRequestDto` | Datos del encuentro clínico para EHRbase (incluye ehrId, signos vitales, diagnóstico). |
| `SaveAntecedentesCompositionRequestDto` | Datos del antecedente clínico para EHRbase (ehrId, tipo, contenido). |
| `FullPatientRecordResponseDto` | Respuesta unificada con datos demográficos (FHIR) + consultas + antecedentes (EHRbase). |

---

## Endpoints REST del sistema

### Autenticación (`/api/auth`)

```
POST /api/auth/login       — Inicio de sesión, devuelve JWT
POST /api/auth/signup      — Registro de usuario nuevo
POST /api/auth/admin       — Creación de cuenta administrador
```

### Virtual EHR (`/api/virtual-ehr/patients`)

```
POST   /api/virtual-ehr/patients                              — Crear paciente (FHIR + EHRbase)
GET    /api/virtual-ehr/patients/{id}/linkage                 — Verificar vínculo FHIR–EHRbase
POST   /api/virtual-ehr/patients/{id}/ehr-composition         — Guardar encuentro en EHRbase
POST   /api/virtual-ehr/patients/{id}/antecedentes-composition — Guardar antecedente en EHRbase
GET    /api/virtual-ehr/patients/{id}/full-record             — Expediente completo (FHIR + AQL)
```

### FHIR R4 (`/fhir`)

```
GET/POST /fhir/Patient        — Recursos de paciente
GET/POST /fhir/Encounter      — Encuentros clínicos
GET/POST /fhir/Practitioner   — Médicos/practicantes
GET/POST /fhir/Appointment    — Citas
GET/POST /fhir/MedicationRequest — Recetas médicas
```

---

## Flujo completo: Registro de paciente

1. El médico completa el formulario en `patient_form_screen.dart` y presiona "Guardar".
2. `FhirService.createPatient()` hace un `POST /api/virtual-ehr/patients` con los datos demográficos.
3. `VirtualEhrPatientController.createPatient()` recibe la petición y llama a `PatientOrchestratorService.createUnifiedPatientRecord()`.
4. El orquestador crea un recurso `Patient` en HAPI FHIR mediante `IGenericClient`. HAPI FHIR lo persiste en PostgreSQL:5432.
5. El orquestador llama a la REST API de EHRbase en el puerto 8081 para crear un EHR vacío. EHRbase devuelve un UUID (ehrId).
6. El orquestador actualiza el recurso `Patient` en FHIR agregando el ehrId como extensión personalizada con URL `http://hospital.com/fhir/StructureDefinition/ehr-id`.
7. El controlador devuelve un `UnifiedPatientRecordResponseDto` con los IDs de FHIR y EHRbase al frontend.

---

## Flujo completo: Registro de encuentro clínico (escritura dual)

1. El médico completa el formulario en `encounter_form_screen.dart` con motivo, diagnóstico y signos vitales.
2. `FhirService` hace un `POST /fhir/Encounter` con el recurso Encounter en formato FHIR R4. HAPI FHIR lo persiste en PostgreSQL:5432.
3. `FhirService` hace un segundo `POST /api/virtual-ehr/patients/{id}/ehr-composition` con el cuerpo `{ehrId, fhirEncounterId, motivoConsulta, diagnostico, signosVitales}`.
4. `VirtualEhrPatientController.saveEncounterComposition()` recibe la petición y llama a `EhrbaseCompositionService.saveConsultaClinica()`.
5. El servicio construye un objeto `ConsultaClinicaComposition` usando las clases generadas por el SDK openEHR a partir del template `consulta_clinica.opt`, que sigue el archetype `openEHR-EHR-COMPOSITION.encounter.v1`. Cada signo vital se mapea a su nodo correspondiente: `BloodPressureObservation`, `PulseHeartBeatObservation`, `BodyTemperatureObservation`, `BodyWeightObservation`, `HeightLengthObservation`, `RespirationObservation`.
6. El cliente `OpenEhrClient.compositionEndpoint(ehrId).mergeCompositionEntity(composition)` envía la composición a EHRbase en el puerto 8081.
7. EHRbase valida la composición contra el template registrado y la persiste en PostgreSQL:5434.
8. El servicio devuelve el ID de la composición generado por EHRbase. El controlador lo envuelve en un `CompositionResponseDto` y responde al frontend con HTTP 201.

---

## Flujo completo: Registro de antecedente clínico (escritura dual)

1. El médico abre el diálogo en `antecedent_form_dialog.dart`, selecciona el tipo de antecedente y escribe el contenido.
2. `FhirService` actualiza el recurso `Patient` en FHIR con el texto del antecedente.
3. `FhirService` hace un `POST /api/virtual-ehr/patients/{id}/antecedentes-composition` con `{ehrId, tipoAntecedente, contenido}`.
4. `VirtualEhrPatientController.saveAntecedentesComposition()` delega a `EhrbaseAntecedentesService.saveAntecedente()`.
5. El servicio construye un `AntecedentesClinicosComposition` bajo el archetype `openEHR-EHR-COMPOSITION.health_summary.v1`. Según el tipo recibido popula el nodo correspondiente: `FamilyHistorySummaryEvaluation` (HEREDOFAMILIAR), `SocialSummaryEvaluation` (NO_PATOLOGICO) u `ObstetricSummaryEvaluation` (GINECO_OBSTETRICO).
6. El cliente `OpenEhrClient` envía la composición a EHRbase, que la persiste en PostgreSQL:5434.

---

## Flujo completo: Consulta del expediente clínico (lectura dual)

1. El médico navega al expediente del paciente desde `patient_clinical_view_screen.dart`.
2. `FhirService` hace un `GET /api/virtual-ehr/patients/{id}/full-record`.
3. `FullPatientRecordService.getFullRecord()` lee el recurso `Patient` de HAPI FHIR usando `IGenericClient` para obtener los datos demográficos y recuperar el ehrId de la extensión personalizada.
4. Con el ehrId construye dos consultas AQL y las envía a EHRbase vía HTTP POST a `/rest/openehr/v1/query/aql` con autenticación Basic:
   - Consulta de encuentros: filtra composiciones `openEHR-EHR-COMPOSITION.encounter.v1` ordenadas por fecha descendente.
   - Consulta de antecedentes: filtra composiciones `openEHR-EHR-COMPOSITION.health_summary.v1`.
5. EHRbase ejecuta las consultas AQL sobre PostgreSQL:5434 y devuelve los resultados en formato JSON con estructura de filas y columnas.
6. `FullPatientRecordService` mapea cada fila a objetos `ConsultaDto` y `AntecedentesDto` y los ensambla en un `FullPatientRecordResponseDto`.
7. El controlador devuelve el DTO completo al frontend, que lo muestra en la vista del expediente.

---

## Templates openEHR registrados en EHRbase

| Template ID | Archetype base | Uso |
|---|---|---|
| `consulta_clinica` | `openEHR-EHR-COMPOSITION.encounter.v1` | Encuentros clínicos con signos vitales, motivo y diagnóstico |
| `antecedentes_clinicos` | `openEHR-EHR-COMPOSITION.health_summary.v1` | Antecedentes heredofamiliares, no patológicos y gineco-obstétricos |

Los archivos `.opt` de estos templates se encuentran en `backend/src/main/resources/openehr/templates/` y son cargados automáticamente al iniciar el servidor por `EhrbaseTemplateUploader.java`.

---

## Mecanismo de autenticación

El sistema usa JWT (JSON Web Token) sin Spring Security. Al iniciar sesión, el backend genera un token firmado con JJWT 0.12.6 usando una clave secreta configurada en `application.yaml`. El token se almacena en `SharedPreferences` del dispositivo Flutter. En cada petición posterior, `FhirService` recupera el token y lo agrega en el encabezado `Authorization: Bearer <token>`. El backend valida el token en un filtro de autenticación antes de procesar la petición. Las contraseñas se almacenan en PostgreSQL hasheadas con jBCrypt 0.4.

---

## Separación de responsabilidades por base de datos

| Tipo de dato | Sistema | Base de datos |
|---|---|---|
| Datos demográficos del paciente (nombre, CURP, teléfono, dirección, tipo de sangre) | HAPI FHIR | PostgreSQL:5432 |
| Credenciales de usuarios y tokens | Auth propio | PostgreSQL:5432 |
| Encuentros clínicos estructurados (signos vitales, diagnóstico, motivo) | EHRbase | PostgreSQL:5434 |
| Antecedentes clínicos (heredofamiliares, no patológicos, gineco-obstétricos) | EHRbase | PostgreSQL:5434 |
| Vínculo FHIR–EHRbase (ehrId como extensión del Patient) | HAPI FHIR | PostgreSQL:5432 |
