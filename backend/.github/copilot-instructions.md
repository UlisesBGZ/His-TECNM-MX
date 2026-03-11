# GitHub Copilot - Instrucciones del Proyecto

## Contexto del Proyecto

**Proyecto**: Sistema de Gestión Hospitalaria FHIR con Autenticación JWT  
**Estado**: ✅ Completamente funcional  
**Stack**: Spring Boot 3.5.9 + HAPI FHIR 8.6.1 + Flutter 3.27.3 + PostgreSQL 16

## Estructura Clave

```
src/main/java/ca/uhn/fhir/jpa/starter/auth/
  ├── controller/
  │   ├── AuthController.java      # login, signup, validateToken, createAdmin
  │   └── UserController.java      # CRUD usuarios, toggleUserStatus
  ├── model/User.java
  ├── repository/UserRepository.java
  ├── service/AuthService.java
  └── security/JwtUtil.java

flutter_frontend/lib/
  ├── config/api_config.dart       # Configuración dinámica (kIsWeb)
  ├── services/
  │   ├── auth_service.dart
  │   └── fhir_service.dart
  ├── providers/auth_provider.dart
  └── screens/ (login, home, patients, appointments)
```

## Configuraciones Importantes

### IP Dinámica
- **Web**: localhost:8080
- **Móvil**: Usar IP de red local (actualizar con `update-ip.ps1`)
- Archivos: `api_config.dart` y `fhir_service.dart` usan `kIsWeb` para detección automática

### Credenciales
- **Admin**: admin / admin123
- **BD**: admin / admin (localhost:5432/fhirdb)

## Comandos Principales

```powershell
# Backend
.\mvnw.cmd spring-boot:run -Pboot

# Frontend Web
cd flutter_frontend
flutter run -d chrome

# Tests
.\mvnw.cmd test -Dtest="AuthControllerTest,UserControllerTest"
cd flutter_frontend && flutter test

# Actualizar IP (móvil)
cd flutter_frontend
.\update-ip.ps1
```

## Endpoints Principales

- `POST /api/auth/login` - Login
- `POST /api/auth/signup` - Registro
- `GET /api/auth/validate` - Validar token
- `GET /api/users` - Listar usuarios (admin)
- `GET /fhir/Patient?_count=10` - Pacientes FHIR

## Problemas Resueltos

1. ✅ Maven Wrapper reparado (maven-wrapper.jar + mvnw.cmd)
2. ✅ Configuración dinámica de IP implementada
3. ✅ Tests corregidos (validateToken, toggleUserStatus)
4. ✅ Mocks corregidos (findById en lugar de existsById)

## Tests

- **Backend**: 23/23 ✅ (AuthController: 12, UserController: 11)
- **Frontend**: 25/25 ✅ (auth_service: 12, fhir_service: 11)

## Documentación

Para más detalles, consultar:
- **CONTEXTO_PARA_NUEVA_SESION.md** - Guía completa
- **DESARROLLO_COMPLETO.md** - Historia detallada
- **CHECKLIST_TRANSFERENCIA.md** - Setup en nueva laptop

## Notas al Desarrollar

- **Spring Controllers**: Usar métodos existentes (validateToken, toggleUserStatus)
- **Flutter Config**: Mantener detección `kIsWeb` para soporte multiplataforma
- **Tests**: Mockear con findById() cuando controller necesite objeto completo
- **Seguridad**: JWT secret y passwords son de desarrollo, cambiar en producción
