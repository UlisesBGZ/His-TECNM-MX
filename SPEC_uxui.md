# SPEC UX/UI

## Objetivo
Permitir operacion clinica y administrativa con friccion minima, mensajes claros y navegacion por rol.

## Base tecnologica UX
- UI framework: Flutter Material 3.
- Estado de UI: Provider.
- Persistencia de sesion en cliente: shared_preferences.
- Comunicacion: HTTP JSON hacia `/api/auth`, `/api/users`, `/fhir`, `/api/virtual-ehr`.

## Usuarios objetivo
- Admin: gestiona usuarios y configuracion operativa.
- Usuario clinico: opera modulos de pacientes, encuentros clinicos y expediente clinico.

## Flujos criticos
- UX-01 Login: ingreso, error de credenciales y estado de carga visibles.
- UX-02 Home por rol: acceso solo a modulos permitidos.
- UX-03 CRUD: listar, crear, editar y eliminar con confirmaciones.
- UX-04 Error de sesion: informar expiracion/permisos y reautenticacion.

## Reglas UX
- Mensajes accionables, sin exponer trazas tecnicas.
- Estados obligatorios por pantalla: cargando, vacio, error, exito.
- Confirmacion previa en acciones destructivas.
- Consistencia en labels, botones y feedback visual.
- Errores de autenticacion/permisos deben guiar a re-login.

## Criterios de aceptacion UX
- CA-UX-01: un usuario identifica su siguiente accion en cada pantalla.
- CA-UX-02: errores muestran causa funcional y accion sugerida.
- CA-UX-03: no hay rutas administrativas visibles para roles no admin.
- CA-UX-04: al expirar sesion, la app informa y redirige a autenticacion.
- CA-UX-05: operaciones CRUD muestran confirmacion o error controlado en menos de un flujo de pantalla.

## Accesibilidad minima
- Contraste legible en textos y acciones principales.
- Controles tactiles con tamano adecuado.
- Estados de error perceptibles y comprensibles.

## No objetivo UX en esta fase
- Personalizacion avanzada por perfil.
- Internacionalizacion multiidioma completa.
