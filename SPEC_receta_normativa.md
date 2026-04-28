# SPEC Receta Normativa

## Proposito
Definir una plantilla unica para captura de receta medica en el MVP, con validaciones minimas y mapeo consistente a HL7 FHIR R4 (`MedicationRequest`).

## Referencia normativa aplicada en este alcance
- NOM-004-SSA3-2012: documentacion de prescripcion dentro del expediente clinico.
- NOM-024-SSA3-2012: requisitos de sistema de expediente clinico electronico (estructura, trazabilidad y seguridad).
- Reglamento de Insumos para la Salud: reglas de prescripcion y dispensacion para medicamentos en Mexico.
- Nota de alcance: para psicotropicos/estupefacientes se requiere flujo adicional regulatorio fuera del MVP actual.

## Plantilla unica de receta

### Campos obligatorios
- Paciente: referencia valida a paciente institucional.
- Medicamento (nombre generico): texto no vacio.
- Presentacion y concentracion: texto no vacio.
- Dosis e instrucciones: texto no vacio y accionable para el paciente.
- Cantidad total a surtir: entero mayor que 0.
- Fecha de prescripcion: fecha valida (por defecto fecha actual).
- Prescriptor: referencia valida al profesional autenticado.
- Estado de receta: `draft`, `active`, `on-hold`, `cancelled`, `completed`.

### Campos recomendados
- Via de administracion.
- Frecuencia.
- Duracion (dias de tratamiento).
- Diagnostico o motivo terapeutico.
- Indicaciones adicionales al paciente.

### Campos opcionales
- Notas clinicas adicionales.

## Reglas de validacion funcional
- No permitir guardar receta sin paciente seleccionado.
- No permitir guardar receta sin medicamento.
- No permitir guardar receta sin dosis/instrucciones.
- Cantidad debe ser numerica y mayor a 0.
- Si se captura duracion, debe ser numerica y mayor a 0.
- Estado inicial recomendado: `active` o `draft`.
- Si estado es `completed` o `cancelled`, bloquear edicion de dosis/cantidad y permitir solo trazabilidad.
- Para receta con multiples medicamentos, registrar un `MedicationRequest` por medicamento.
- Si una receta clinica incluye multiples medicamentos, agruparlos con `groupIdentifier` compartido.

## Mapeo FHIR R4 (MedicationRequest)
- `resourceType`: `MedicationRequest`.
- `status`: estado de receta.
- `intent`: `order`.
- `subject.reference`: `Patient/{id}`.
- `requester.reference`: `Practitioner/{id}`.
- `authoredOn`: fecha de prescripcion.
- `medicationCodeableConcept.text`: nombre generico + presentacion/concentracion.
- `dosageInstruction[0].text`: dosis + via + frecuencia + instrucciones.
- `dispenseRequest.quantity.value`: cantidad total.
- `dispenseRequest.expectedSupplyDuration.value`: duracion en dias (si aplica).
- `note[0].text`: notas/indicaciones adicionales.
- `groupIdentifier.value`: identificador comun cuando hay varios medicamentos en una misma receta clinica.

## Manejo de multiples medicamentos
- Regla principal: en FHIR R4, cada medicamento prescrito se representa como un `MedicationRequest` independiente.
- Flujo UI recomendado: capturar medicamento 1, guardar, y continuar con "Guardar y agregar otro" para el mismo paciente.
- Trazabilidad: todos los medicamentos de la misma receta deben compartir `groupIdentifier`.
- Visualizacion recomendada: mostrar agrupacion en listado por `groupIdentifier` para revisar la receta completa sin perder el detalle por medicamento.
- Beneficio: se conserva validacion normativa minima por medicamento y se evita mezclar dosis/cantidades de farmacos distintos en un solo recurso.

## Convenciones de captura recomendadas
- Medicamento: usar denominacion generica en primer termino.
- Estructura de dosis sugerida: "<cantidad por toma> cada <intervalo> via <ruta> por <dias>".
- Cantidad total debe ser coherente con frecuencia y duracion para evitar sub/sobre surtido.

## Criterios de aceptacion
- El formulario de receta solo permite guardar cuando cumple los obligatorios.
- El backend rechaza payload incompleto o inconsistente de receta.
- Toda receta creada incluye paciente, prescriptor, fecha y estado.
- El recurso FHIR resultante valida como `MedicationRequest` y conserva trazabilidad.
- En una receta con multiples medicamentos, cada item se almacena de forma independiente y queda ligado por `groupIdentifier`.

## Fuera de alcance en esta fase
- Receta electronica avanzada con firma digital certificada.
- Flujos regulatorios especiales para controlados.
- Integracion directa con sistemas externos de farmacia.
