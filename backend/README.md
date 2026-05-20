# Backend - Sistema Hospitalario La Clemencia

Backend basado en **HAPI FHIR 8.6.1** + **EHRbase 2.6.0** con autenticación JWT personalizada.

## Stack Tecnológico

- **Framework**: Spring Boot 3.5.9
- **FHIR Server**: HAPI FHIR 8.6.1 (HL7 FHIR R4)
- **Servidor openEHR**: EHRbase 2.6.0 + openEHR SDK 2.30.0
- **Java**: 21 (mínimo 17)
- **Build Tool**: Maven Wrapper 3.3.2 (incluido, NO requiere instalación global)
- **BD FHIR/Auth**: PostgreSQL 16 (puerto 5432)
- **BD EHRbase**: ehrbase/ehrbase-v2-postgres:16.2 (puerto 5434)
- **Autenticación**: JWT (JJWT 0.12.6) + jBCrypt 0.4

## Arquitectura

```
Flutter App
    │  HTTP + JWT (:8080)
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
                    (Datos clínicos)
```

**Separación de datos**:
- **FHIR/Auth (5432)**: datos demográficos del paciente, credenciales de usuarios
- **EHRbase (5434)**: encuentros clínicos, antecedentes, signos vitales

## Estructura del Código

```
backend/
├── src/main/java/ca/uhn/fhir/jpa/starter/
│   ├── Application.java
│   ├── auth/                                # Autenticación JWT personalizada
│   │   ├── controller/
│   │   │   ├── AuthController.java          # POST /api/auth/login, /signup, /admin
│   │   │   └── UserController.java          # GET/PUT/DELETE /api/users/*
│   │   ├── service/AuthService.java
│   │   ├── repository/UserRepository.java
│   │   ├── model/User.java
│   │   └── util/JwtUtil.java
│   └── virtualehr/                          # Integración FHIR + EHRbase
│       ├── controller/
│       │   └── VirtualEhrPatientController.java  # /api/virtual-ehr/patients
│       ├── service/
│       │   ├── PatientOrchestratorService.java   # Alta unificada (FHIR + EHRbase)
│       │   ├── EhrbaseCompositionService.java    # Encuentros → EHRbase
│       │   ├── EhrbaseAntecedentesService.java   # Antecedentes → EHRbase
│       │   └── FullPatientRecordService.java     # Agrega FHIR + AQL EHRbase
│       ├── config/
│       │   └── EhrbaseTemplateUploader.java      # Carga .opt al arrancar
│       └── dto/
│           ├── CreatePatientRequestDto.java
│           ├── SaveEncounterCompositionRequestDto.java
│           ├── SaveAntecedentesCompositionRequestDto.java
│           └── FullPatientRecordResponseDto.java
│
├── src/main/resources/
│   ├── application.yaml
│   └── openehr/templates/                   # Templates .opt (consulta_clinica, antecedentes)
│
├── docker-compose.yml                       # PostgreSQL FHIR + EHRbase + PostgreSQL EHRbase
├── pom.xml
└── mvnw.cmd
```

## Inicio Rápido

Usar el script de arranque en la raíz del proyecto:

```powershell
.\iniciar-backend.bat
```

Este script levanta Docker Compose (PostgreSQL FHIR + EHRbase + PostgreSQL EHRbase) y luego inicia Spring Boot. Al arrancar, `EhrbaseTemplateUploader` carga los templates openEHR en EHRbase automáticamente.

El servidor estará disponible en: **http://localhost:8080**  
EHRbase Swagger UI: **http://localhost:8081/ehrbase/swagger-ui/index.html**

### 3. Verificar que Funciona

```powershell
# Probar endpoint FHIR
curl http://localhost:8080/fhir/metadata

# Probar autenticación (debe dar error sin token)
curl http://localhost:8080/api/auth/validate
```

## API Endpoints

### Autenticación (`/api/auth`)

- `POST /api/auth/login` — Login, devuelve JWT
- `POST /api/auth/signup` — Registro de usuario
- `GET /api/auth/validate` — Validar token (Header: `Authorization: Bearer <token>`)
- `POST /api/auth/admin` — Crear cuenta administrador

### Gestión de Usuarios (`/api/users`) — Solo ADMIN

- `GET /api/users` — Listar todos los usuarios
- `GET /api/users/{id}` — Obtener usuario por ID
- `DELETE /api/users/{id}` — Eliminar usuario
- `PUT /api/users/{id}/toggle-status` — Habilitar/Deshabilitar usuario

### Virtual EHR (`/api/virtual-ehr/patients`)

- `POST /api/virtual-ehr/patients` — Crear paciente (FHIR + EHRbase simultáneo)
- `GET /api/virtual-ehr/patients/{id}/linkage` — Verificar vínculo FHIR–EHRbase
- `POST /api/virtual-ehr/patients/{id}/ehr-composition` — Guardar encuentro clínico en EHRbase
- `POST /api/virtual-ehr/patients/{id}/antecedentes-composition` — Guardar antecedente en EHRbase
- `GET /api/virtual-ehr/patients/{id}/full-record` — Expediente completo (FHIR + AQL EHRbase)

### FHIR R4 (`/fhir`)

- `GET/POST /fhir/Patient` — Recursos de paciente
- `GET/POST /fhir/Encounter` — Encuentros clínicos
- `GET/POST /fhir/Observation` — Observaciones

## Testing

### Ejecutar Todos los Tests

```powershell
.\mvnw.cmd test
```

**Tests disponibles:**
- **AuthControllerTest**: 12 tests (login, signup, validación, etc.)
- **UserControllerTest**: 11 tests (CRUD, permisos, toggle status)
- **Total**: 23 tests pasando ✅

### Ejecutar Tests Específicos

```powershell
# Solo tests de autenticación
.\mvnw.cmd test -Dtest=AuthControllerTest

# Solo tests de usuarios
.\mvnw.cmd test -Dtest=UserControllerTest
```

## Configuración

### Variables de Entorno

Editar `src/main/resources/application.yaml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fhirdb
    username: admin
    password: admin   # ⚠️ Cambiar en producción
  
  jpa:
    hibernate:
      ddl-auto: update   # Crea/actualiza tablas automáticamente

jwt:
  secret: tu-secreto-jwt-super-seguro   # ⚠️ Cambiar en producción
  expiration: 86400000  # 24 horas

server:
  port: 8080
```

### Usuario Admin Inicial

Al iniciar por primera vez, se crea automáticamente:
- **Username**: `admin`
- **Password**: `admin123`
- **Roles**: ADMIN, USER

**Script**: `src/main/resources/init-admin.sql`

## Características de Seguridad

### JWT (JSON Web Tokens)
- Generación de tokens con JJWT 0.12.6
- Expiración configurable (por defecto 24 horas)
- Firma con HS512

### Hash de Contraseñas
- BCrypt con salt automático
- Nunca se almacenan contraseñas en texto plano

### CORS
- Configurado para permitir `http://localhost:*` (desarrollo)
- Ajustar en producción en `SecurityConfig.java`

### Autorización
- Endpoints de usuario requieren token JWT válido
- Endpoints de administración requieren rol `ADMIN`
- Validación automática en cada request

## Troubleshooting

### Error: "Puerto 8080 ya en uso"
```powershell
# Ver qué proceso usa el puerto
netstat -ano | Select-String ":8080"

# Detener proceso (reemplazar PID)
Stop-Process -Id <PID> -Force

# O usar el script de iniciación que lo hace automáticamente
cd ..
.\iniciar-backend.bat
```

### Error: "Connection refused to PostgreSQL"
```powershell
# Verificar si PostgreSQL está corriendo
docker ps | Select-String "postgres"

# Si no está corriendo, iniciarlo
cd backend
docker-compose up -d

# Ver logs si hay problemas
docker logs hapi-fhir-postgres
```

### Error: Tests fallan
```powershell
# Limpiar y recompilar
.\mvnw.cmd clean test

# Ver logs detallados
.\mvnw.cmd test -X
```

### Error: "Maven Wrapper not found"
Los archivos `mvnw.cmd` y `.mvn/wrapper/maven-wrapper.jar` están incluidos en el repositorio. Si faltan:
```powershell
git restore mvnw.cmd .mvn/
```

## Build para Producción

### Crear WAR

```powershell
.\mvnw.cmd clean package
```

El archivo se genera en: `target/ROOT.war`

### Crear Imagen Docker

```powershell
docker build -t hospital-fhir-backend .
docker run -p 8080:8080 hospital-fhir-backend
```

## Tecnologías y Librerías

- **HAPI FHIR 8.6.1**: Framework FHIR R4 para Java
- **EHRbase 2.6.0**: Servidor openEHR (composiciones clínicas)
- **openEHR SDK 2.30.0**: Clases generadas a partir de templates .opt
- **Spring Boot 3.5.9**: Framework web y DI
- **Spring Data JPA**: ORM y acceso a datos FHIR/Auth
- **PostgreSQL 16**: BD relacional (FHIR+Auth en :5432, EHRbase en :5434)
- **JJWT 0.12.6**: Librería JWT para Java
- **jBCrypt 0.4**: Hash de contraseñas
- **Apache HttpClient**: Llamadas HTTP a EHRbase (AQL)
- **Jackson**: Serialización JSON

## Documentación Adicional

- [HAPI FHIR Docs](https://hapifhir.io/hapi-fhir/docs/)
- [FHIR Spec](https://www.hl7.org/fhir/)
- [Spring Boot Docs](https://docs.spring.io/spring-boot/docs/current/reference/html/)

## Licencia

Ver archivo LICENSE en la raíz del proyecto.
