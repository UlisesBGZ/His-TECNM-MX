# SPEC Flutter

## Stack
- Flutter 3.x / Dart 3.x
- Provider para estado
- http para consumo API
- shared_preferences para token/sesion
- Material 3 para UI

## Estructura base
- lib/config: configuracion de endpoints.
- lib/models: modelos de datos.
- lib/services: llamadas HTTP y parseo.
- lib/providers: estado global de autenticacion.
- lib/screens: UI por modulo.

## Responsabilidades
- Mostrar interfaz por rol.
- Gestionar sesion (login/logout, lectura de token, validacion de token en inicio).
- Consumir endpoints de auth/users/FHIR.
- Manejar errores de red y permisos con mensajes claros.

## Ejecucion
- Desarrollo rapido: usar scripts .bat del root.
- Manual:
  - flutter pub get
  - flutter run -d chrome

## Testing
- flutter test
- Enfoque actual: servicios y widgets principales.
