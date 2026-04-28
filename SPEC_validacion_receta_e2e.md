# Validacion E2E Receta Estandarizada

## Proposito
Documentar evidencia de ejecucion end-to-end del flujo de receta estandarizada (T-07) sobre backend en ejecucion real.

## Fecha
- 2026-04-15

## Entorno de prueba
- Backend local: http://localhost:8080
- FHIR endpoint: /fhir
- Autenticacion: JWT (`/api/auth/login`)
- Usuario de prueba: admin

## Casos ejecutados

### Caso 1: Login y obtencion de token
- Entrada: username/password validos.
- Resultado esperado: token JWT emitido.
- Resultado observado: `TOKEN_OK`.

### Caso 2: Creacion de receta valida
- Recurso: `MedicationRequest`.
- Datos clave enviados:
  - `status=active`
  - `intent=order`
  - `subject.reference=Patient/1052`
  - `requester.reference=Practitioner/1301`
  - `authoredOn` con fecha valida
  - `medicationCodeableConcept.text` con medicamento + presentacion
  - `dosageInstruction[0].text` presente
  - `dispenseRequest.quantity.value=10`
- Resultado esperado: creado (HTTP 201).
- Resultado observado: `VALID_STATUS=201`.

### Caso 3: Rechazo de receta invalida
- Recurso: `MedicationRequest` sin `dosageInstruction.text`.
- Resultado esperado: rechazo por validacion.
- Resultado observado: `INVALID_STATUS=422`.
- Diagnostico devuelto:
  - `MedicationRequest requires dosageInstruction.text`

## Evidencia tecnica resumida
- `PATIENT_ID=1052`
- `PRACTITIONER_ID=1301`
- `VALID_STATUS=201`
- `INVALID_STATUS=422`

## Conclusion
El flujo de receta estandarizada cumple la validacion minima definida:
- Acepta payload completo y consistente.
- Rechaza payload incompleto con `OperationOutcome` explicito.
- Se confirma la aplicacion efectiva de la validacion normativa en backend.
