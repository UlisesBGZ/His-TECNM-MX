# SPEC Flutter

## Proposito
Definir la arquitectura del cliente Flutter y sus contratos de integracion con backend.

## Stack
- Flutter: objetivo 3.27.3.
- Dart: objetivo 3.6.1 (pubspec: `>=3.0.0 <4.0.0`).
- Provider: ^6.1.1.
- http: ^1.2.0.
- shared_preferences: ^2.2.2.
- Material 3 + `google_fonts` ^6.1.0.
- Soporte i18n base: `flutter_localizations` + `intl` ^0.19.0.

## Estructura
- `lib/config`: endpoints y configuracion de red.
- `lib/models`: DTOs/modelos de UI.
- `lib/services`: cliente HTTP y parseo.
- `lib/providers`: estado de autenticacion/sesion.
- `lib/screens`: presentacion por modulo.

## Responsabilidades funcionales
- Renderizar UI por rol.
- Gestionar login/logout y token local.
- Validar sesion al iniciar app.
- Consumir `/api/auth`, `/api/users`, `/fhir`, `/api/virtual-ehr`.
- Traducir errores de red/permisos a mensajes accionables.

## Contratos tecnicos
- Header requerido en rutas protegidas: `Authorization: Bearer <token>`.
- Formato esperado backend custom: JSON.
- Errores HTTP 401/403: mostrar mensaje funcional y forzar flujo de reautenticacion.

## Reglas de implementacion
- Separar logica de red (services) de presentacion (screens).
- Evitar acoplar widgets a detalles HTTP.
- Mantener estados explicitos: loading/error/data/empty.
- Evitar almacenamiento de secretos fuera de mecanismos definidos por la app.

## Ejecucion y calidad
- Ejecucion rapida: scripts `.bat` del root.
- Ejecucion manual: `flutter pub get` + `flutter run -d chrome`.
- Validacion: `flutter test` y `flutter analyze`.

## Criterios de calidad
- Compila y corre en web sin errores bloqueantes.
- Tests de servicios y widgets en verde.
- Navegacion por rol y manejo de sesion consistentes con backend.
