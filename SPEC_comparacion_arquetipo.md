# Comparacion de Arquetipo

## Proposito
Comparar el formulario actual de pacientes contra la captura historica y dejar trazabilidad de lo que ya quedo integrado al MVP.

## Fuente de comparacion
- Captura actual implementada en el frontend Flutter.
- Lista de campos historicos documentados en `SPEC_requisitos.md`.

## Resultado ejecutivo
La captura actual ya cubre el arquetipo historico base y ademas separa los datos demograficos de los antecedentes clinicos generales, con validaciones acordes al alcance del MVP.

## Matriz de comparacion

| Campo historico | Estado actual | Observacion |
| --- | --- | --- |
| CURP | Integrado | Se captura como identificador principal y se valida formato de 18 caracteres |
| Nombre(s) | Integrado | Campo separado de apellidos |
| Apellido paterno | Integrado | Campo separado |
| Apellido materno | Integrado | Campo separado |
| Sexo | Integrado | Catalogo controlado |
| Fecha de nacimiento | Integrado | Se captura en formato yyyy-MM-dd |
| Tipo de sangre | Integrado | Catalogo controlado, opcional |
| Entidad federativa | Integrado | Campo separado en direccion |
| Municipio | Integrado | Campo separado en direccion |
| Codigo postal | Integrado | Validacion de 5 digitos |
| Calle y numero | Integrado | Campo separado en direccion |
| Colonia | Integrado | Campo separado en direccion |
| Telefono | Integrado | Validacion de longitud si se captura |
| Correo electronico | Integrado | Validacion de formato si se captura |
| Antecedentes clinicos generales | Integrado | Seccion independiente de los datos demograficos |

## Campos fuera de alcance
- No se agregan campos ajenos al alcance del MVP o al arquetipo documentado.

## Decision tecnica
- La captura historica fue absorbida al arquetipo actual sin romper el modelo universal de paciente.
- Los antecedentes clinicos generales quedan separados para mantener la division entre datos demograficos y datos clinicos.
- El tipo de sangre queda como campo opcional validado dentro del contrato actual.
