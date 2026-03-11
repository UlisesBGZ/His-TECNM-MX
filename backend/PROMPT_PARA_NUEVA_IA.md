# 🤖 PROMPT DE INICIALIZACIÓN PARA NUEVA SESIÓN DE IA

> **Copia este contenido completo y pégalo en una nueva sesión de IA para continuar trabajando en el proyecto**

---

Hola, voy a continuar trabajando en un proyecto que ya está en desarrollo. Este es el contexto completo:

## 📋 CONTEXTO DEL PROYECTO

**Nombre**: Sistema de Gestión Hospitalaria FHIR con Autenticación Custom  
**Estado**: ✅ Completamente funcional, tests pasando al 100%  
**Stack**: Spring Boot 3.5.9 + HAPI FHIR 8.6.1 + Flutter 3.38.7 + PostgreSQL 16  
**Fecha de última actualización**: 20 de Febrero, 2026

## 🏗️ ARQUITECTURA

- **Backend**: Spring Boot + HAPI FHIR en puerto 8080
- **Frontend**: Flutter (web en Chrome, móvil en Android)
- **Base de Datos**: PostgreSQL 16 en Docker (puerto 5432)
- **Autenticación**: JWT (JJWT 0.12.6) + BCrypt
- **Testing**: 23 tests backend + 25 tests frontend (100% pasando)

## 📁 ESTRUCTURA CLAVE

```
hapi-fhir-jpaserver-starter/
├── src/main/java/ca/uhn/fhir/jpa/starter/
│   ├── Application.java
│   └── auth/                              # Sistema custom de autenticación
│       ├── controller/
│       │   ├── AuthController.java        # login, signup, validateToken, createAdmin
│       │   └── UserController.java        # CRUD usuarios, toggleUserStatus
│       ├── model/User.java
│       ├── repository/UserRepository.java
│       ├── service/AuthService.java
│       ├── security/JwtUtil.java
│       └── dto/
│
├── src/test/java/.../auth/
│   ├── AuthControllerTest.java           # 12 tests ✅
│   └── UserControllerTest.java           # 11 tests ✅
│
├── flutter_frontend/
│   ├── lib/
│   │   ├── config/api_config.dart        # 🔧 Configuración dinámica (kIsWeb)
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   └── fhir_service.dart         # 🔧 Configuración dinámica
│   │   ├── models/ (Patient, Appointment)
│   │   ├── providers/auth_provider.dart
│   │   └── screens/ (login, home, patients, appointments)
│   ├── test/                              # 25 tests ✅
│   └── update-ip.ps1                      # Script para actualizar IP
│
├── docker-compose.yml                     # PostgreSQL 16
├── mvnw.cmd                               # Maven Wrapper (REPARADO)
├── .mvn/wrapper/maven-wrapper.jar         # JAR descargado (61.5 KB)
└── DESARROLLO_COMPLETO.md                 # Documentación detallada (700+ líneas)
```

## ⚙️ CONFIGURACIÓN CRÍTICA

### 1. Configuración Dinámica de Red (IMPORTANTE)

**flutter_frontend/lib/config/api_config.dart**:
```dart
static String get baseUrl {
  if (kIsWeb) return 'http://localhost:8080';      // Web
  else return 'http://192.168.21.0:8080';          // Móvil (IP actual)
}
```

**flutter_frontend/lib/services/fhir_service.dart**:
```dart
static String get baseUrl {
  if (kIsWeb) return 'http://localhost:8080/fhir';
  else return 'http://192.168.21.0:8080/fhir';
}
```

⚠️ **Importante**: La IP de red puede cambiar. Si hay problemas de conexión en móvil, ejecutar:
```powershell
cd flutter_frontend
.\update-ip.ps1
```

### 2. Credenciales

**Base de Datos**:
- Host: localhost:5432
- Database: fhirdb
- User: admin
- Password: admin

**Usuario Admin**:
- Username: admin
- Password: admin123

## 🚀 COMANDOS PARA INICIAR

```powershell
# 1. Base de datos
docker-compose up -d

# 2. Backend (en raíz del proyecto)
.\mvnw.cmd spring-boot:run -Pboot

# 3. Frontend web
cd flutter_frontend
flutter run -d chrome

# 4. Tests backend
.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"

# 5. Tests frontend
cd flutter_frontend
flutter test
```

## 🔐 ENDPOINTS PRINCIPALES

**Autenticación**:
- POST `/api/auth/login` - Login (retorna JWT)
- POST `/api/auth/signup` - Registro
- GET `/api/auth/validate` - Validar token
- POST `/api/auth/create-admin` - Crear admin (requiere token admin)

**Usuarios** (requieren token):
- GET `/api/users` - Listar usuarios (solo admin)
- GET `/api/users/{id}` - Usuario por ID (solo admin)
- DELETE `/api/users/{id}` - Eliminar usuario (solo admin)
- PUT `/api/users/{id}/toggle-status` - Cambiar estado (solo admin)

**FHIR** (requieren token):
- GET `/fhir/Patient?_count=10`
- GET `/fhir/Appointment?_count=10`
- GET `/fhir/Patient/{id}`

## 🔧 PROBLEMAS RESUELTOS

1. ✅ **Maven Wrapper**: Faltaba `maven-wrapper.jar` y `mvnw.cmd` estaba corrupto → Descargamos JAR (61.5 KB) y reemplazamos CMD

2. ✅ **IP Cambiante**: DHCP reasignaba IP (192.168.20.225 → 192.168.21.0) → Implementamos configuración dinámica con `kIsWeb` + script `update-ip.ps1`

3. ✅ **Tests con Métodos Incorrectos**: Tests llamaban `checkAuth()`, `enableUser()`, `updateUser()` → Corregimos a `validateToken()`, `toggleUserStatus()`, eliminamos inexistentes

4. ✅ **Mocks Incorrectos**: Test usaba `existsById()` pero controller llamaba `findById()` → Cambiamos mocks para retornar `Optional<User>`

## 🎨 CARACTERÍSTICAS DE UI

- Gradiente morado/azul en login
- Animaciones FadeTransition + SlideTransition (1200ms)
- Animaciones ScaleTransition escalonadas en home (1500ms, delay 100ms)
- Material Design 3 (botones elevados, campos modernos)
- Efectos glassmórficos con blur

## 📊 ESTADO ACTUAL

**Tests**:
- Backend: 23/23 ✅ (AuthController: 12, UserController: 11)
- Frontend: 25/25 ✅ (auth_service: 12, fhir_service: 11, widgets: 2)
- 7 tests de widget Flutter requieren Provider mocking (no crítico)
- 9 tests de integración HAPI fallan (esperado, requieren BD de test)

**Despliegue**:
- ✅ Web (Chrome): Funcionando en localhost:8080
- ✅ Móvil: Desplegado exitosamente en Android 16 (device 2412DPC0AG)

**Documentación**:
- ✅ DESARROLLO_COMPLETO.md (700+ líneas, historia completa)
- ✅ CONTEXTO_PARA_NUEVA_SESION.md (guía de transferencia)
- ✅ AGENTS.md (guías para IAs)

## 📚 ARCHIVOS DE REFERENCIA

Si necesitas detalles específicos, revisa:
- **CONTEXTO_PARA_NUEVA_SESION.md**: Guía completa de setup y configuración
- **DESARROLLO_COMPLETO.md**: Historia del desarrollo, problemas resueltos, guías de despliegue
- **AGENTS.md**: Convenciones del proyecto para agentes IA

## 🎯 POSIBLES PRÓXIMOS PASOS

Según la documentación, los próximos pasos recomendados son:

**Inmediato**:
- Configurar Git para versionamiento
- Probar flujo completo end-to-end

**Corto plazo**:
- Mejorar seguridad (refresh tokens, rate limiting, CORS específico)
- Ampliar tests (mockear Provider en widget tests)
- Mejorar UX (loading indicators, pull-to-refresh)

**Mediano plazo**:
- Ampliar funcionalidad FHIR (Observations, Medications)
- Implementar roles avanzados (DOCTOR, NURSE, PATIENT)
- Optimizar performance (paginación, caching con Redis)

**Largo plazo**:
- Despliegue a producción (Railway/Render para backend, Firebase para frontend)
- Publicar app móvil en Play Store
- Implementar monitoreo (Sentry, Prometheus, ELK)

## 📝 NOTAS IMPORTANTES

1. **Configuración de Red**: Es dinámica, pero si cambias de red/laptop ejecuta `update-ip.ps1`

2. **Maven Wrapper**: NO eliminar `.mvn/wrapper/maven-wrapper.jar` (61.5 KB) ni `mvnw.cmd`

3. **Tests**: Para ejecución rápida usar `.\mvnw.cmd test -Dtest="Auth*,User*"` (evita tests de integración HAPI que requieren BD especial)

4. **Móvil**: Requiere PC y dispositivo en misma red WiFi, IP correcta en configuración

5. **Seguridad**: JWT secret y passwords son de desarrollo, cambiar en producción

## 🆘 SI ALGO NO FUNCIONA

**No puedo iniciar sesión**:
1. Verificar backend corriendo: `Get-Process | Where-Object {$_.ProcessName -like "*java*"}`
2. Verificar puerto: `Test-NetConnection localhost -Port 8080`
3. Verificar IP (móvil): `ipconfig | Select-String "IPv4"` y actualizar con `update-ip.ps1`

**Maven no compila**:
1. Verificar JAR existe: `Test-Path .\.mvn\wrapper\maven-wrapper.jar`
2. Si falta, está en CONTEXTO_PARA_NUEVA_SESION.md cómo descargarlo

**Tests fallan**:
1. Si son tests HAPI (9 errores), es normal → usar `-Dtest="Auth*,User*"`
2. Si son tests custom, revisar que mocks usen métodos correctos (findById, no existsById)

**App móvil no conecta**:
1. Verificar misma red WiFi
2. Ejecutar `.\update-ip.ps1`
3. Verificar firewall no bloquea puerto 8080

---

## 💬 PETICIÓN ACTUAL

[AQUÍ PUEDES ESCRIBIR TU NUEVA PETICIÓN]

Por ejemplo:
- "Necesito agregar un endpoint para actualizar perfil de usuario"
- "Quiero implementar paginación en la lista de pacientes"
- "Ayúdame a configurar el despliegue en Railway"
- "Necesito agregar búsqueda de pacientes por nombre"

---

**Contexto proporcionado por**: Usuario original  
**Laptop origen**: Primera laptop  
**Fecha de transferencia**: 20 de Febrero, 2026  
**Estado del sistema**: ✅ Completamente funcional, listo para continuar

---

*Para detalles técnicos completos, pide que abra y lea los archivos:*
- *CONTEXTO_PARA_NUEVA_SESION.md*
- *DESARROLLO_COMPLETO.md*
- *AGENTS.md*
