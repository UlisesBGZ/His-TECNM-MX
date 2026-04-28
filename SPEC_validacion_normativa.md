# Validacion Normativa

## Proposito
Dejar trazabilidad de los campos de captura y su estado de validacion respecto al alcance actual del MVP.

## Nota de alcance
La referencia aplicada en este alcance es la NOM-024-SSA3-2012 para expediente clinico electronico. Si el proyecto requiere una version o complemento distinto, esta matriz debe actualizarse.

## Matriz de campos

| Campo | Estado | Regla aplicada | Observacion |
| --- | --- | --- | --- |
| CURP / identificador | Requerido | 18 caracteres alfanumericos, normalizado a mayusculas | Acepta CURP institucional en el flujo actual |
| Nombre(s) | Requerido | No vacio | |
| Apellido paterno | Requerido | No vacio | |
| Apellido materno | Requerido | No vacio | |
| Sexo | Requerido | Valor catalogado | male, female, other, unknown |
| Fecha de nacimiento | Requerido | Formato yyyy-MM-dd | |
| Tipo de sangre | Opcional | Catalogo A+, A-, B+, B-, AB+, AB-, O+, O- | Pendiente de definir si se modela como dato estructurado o clinico |
| Entidad federativa | Requerido | No vacio | |
| Municipio | Requerido | No vacio | |
| Codigo postal | Requerido | 5 digitos | |
| Calle y numero | Requerido | No vacio | |
| Colonia | Opcional | No vacio si se captura | |
| Telefono | Opcional | 10 a 15 digitos si se captura | |
| Correo electronico | Opcional | Formato de email valido si se captura | |
| Antecedentes clinicos generales | Opcional | Texto libre | Se conserva separado de los datos demograficos |

## Resultado de implementacion
- El frontend valida los campos principales antes de guardar.
- El backend rechaza cargas incompletas o con formato invalido.
- El registro de paciente sigue siendo universal y el alta unificada conserva el vinculo FHIR-EHRbase.
- La validacion actual queda alineada a NOM-024-SSA3-2012 dentro del alcance del MVP.
