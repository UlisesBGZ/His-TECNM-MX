# 🏥 Sistema Hospitalario Completo - HAPI FHIR + Flutter

## 🎯 **Sistema Integrado de Información Hospitalaria**

Solución completa con:
- ✅ **Backend:** Spring Boot + HAPI FHIR Server (HL7 FHIR R4)
- ✅ **Base de Datos:** PostgreSQL 16
- ✅ **Autenticación:** JWT + Spring Security
- ✅ **Frontend:** Flutter (iOS/Android)

---

## � **Requisitos Previos**

- ✅ **Java 17+** (JDK instalado y JAVA_HOME configurado)
- ✅ **Flutter 3.27+** (agregado al PATH del sistema)
- ✅ **Docker Desktop** (corriendo)
- ✅ **Git** (opcional, para clonar)
- ✅ **PostgreSQL 16** (Docker container)

### **Verificar Requisitos**

```powershell
java -version          # Java 17 o superior
flutter --version      # Flutter 3.27 o superior
docker --version       # Docker instalado
echo $env:JAVA_HOME    # Debe mostrar ruta a JDK
```

---

## 🚀 **Inicio Rápido (Primera Vez)**

### **Paso 1: Configurar Variables de Entorno**

```powershell
# Ejecutar como Administrador
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-21.0.10", "Machine")
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = "$currentPath;C:\src\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

# Cerrar y reabrir PowerShell
```

**O usar el script incluido:**
```powershell
# Como Administrador
.\configurar-variables-entorno.ps1
```

### **Paso 2: Iniciar PostgreSQL**

```powershell
# Primera vez o si no existe el contenedor
docker-compose up -d hapi-fhir-postgres

# Si ya existe, solo iniciarlo
docker start hapi-fhir-postgres

# Verificar que está corriendo
docker ps
```

### **Paso 3: Iniciar Backend**

```powershell
# En el directorio raíz del proyecto
cd C:\Users\Ulises\Desktop\HapiFhir-Springboot
.\mvnw.cmd spring-boot:run -Pboot

# Espera a ver: "Started Application in XX seconds"
# Backend estará en http://localhost:8080
```

### **Paso 4: Iniciar Frontend (en otra terminal)**

```powershell
# Nueva terminal PowerShell
cd C:\Users\Ulises\Desktop\HapiFhir-Springboot\flutter_frontend
flutter run -d chrome

# Chrome se abrirá automáticamente
```

---

## ⚡ **Inicio Rápido (Sesiones Siguientes)**

```powershell
# Terminal 1 - Backend
cd C:\Users\Ulises\Desktop\HapiFhir-Springboot
.\mvnw.cmd spring-boot:run -Pboot

# Terminal 2 - Frontend
cd flutter_frontend
flutter run -d chrome
```

---

## 📱 **Credenciales de Acceso**

**Usuario Administrador (creado automáticamente):**
```
Username: admin
Password: admin123
```

---

## ✨ **Características Implementadas**

### **Backend**
- ✅ Servidor HAPI FHIR R4 completo
- ✅ Persistencia en PostgreSQL
- ✅ Sistema de autenticación con JWT
- ✅ Roles y permisos (Admin/User/Doctor/Nurse)
- ✅ API REST para autenticación
- ✅ CORS configurado para Flutter
- ✅ Inicialización automática de admin
- ✅ 147 resource providers FHIR

### **Frontend (Flutter)**
- ✅ Pantalla de Login con validación
- ✅ Registro de usuarios
- ✅ Creación de administradores
- ✅ Gestión de sesión persistente
- ✅ Home personalizado por rol
- ✅ Logout
- ✅ Manejo de errores
- ✅ UI Material Design 3

---

## 📊 **Endpoints de API**

### **Autenticación** (`/api/auth`)

| Endpoint | Método | Descripción | Auth |
|----------|--------|-------------|------|
| `/api/auth/login` | POST | Iniciar sesión | No |
| `/api/auth/signup` | POST | Crear usuario | No |
| `/api/auth/create-admin` | POST | Crear admin | No |
| `/api/auth/check` | GET | Verificar token | Sí |

### **FHIR API** (`/fhir`)

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/fhir/metadata` | GET | CapabilityStatement |
| `/fhir/Patient` | GET, POST, PUT, DELETE | Pacientes |
| `/fhir/Observation` | GET, POST | Observaciones |
| `/fhir/Practitioner` | GET, POST | Profesionales |
| `/fhir/Appointment` | GET, POST | Citas |

---

## 📁 **Estructura del Proyecto**

```
hapi-fhir-jpaserver-starter/
├── src/main/java/ca/uhn/fhir/jpa/starter/
│   ├── auth/                          # 🔐 Sistema de autenticación
│   │   ├── config/
│   │   │   └── DataInitializer.java   # Crea admin al iniciar
│   │   ├── controller/
│   │   │   └── AuthController.java    # API REST de auth
│   │   ├── dto/
│   │   │   ├── LoginRequest.java
│   │   │   ├── SignupRequest.java
│   │   │   └── JwtResponse.java
│   │   ├── model/
│   │   │   ├── User.java              # Entidad de usuario
│   │   │   └── Role.java              # Enum de roles
│   │   ├── repository/
│   │   │   └── UserRepository.java    # JPA Repository
│   │   ├── security/
│   │   │   ├── SecurityConfig.java    # Spring Security
│   │   │   ├── JwtTokenProvider.java  # Generador de JWT
│   │   │   ├── JwtAuthenticationFilter.java
│   │   │   └── CustomUserDetailsService.java
│   │   └── service/
│   │       └── UserService.java       # Lógica de negocio
│   └── Application.java               # Main class
│
├── flutter_frontend/                  # 📱 App móvil Flutter
│   ├── lib/
│   │   ├── config/
│   │   │   └── api_config.dart        # Configuración API
│   │   ├── models/
│   │   │   ├── user.dart
│   │   │   └── auth_models.dart
│   │   ├── providers/
│   │   │   └── auth_provider.dart     # State management
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── home_screen.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md                      # Docs de Flutter
│
├── pom.xml                            # Dependencias Maven
├── docker-compose.yml                 # PostgreSQL + HAPI
├── configurar-variables-entorno.ps1   # 🚀 Script para JAVA_HOME y Flutter PATH
├── SERVIDOR_CONFIGURADO.md            # Estado del servidor
├── AUTH_INTEGRATION_GUIDE.md          # 📖 Guía completa
├── CONTEXTO_PARA_NUEVA_SESION.md      # 📚 Contexto técnico completo
├── DESARROLLO_COMPLETO.md             # 📚 Historia del desarrollo
├── TESTING.md                         # 🧪 Guía de tests
└── README_SISTEMA_COMPLETO.md         # Este archivo
```

---

## 🔧 **Tecnologías Utilizadas**

### **Backend**
- Java 21.0.10 (compatible con Java 17+)
- Spring Boot 3.5.9
- HAPI FHIR 8.6.1
- Spring Security 6.x
- JWT (JJWT 0.12.6)
- PostgreSQL 16 (Docker)
- Hibernate/JPA
- Maven 3.3.2 (Maven Wrapper)

### **Frontend**
- Flutter 3.27.3
- Dart 3.10.7
- Provider (State Management)
- HTTP package
- SharedPreferences
- Material Design 3

### **DevOps**
- Docker Desktop 29.2+
- Docker Compose
- Git 2.53+
- PowerShell 7+

---

## 📖 **Documentación Detallada**

1. **[AUTH_INTEGRATION_GUIDE.md](AUTH_INTEGRATION_GUIDE.md)** ⭐
   - Guía completa paso a paso
   - Pruebas de funcionalidad
   - Solución de problemas
   - Arquitectura del sistema

2. **[CONTEXTO_PARA_NUEVA_SESION.md](CONTEXTO_PARA_NUEVA_SESION.md)** ⭐⭐
   - Contexto técnico completo (5,500+ líneas)
   - Estructura detallada del proyecto
   - Configuración de todos los componentes
   - Endpoints y credenciales

3. **[DESARROLLO_COMPLETO.md](DESARROLLO_COMPLETO.md)**
   - Historia del desarrollo (700+ líneas)
   - Problemas resueltos
   - Decisiones técnicas
   - Fases del proyecto

4. **[TESTING.md](TESTING.md)**
   - Guía de tests completa
   - 23 tests backend + 25 tests frontend
   - Cómo ejecutar tests
   - Resultados esperados

5. **[CHECKLIST_TRANSFERENCIA.md](CHECKLIST_TRANSFERENCIA.md)**
   - Transferir proyecto a nueva laptop
   - Requisitos previos
   - Pasos de configuración
   - Verificación de integridad

6. **[GUIA_GITHUB.md](GUIA_GITHUB.md)**
   - Subir proyecto a GitHub
   - Configurar Git
   - Comandos útiles
   - Sincronización

7. **[SERVIDOR_CONFIGURADO.md](SERVIDOR_CONFIGURADO.md)**
   - Estado del servidor HAPI FHIR
   - URLs y endpoints
   - Troubleshooting

8. **[flutter_frontend/README.md](flutter_frontend/README.md)**
   - Documentación específica de Flutter
   - Configuración de la app
   - Builds y deployment

---

## 🧪 **Pruebas Completas**

### **Test 1: Backend REST API**

```powershell
# Login
$body = @{username='admin'; password='admin123'} | ConvertTo-Json
$response = Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
    -Method POST -Body $body -ContentType "application/json"
$token = ($response.Content | ConvertFrom-Json).token

# Usar token para acceder a FHIR
Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient" `
    -Headers @{Authorization="Bearer $token"}
```

### **Test 2: Flutter App**

1. Abrir app en emulador/dispositivo
2. Login con `admin` / `admin123`
3. Verificar que muestra Home con roles ADMIN y USER
4. Crear nuevo usuario desde "Regístrate"
5. Logout y login con nuevo usuario

---

## 🔐 **Seguridad**

### **Características Implementadas**

- ✅ Contraseñas hasheadas con BCrypt
- ✅ Tokens JWT con expiración (24h)
- ✅ CORS configurado correctamente
- ✅ Roles y permisos
- ✅ Validación de entrada en backend y frontend
- ✅ Session management segura

### **⚠️ Para Producción**

- [ ] Cambiar JWT secret en production
- [ ] Habilitar HTTPS/TLS
- [ ] Configurar CORS específicos (no `*`)
- [ ] Implementar rate limiting
- [ ] Agregar refresh tokens
- [ ] Audit logging
- [ ] Two-factor authentication

---

## 🗄️ **Base de Datos**

### **Tablas Creadas Automáticamente**

**Autenticación:**
- `app_users` - Usuarios del sistema
- `user_roles` - Roles asignados

**HAPI FHIR (300+ tablas):**
- `hfj_resource` - Recursos FHIR
- `hfj_res_ver` - Versiones de recursos
- `hfj_spidx_*` - Índices de búsqueda
- Y muchas más...

### **Verificar Datos**

```powershell
docker exec -it hapi-fhir-postgres psql -U fhiruser -d fhirdb

# Ver usuarios
SELECT username, email, first_name FROM app_users;

# Ver roles
SELECT u.username, r.role FROM app_users u 
JOIN user_roles r ON u.id = r.user_id;
```

---

## 🐛 **Solución de Problemas Comunes**

### **1. Backend no compila**

```powershell
# Limpiar y recompilar
.\mvnw.cmd clean install -U
```

### **2. Flutter no conecta al backend**

**Para Web (Chrome/Edge):**
```dart
// En lib/config/api_config.dart
static const String _webBaseUrl = 'http://localhost:8080';
```

**Para Móvil (Android/iOS):**
```dart
// En lib/config/api_config.dart
// Actualiza con tu IP de red local
static const String _mobileBaseUrl = 'http://192.168.0.181:8080';
```

**Encontrar tu IP:**
```powershell
ipconfig | Select-String "IPv4"
# Actualiza la IP en:
# - flutter_frontend/lib/config/api_config.dart
# - flutter_frontend/lib/services/fhir_service.dart
```

**Configuración Dinámica Actual:**
- Detecta automáticamente si es web (`kIsWeb`)
- Web usa `localhost:8080`
- Móvil usa IP de red: `192.168.0.181:8080`

### **3. PostgreSQL no arranca**

```powershell
# Ver logs
docker logs hapi-fhir-postgres

# Recrear contenedor con docker-compose
docker-compose down
docker-compose up -d hapi-fhir-postgres

# Verificar estado
docker ps --filter "name=postgres"

# Debe mostrar puerto mapeado: 0.0.0.0:5432->5432/tcp
```

### **5. Error: JAVA_HOME not found**

```powershell
# Configurar JAVA_HOME para esta sesión
$env:JAVA_HOME = "C:\Program Files\Java\jdk-21.0.10"

# O configurar permanentemente (como Administrador)
[Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-21.0.10", "Machine")

# Reiniciar PowerShell después
```

### **4. Admin no se crea**

Verifica los logs del servidor. Deberías ver:
```
✅ Usuario admin creado exitosamente
   Username: admin
   Password: admin123
```

---

## 📊 **Monitoreo**

### **Health Checks**

```
GET http://localhost:8080/actuator/health
GET http://localhost:8080/actuator/health/liveness
GET http://localhost:8080/actuator/health/readiness
```

### **Métricas**

```
GET http://localhost:8080/actuator/metrics
```

---

## 🎯 **Roadmap**

### **Fase 1: Autenticación ✅ COMPLETADA**
- [x] Login/Logout
- [x] Registro de usuarios
- [x] Creación de admins
- [x] JWT tokens
- [x] Roles y permisos

### **Fase 2: Gestión de Pacientes (Próximo)**
- [ ] CRUD de pacientes en Flutter
- [ ] Búsqueda avanzada
- [ ] Filtros y ordenamiento
- [ ] Paginación

### **Fase 3: Citas Médicas**
- [ ] Programar citas
- [ ] Calendario
- [ ] Notificaciones

### **Fase 4: Historial Médico**
- [ ] Observaciones
- [ ] Diagnósticos
- [ ] Medicaciones
- [ ] Documentos adjuntos

---

## 👥 **Roles del Sistema**

| Rol | Permisos | Descripción |
|-----|----------|-------------|
| **ADMIN** | Completo | Gestión total del sistema |
| **USER** | Básico | Usuario estándar |
| **DOCTOR** | Médico | Acceso a pacientes y citas |
| **NURSE** | Enfermería | Registro de observaciones |

---

## 🌐 **URLs del Sistema**

### **Backend**
- Web UI: http://localhost:8080
- FHIR API: http://localhost:8080/fhir
- Auth API: http://localhost:8080/api/auth
- Metadata: http://localhost:8080/fhir/metadata
- Health: http://localhost:8080/actuator/health

### **Base de Datos**
- Host: localhost
- Port: 5432
- Database: fhirdb
- Usuario: fhiruser
- Password: fhirpass

**Conexión:**
```powershell
# Verificar que PostgreSQL está corriendo
docker ps --filter "name=postgres"

# Conectarse a la base de datos
docker exec -it hapi-fhir-postgres psql -U fhiruser -d fhirdb
```

---

## 🔄 **Flujo de Autenticación**

```
┌─────────┐         ┌──────────┐         ┌──────────┐         ┌──────────┐
│ Flutter │         │  Spring  │         │   JWT    │         │PostgreSQL│
│   App   │         │  Backend │         │ Provider │         │   DB     │
└────┬────┘         └─────┬────┘         └─────┬────┘         └─────┬────┘
     │                    │                    │                    │
     │  POST /login       │                    │                    │
     ├───────────────────>│                    │                    │
     │  {username,pwd}    │                    │                    │
     │                    │ Validar usuario    │                    │
     │                    ├───────────────────────────────────────>│
     │                    │                    │                    │
     │                    │<───────────────────────────────────────┤
     │                    │   User found       │                    │
     │                    │                    │                    │
     │                    │  Generar JWT       │                    │
     │                    ├───────────────────>│                    │
     │                    │                    │                    │
     │                    │<───────────────────┤                    │
     │                    │   JWT Token        │                    │
     │                    │                    │                    │
     │<───────────────────┤                    │                    │
     │  {token, user}     │                    │                    │
     │                    │                    │                    │
     │  Guardar token     │                    │                    │
     │  en localStorage   │                    │                    │
     │                    │                    │                    │
     │  GET /fhir/Patient │                    │                    │
     │  Authorization:    │                    │                    │
     │  Bearer {token}    │                    │                    │
     ├───────────────────>│                    │                    │
     │                    │  Validar token     │                    │
     │                    ├───────────────────>│                    │
     │                    │                    │                    │
     │                    │<───────────────────┤                    │
     │                    │   Token válido     │                    │
     │                    │                    │                    │
     │<───────────────────┤                    │                    │
     │  Patients data     │                    │                    │
     │                    │                    │                    │
```

---

## 🎓 **Para Desarrolladores**

### **Agregar Nuevo Endpoint Protegido**

```java
@RestController
@RequestMapping("/api/patients")
public class PatientController {
    
    @GetMapping
    @PreAuthorize("hasRole('USER')")  // Solo usuarios autenticados
    public ResponseEntity<?> getPatients() {
        // ...
    }
    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")  // Solo administradores
    public ResponseEntity<?> createPatient() {
        // ...
    }
}
```

### **Agregar Nueva Pantalla en Flutter**

1. Crear archivo en `lib/screens/nueva_screen.dart`
2. Implementar `StatefulWidget` o `StatelessWidget`
3. Agregar navegación desde otra pantalla
4. Usar `Provider` para acceder al estado

---

## 📞 **Soporte**

Para preguntas o problemas:

1. Revisa [AUTH_INTEGRATION_GUIDE.md](AUTH_INTEGRATION_GUIDE.md)
2. Verifica logs del servidor
3. Consulta la documentación de HAPI FHIR
4. Revisa los issues en GitHub

---

## 📄 **Licencia**

Este proyecto es parte del Sistema Hospitalario HAPI FHIR.

---

## ✅ **Checklist de Verificación**

Antes de considerar el sistema completo, verifica:

**Requisitos:**
- [x] Java 21+ instalado
- [x] JAVA_HOME configurado permanentemente
- [x] Flutter 3.27+ instalado
- [x] Flutter agregado al PATH del sistema
- [x] Docker Desktop instalado y corriendo
- [x] Git instalado (opcional)

**Sistema:**
- [x] PostgreSQL corriendo en Docker (puerto 5432 mapeado)
- [x] Maven Wrapper descargado (63 KB)
- [x] Backend compila sin errores
- [x] Servidor inicia correctamente (~18-26 segundos)
- [x] Admin creado automáticamente (admin/admin123)
- [x] Login funciona desde API REST
- [x] Flutter app compila sin errores
- [x] Flutter conecta al backend (localhost para web)
- [x] IP de red configurada (192.168.0.181 para móvil)
- [x] Login funciona desde Flutter web
- [x] Registro de usuarios funciona
- [x] Creación de admins funciona
- [x] Home muestra datos correctos con roles
- [x] Logout funciona
- [x] Sesión persiste al cerrar/abrir app
- [x] Proyecto sincronizado con GitHub

**Tests:**
- [x] Backend: 23/23 tests pasando (AuthController + UserController)
- [x] Frontend: 25/25 tests pasando (auth_service + fhir_service)

---

**🎉 ¡Sistema Completo y Funcionando!**

```
Backend:     ✅ Spring Boot + HAPI FHIR + JWT (puerto 8080)
Database:    ✅ PostgreSQL 16 con autenticación y FHIR (puerto 5432)
Frontend:    ✅ Flutter con Login, Registro y Home
Config:      ✅ JAVA_HOME y Flutter PATH configurados
Network:     ✅ IP dinámica para web (localhost) y móvil (192.168.0.181)
Docs:        ✅ Guías completas y troubleshooting
Tests:       ✅ 48 tests pasando (23 backend + 25 frontend)
GitHub:      ✅ Sincronizado con repositorio remoto
```

## 🚀 **Comandos de Referencia Rápida**

```powershell
# Iniciar Sistema Completo
# Terminal 1 - Backend:
cd C:\Users\Ulises\Desktop\HapiFhir-Springboot
.\mvnw.cmd spring-boot:run -Pboot

# Terminal 2 - Frontend:
cd flutter_frontend
flutter run -d chrome

# Verificar Estado
docker ps                          # PostgreSQL corriendo
java -version                      # Java instalado
flutter --version                  # Flutter instalado
echo $env:JAVA_HOME                # JAVA_HOME configurado
git status                         # Estado del repositorio

# Tests
.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"
cd flutter_frontend; flutter test

# Git
git add .
git commit -m "descripción"
git push origin master
```

**Desarrollado con ❤️ para el Sistema Hospitalario**

---

## 📚 **Documentación Adicional**

| Archivo | Descripción |
|---------|-------------|
| [CONTEXTO_PARA_NUEVA_SESION.md](CONTEXTO_PARA_NUEVA_SESION.md) | Guía técnica completa (5,500+ líneas) |
| [DESARROLLO_COMPLETO.md](DESARROLLO_COMPLETO.md) | Historia del desarrollo (700+ líneas) |
| [TESTING.md](TESTING.md) | Guía de tests y resultados |
| [AUTH_INTEGRATION_GUIDE.md](AUTH_INTEGRATION_GUIDE.md) | Integración de autenticación |
| [CHECKLIST_TRANSFERENCIA.md](CHECKLIST_TRANSFERENCIA.md) | Para transferir a otra laptop |
| [GUIA_GITHUB.md](GUIA_GITHUB.md) | Guía de Git y GitHub |
| [.github/copilot-instructions.md](.github/copilot-instructions.md) | Instrucciones para Copilot |
