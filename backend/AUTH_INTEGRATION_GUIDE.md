# 🔐 Sistema de Autenticación - HAPI FHIR + Flutter

## 📋 **Guía Completa de Integración**

---

## ✅ **Estado del Proyecto**

### **Backend (Spring Boot + HAPI FHIR)**
- ✅ Entidades de usuario y roles creadas
- ✅ Repositorio JPA configurado
- ✅ JWT Token Provider implementado
- ✅ Spring Security configurado
- ✅ Controlador de autenticación REST
- ✅ Filtro JWT para proteger endpoints
- ✅ CORS configurado para Flutter
- ✅ Inicialización automática de admin

### **Frontend (Flutter)**
- ✅ Estructura del proyecto creada
- ✅ Modelos de datos
- ✅ Servicio HTTP de autenticación
- ✅ State management con Provider
- ✅ Pantalla de Login
- ✅ Pantalla de Registro
- ✅ Pantalla Home
- ✅ Persistencia de sesión

---

## 🚀 **Pasos para Iniciar el Sistema Completo**

### **PASO 1: Compilar Backend**

```powershell
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter

# Compilar proyecto con nuevas dependencias
.\mvnw.cmd clean package -DskipTests
```

**Tiempo estimado:** 3-5 minutos

---

### **PASO 2: Verificar PostgreSQL**

```powershell
# Ver contenedores corriendo
docker ps

# Si no está corriendo, iniciarlo
docker start hapi-fhir-postgres

# Si no existe, crearlo
docker run -d --name hapi-fhir-postgres `
  -e POSTGRES_DB=fhirdb `
  -e POSTGRES_USER=fhiruser `
  -e POSTGRES_PASSWORD=fhirpass `
  -p 5432:5432 `
  postgres:16-alpine
```

---

### **PASO 3: Iniciar Servidor HAPI FHIR**

```powershell
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter
java -jar target/ROOT.war
```

**Espera a ver:**
```
✅ Usuario admin creado exitosamente
   Username: admin
   Password: admin123

Started Application in X seconds
```

El servidor creará automáticamente:
- Tabla `app_users`
- Tabla `user_roles`
- Usuario admin por defecto

---

### **PASO 4: Verificar Backend**

Abre un nuevo PowerShell y prueba los endpoints:

```powershell
# Test 1: Login con admin
$body = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8080/api/auth/login" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

**Respuesta esperada (200 OK):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "type": "Bearer",
  "id": 1,
  "username": "admin",
  "email": "admin@hospital.com",
  "firstName": "Administrador",
  "lastName": "Sistema",
  "roles": ["ROLE_ADMIN", "ROLE_USER"]
}
```

```powershell
# Test 2: Crear nuevo usuario
$body = @{
    username = "doctor1"
    email = "doctor1@hospital.com"
    password = "123456"
    firstName = "Dr. Juan"
    lastName = "Pérez"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost:8080/api/auth/signup" `
    -Method POST `
    -Body $body `
    -ContentType "application/json"
```

---

### **PASO 5: Configurar Flutter**

```powershell
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter\flutter_frontend

# Instalar dependencias
flutter pub get
```

**Editar `lib/config/api_config.dart`:**

Para **emulador Android:**
```dart
static const String baseUrl = 'http://10.0.2.2:8080';
```

Para **simulador iOS:**
```dart
static const String baseUrl = 'http://localhost:8080';
```

Para **dispositivo físico** (reemplaza con tu IP):
```dart
static const String baseUrl = 'http://192.168.1.X:8080';
```

**Obtener tu IP:**
```powershell
ipconfig | Select-String "IPv4"
```

---

### **PASO 6: Ejecutar Flutter App**

```powershell
cd C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter\flutter_frontend

# Verificar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo/emulador
flutter run
```

---

## 🎯 **Pruebas de Funcionalidad**

### **Test 1: Login con Admin**

1. Abre la app Flutter
2. Ingresa:
   - Usuario: `admin`
   - Contraseña: `admin123`
3. Presiona "Iniciar Sesión"
4. Deberías ver la pantalla Home con tu perfil

✅ **Resultado esperado:** Redirige a Home, muestra "Administrador Sistema" con chips ADMIN y USER

---

### **Test 2: Crear Nuevo Usuario**

1. En la pantalla de login, presiona "Regístrate"
2. Ingresa datos:
   - Usuario: `enfermera1`
   - Email: `enfermera@hospital.com`
   - Nombre: `María`
   - Apellido: `García`
   - Contraseña: `123456`
   - Confirmar contraseña: `123456`
3. **Deja el switch desactivado** (crear como usuario)
4. Presiona "Registrarse"

✅ **Resultado esperado:** Mensaje "Usuario registrado exitosamente", regresa a login

---

### **Test 3: Crear Administrador**

1. En la pantalla de login, presiona "Regístrate"
2. Ingresa datos similares al Test 2 pero con diferente username
3. **Activa el switch "Crear como Administrador"**
4. Presiona "Crear Administrador"

✅ **Resultado esperado:** Mensaje "Administrador creado exitosamente"

---

### **Test 4: Login con Usuario Nuevo**

1. Regresa a login
2. Usa las credenciales del usuario creado en Test 2
3. Inicia sesión

✅ **Resultado esperado:** Home muestra solo chip USER (no ADMIN)

---

## 📊 **Endpoints de API**

### **Autenticación**

| Método | Endpoint | Descripción | Auth Requerida |
|--------|----------|-------------|----------------|
| POST | `/api/auth/login` | Iniciar sesión | No |
| POST | `/api/auth/signup` | Registrar usuario | No |
| POST | `/api/auth/create-admin` | Crear administrador | No |
| GET | `/api/auth/check` | Verificar autenticación | Sí |

### **FHIR API** (protegida opcionalmente)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/fhir/metadata` | CapabilityStatement |
| GET/POST | `/fhir/Patient` | Gestión de pacientes |
| GET/POST | `/fhir/Observation` | Gestión de observaciones |

---

## 🛡️ **Seguridad**

### **JWT Token**

- **Algoritmo:** HS256
- **Expiración:** 24 horas (configurable)
- **Header:** `Authorization: Bearer {token}`

### **Roles Implementados**

```java
public enum Role {
    ROLE_USER,      // Usuario regular
    ROLE_ADMIN,     // Administrador completo
    ROLE_DOCTOR,    // Doctor (futuro)
    ROLE_NURSE      // Enfermera (futuro)
}
```

### **Encriptación de Contraseñas**

- Algoritmo: **BCrypt**
- Configuración: `BCryptPasswordEncoder`
- Las contraseñas NUNCA se almacenan en texto plano

---

## 📁 **Archivos Creados - Backend**

```
src/main/java/ca/uhn/fhir/jpa/starter/auth/
├── config/
│   └── DataInitializer.java          # Crea admin al iniciar
├── controller/
│   └── AuthController.java           # Endpoints REST
├── dto/
│   ├── JwtResponse.java              # Response de login
│   ├── LoginRequest.java             # Request de login
│   └── SignupRequest.java            # Request de registro
├── model/
│   ├── Role.java                     # Enum de roles
│   └── User.java                     # Entidad de usuario
├── repository/
│   └── UserRepository.java           # JPA Repository
├── security/
│   ├── CustomUserDetailsService.java # Carga usuarios
│   ├── JwtAuthenticationFilter.java  # Filtro JWT
│   ├── JwtTokenProvider.java         # Genera/valida tokens
│   └── SecurityConfig.java           # Configuración Spring Security
└── service/
    └── UserService.java              # Lógica de negocio
```

---

## 📁 **Archivos Creados - Flutter**

```
flutter_frontend/
├── lib/
│   ├── config/
│   │   └── api_config.dart
│   ├── models/
│   │   ├── auth_models.dart
│   │   └── user.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── services/
│   │   └── auth_service.dart
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 🔧 **Configuraciones Importantes**

### **Backend - application.yaml**

Agregado implícitamente (no necesitas cambiar nada):
```yaml
app:
  jwt:
    secret: MySecretKeyForJWTAuthenticationThatIsAtLeast256BitsLongForHS256Algorithm
    expiration: 86400000  # 24 horas
```

### **Backend - pom.xml**

Dependencias agregadas:
```xml
<!-- Spring Security -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>

<!-- JWT -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt-api</artifactId>
    <version>0.12.6</version>
</dependency>
```

---

## 🐛 **Solución de Problemas**

### **Problema 1: Error al compilar Backend**

**Error:** `cannot find symbol: class SecurityFilterChain`

**Solución:**
```powershell
.\mvnw.cmd clean install -U
```

### **Problema 2: Flutter no se conecta**

**Error:** `Connection refused` o `SocketException`

**Solución:**
1. Verifica que el servidor esté corriendo
2. Para Android Emulator, usa `http://10.0.2.2:8080`
3. Para dispositivo físico, usa tu IP local
4. Verifica que el firewall no bloquee el puerto 8080

### **Problema 3: Token inválido**

**Error:** `Invalid JWT token`

**Solución:**
1. Logout y login nuevamente
2. El token expira en 24 horas
3. Verifica que el secret sea consistente

### **Problema 4: Usuario admin no se crea**

**Error:** No puedo hacer login con admin/admin123

**Solución:**
1. Verifica los logs del servidor
2. Deberías ver "✅ Usuario admin creado exitosamente"
3. Si no aparece, verifica la conexión a PostgreSQL
4. Revisa que las tablas se hayan creado

---

## 📊 **Verificar Base de Datos**

```powershell
# Conectar a PostgreSQL
docker exec -it hapi-fhir-postgres psql -U fhiruser -d fhirdb

# Ver usuarios
SELECT * FROM app_users;

# Ver roles
SELECT u.username, r.role 
FROM app_users u 
JOIN user_roles r ON u.id = r.user_id;

# Salir
\q
```

---

## 🎓 **Conceptos Técnicos**

### **¿Qué es JWT?**

JSON Web Token - Un token firmado que contiene información del usuario y expira automáticamente.

### **¿Por qué BCrypt?**

BCrypt es un algoritmo de hash diseñado para ser lento, lo que dificulta ataques de fuerza bruta.

### **¿Qué es CORS?**

Cross-Origin Resource Sharing - Permite que Flutter (en localhost:XXXX) haga requests a Spring Boot (localhost:8080).

---

## 📈 **Próximos Pasos**

1. **Proteger endpoints FHIR:**
   - Modificar `SecurityConfig.java`
   - Cambiar `.requestMatchers("/fhir/**").permitAll()` 
   - Por `.requestMatchers("/fhir/**").authenticated()`

2. **Agregar refresh tokens:**
   - Tokens de corta duración
   - Refresh automático sin re-login

3. **Implementar recuperación de contraseña:**
   - Email con enlace de reset
   - Token temporal

4. **Agregar más pantallas en Flutter:**
   - Gestión de pacientes
   - Búsqueda avanzada
   - Formularios FHIR

---

## ✉️ **Soporte**

Si encuentras problemas:

1. Verifica que PostgreSQL esté corriendo
2. Revisa los logs del servidor
3. Asegúrate de que Flutter tenga la URL correcta
4. Verifica los mensajes de error en la app

---

**🎉 ¡Sistema de autenticación completo e integrado!**

Backend ✅ | Frontend ✅ | Documentación ✅
