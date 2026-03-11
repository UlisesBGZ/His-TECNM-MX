# Sistema de Autenticación - HAPI FHIR JPA Server

## ✅ Estado: FUNCIONANDO

El sistema de autenticación JWT está completamente operativo y funcionando correctamente.

## 🔐 Características Implementadas

### Backend (Spring Boot + JWT + BCrypt)
- ✅ Autenticación JWT sin Spring Security (evita conflictos de versiones)
- ✅ Hash de contraseñas con BCrypt
- ✅ Base de datos PostgreSQL para almacenamiento de usuarios
- ✅ Roles: USER, ADMIN, DOCTOR, NURSE
- ✅ Usuarios persistentes con JPA/Hibernate
- ✅ CORS habilitado para Flutter frontend
-  RESTful API en `/api/auth/*`

### Endpoints Disponibles

#### 1. **POST /api/auth/signup** - Registro de Usuario
```json
{
  "username": "usuario",
  "email": "usuario@example.com",
  "password": "contraseña123",
  "firstName": "Nombre",
  "lastName": "Apellido",
  "isAdmin": false
}
```
**Respuesta exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "username": "usuario",
  "email": "usuario@example.com",
  "roles": ["USER"]
}
```

#### 2. **POST /api/auth/login** - Inicio de Sesión
```json
{
  "username": "usuario",
  "password": "contraseña123"
}
```
**Respuesta exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "username": "usuario",
  "email": "usuario@example.com",
  "roles": ["USER"]
}
```

#### 3. **POST /api/auth/create-admin** - Crear Administrador
```json
{
  "username": "admin",
  "email": "admin@example.com",
  "password": "admin123",
  "firstName": "Admin",
  "lastName": "User"
}
```
**Respuesta exitosa (200):**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@example.com",
  "roles": ["ADMIN", "USER"]
}
```

#### 4. **GET /api/auth/validate** - Validar Token
**Headers:**
```
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9...
```
**Respuesta exitosa (200):**
```json
{
  "valid": true,
  "username": "usuario",
  "email": "usuario@example.com",
  "roles": ["USER"]
}
```

## 👤 Usuario Administrador por Defecto

Al iniciar el servidor por primera vez, se crea automáticamente un usuario administrador:

- **Username:** `admin`
- **Password:** `admin123`
- **Email:** `admin@example.com`
- **Roles:** ADMIN, USER

## 🚀 Cómo Usar desde Flutter

### 1. Configurar API en Flutter (ya está configurado)
```dart
// En lib/config/api_config.dart
static const String baseUrl = 'http://localhost:8080';
static const String loginEndpoint = '$baseUrl/api/auth/login';
static const String signupEndpoint = '$baseUrl/api/auth/signup';
static const String createAdminEndpoint = '$baseUrl/api/auth/create-admin';
```

### 2. Login desde Flutter
```dart
final authService = AuthService();
final response = await authService.login('admin', 'admin123');
if (response != null) {
  // Token guardado automáticamente en SharedPreferences
  print('Login exitoso: ${response['username']}');
  print('Roles: ${response['roles']}');
}
```

### 3. Registro desde Flutter
```dart
final authService = AuthService();
final response = await authService.signup(
  'usuario',
  'usuario@example.com',
  'password123',
  firstName: 'Nombre',
  lastName: 'Apellido',
  isAdmin: false,
);
```

### 4. Crear Admin desde Flutter
```dart
final authService = AuthService();
final response = await authService.createAdmin(
  'newadmin',
  'newadmin@example.com',
  'admin123',
  firstName: 'Nuevo',
  lastName: 'Admin',
);
```

## 🗄️ Base de Datos

### Tablas Creadas Automáticamente

1. **app_users** - Almacena usuarios
   - id (BIGINT, PRIMARY KEY)
   - username (VARCHAR, UNIQUE)
   - email (VARCHAR, UNIQUE)
   - password (VARCHAR - BCrypt hash)
   - first_name (VARCHAR)
   - last_name (VARCHAR)
   - enabled (BOOLEAN)
   - created_at (TIMESTAMP)
   - updated_at (TIMESTAMP)

2. **user_roles** - Almacena roles por usuario
   - user_id (BIGINT, FOREIGN KEY)
   - role (VARCHAR - USER, ADMIN, DOCTOR, NURSE)

### Conexión a PostgreSQL
```yaml
# En docker-compose.yml
Database: fhirdb
User: fhiruser
Password: fhirpass
Port: 5432 (interno del contenedor)
```

## 🔧 Configuración JWT

```yaml
# En src/main/resources/application.yaml
jwt:
  secret: mySecretKeyForJWTAuthentication1234567890123456789012345678901234567890
  expiration: 86400000  # 24 horas en milisegundos
```

## 🐳 Docker

### Iniciar Servidor
```bash
docker-compose up -d
```

### Ver Logs
```bash
docker-compose logs -f hapi-fhir-jpaserver-start
```

### Detener Servidor
```bash
docker-compose down
```

### Reconstruir (si hay cambios en código)
```bash
docker-compose up --build -d
```

## 📁 Estructura de Archivos Backend

```
src/main/java/ca/uhn/fhir/jpa/starter/auth/
├── config/
│   ├── AuthDatabaseConfig.java         # Configuración de JPA para auth
│   └── DataInitializer.java            # Crea usuario admin por defecto
├── controller/
│   └── AuthController.java             # Endpoints REST de autenticación
├── dto/
│   ├── JwtResponse.java                # Respuesta con token
│   ├── LoginRequest.java               # Request de login
│   └── SignupRequest.java              # Request de registro
├── model/
│   ├── Role.java                       # Enum de roles
│   └── User.java                       # Entidad JPA de usuario
├── repository/
│   └── UserRepository.java             # Repositorio JPA
└── util/
    └── JwtUtil.java                    # Generación y validación de JWT
```

## 📝 Frontend Flutter

El frontend Flutter ya está completamente implementado con:
- ✅ Pantalla de login
- ✅ Pantalla de registro
- ✅ Pantalla principal (home)
- ✅ Validación de formularios
- ✅ Manejo de estado con Provider
- ✅ Almacenamiento seguro de tokens
- ✅ Toggle para crear admin en registro

### Ejecutar Flutter App
```bash
cd flutter_frontend
flutter run -d chrome
```

## ✅ Pruebas Realizadas

1. ✅ Registro de usuario regular: EXITOSO
2. ✅ Login con credenciales correctas: EXITOSO
3. ✅ Creación de administrador: EXITOSO
4. ✅ Login con admin por defecto (admin/admin123): EXITOSO
5. ✅ Generación de tokens JWT: EXITOSO
6. ✅ Hash de contraseñas con BCrypt: EXITOSO
7. ✅ Persistencia en PostgreSQL: EXITOSO

## 🔒 Seguridad

- ✅ Contraseñas hasheadas con BCrypt (strength 10)
- ✅ Tokens JWT firmados con HS512
- ✅ Secret key de 512 bits
- ✅ Tokens con expiración de 24 horas
- ✅ Validación de tokens en cada request
- ✅ CORS configurado para desarrollo

## 🎯 Próximos Pasos (Opcional)

Si quieres mejorar el sistema, puedes:
1. Agregar refresh tokens para renovación automática
2. Implementar recuperación de contraseña por email
3. Agregar verificación de email
4. Implementar 2FA (autenticación de dos factores)
5. Agregar rate limiting para prevenir ataques
6. Implementar middleware de autorización por roles
7. Agregar logging de auditoría

## 📞 Contacto/Soporte

El sistema está completamente funcional y listo para usar. Para probarlo:

1. Asegúrate de que Docker esté corriendo: `docker-compose ps`
2. Prueba el endpoint de login: `http://localhost:8080/api/auth/login`
3. Usa las credenciales por defecto: `admin` / `admin123`

¡Sistema de autenticación implementado y funcionando correctamente! 🎉
