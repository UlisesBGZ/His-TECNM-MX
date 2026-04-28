# SPEC Tareas

## Proposito
Registrar las tareas activas y la secuencia de trabajo para el MVP, sin salir del stack definido por el proyecto.

## Regla de trabajo
- Los Specs en Markdown son la fuente de verdad.
- No proponer herramientas fuera del stack actual.
- Respetar la configuracion de VS Code del proyecto para ejecutar y depurar localmente.

## Tareas inmediatas
- T-01: Rescatar la captura de datos demograficos del semestre pasado e integrarla al nuevo arquetipo.
- T-02: Rescatar y adaptar antecedentes clinicos generales segun capturas aprobadas.
- T-03: Validar que los campos de registro cumplan la NOM-024-SSA3-2012 del expediente clinico electronico.
- T-04: Implementar registro universal de pacientes.
- T-05: Implementar creacion y seguimiento de encuentros con estado.
- T-06: Verificar el enlace entre el ID FHIR del paciente y el ID de EHRbase.
- T-07: Estandarizar la captura de recetas medicas con plantilla unica y mapeo FHIR MedicationRequest.
- T-08: Alinear captura de multiples medicamentos para un mismo paciente sin romper reglas normativas.

## Estado actual
- Completado: T-01 rescate de captura demografica del semestre pasado.
- Completado: T-02 rescate y adaptacion de antecedentes clinicos generales.
- Completado: T-03 validacion de campos contra NOM-024-SSA3-2012.
- Completado: T-04 registro universal de pacientes.
- Completado: T-05 creacion y seguimiento de encuentros con estado.
- Completado: T-06 verificacion de enlace FHIR-EHRbase.
- Completado: T-07 estandarizacion de receta medica.
- Completado: T-08 captura secuencial de multiples medicamentos con trazabilidad de grupo de receta.
- Siguiente paso activo: ampliar pruebas automatizadas del flujo de receta multiple.

## T-07 cerrado
- Plantilla normativa de receta definida en `SPEC_receta_normativa.md`.
- Frontend actualizado con campos estructurados y validaciones obligatorias de receta.
- Backend actualizado con interceptor para rechazar `MedicationRequest` incompleto o inconsistente.
- Validacion end-to-end completada con evidencia en `SPEC_validacion_receta_e2e.md`.

## T-08 cerrado
- El formulario permite captura secuencial para varios medicamentos del mismo paciente con accion "Guardar y agregar otro".
- Cada medicamento se almacena como `MedicationRequest` individual para mantener compatibilidad FHIR R4.
- Se agrega `groupIdentifier` para agrupar los medicamentos de una misma receta clinica.
- La lista de recetas muestra agrupacion visual por `groupIdentifier` para facilitar revision/edicion de recetas con multiples medicamentos.

## T-01 cerrado
- Comparacion del arquetipo historico contra el formulario actual documentada en `SPEC_comparacion_arquetipo.md`.
- Se confirma que los campos historicos ya estan integrados en el formulario actual.

## T-02 cerrado
- La seccion de antecedentes clinicos generales ya esta modelada como bloque independiente en el formulario actual.
- El campo `clinicalAntecedents` se conserva end-to-end en frontend, contrato y backend.
- La separacion entre datos demograficos y datos clinicos queda respetada en el MVP.

## Mapa de captura actual vs objetivo
### Lo que ya existe en el formulario actual
- Identificador.
- Nombre(s) y apellidos.
- Genero.
- Fecha de nacimiento.
- Telefono.
- Correo electronico.
- Direccion general.

### Lo que muestran las capturas del formulario anterior
- CURP.
- Nombre(s).
- Apellido paterno.
- Apellido materno.
- Sexo.
- Tipo de sangre.
- Entidad federativa.
- Municipio.
- Codigo postal.
- Calle y numero.
- Colonia.
- Telefono.
- Correo electronico.
- Seccion de antecedentes clinicos generales.

### Campo pendiente de definicion tecnica
- Tipo de sangre: modelado como extension estructurada FHIR para el alcance actual del MVP.

### Resultado de T-03
- CURP o identificador: requerido, 18 caracteres alfanumericos.
- Nombre(s): requerido.
- Apellido paterno y materno: requeridos y separados.
- Sexo: requerido con valor catalogado.
- Fecha de nacimiento: requerida con formato `yyyy-MM-dd`.
- Entidad federativa, municipio, codigo postal, calle y numero: requeridos.
- Telefono, correo electronico, colonia y tipo de sangre: opcionales con validacion si se capturan.
- Antecedentes clinicos generales: seccion separada y conservada fuera de los datos demograficos.

## Secuencia recomendada de ejecucion
1. Revisar el arquetipo actual y comparar con el formulario anterior.
2. Definir campos obligatorios, opcionales y de uso clinico.
3. Ajustar backend/modelos para reflejar el nuevo contrato.
4. Ajustar frontend para captura y validacion.
5. Probar el flujo completo de alta y encuentro.

## Criterios de cierre
- Los formularios nuevos reflejan el arquetipo acordado.
- El registro de paciente es universal y consultable por cualquier especialista autorizado.
- El encounter cambia de estado de forma coherente.
- El ID de EHRbase queda vinculado al paciente FHIR.
- No hay campos fuera de la NOM definida para el alcance del MVP.

## Pendientes de validacion
- Sin pendientes criticos abiertos para T-01 a T-08.
- Pendiente operativo: agregar pruebas automatizadas del flujo de receta multiple y agrupacion.