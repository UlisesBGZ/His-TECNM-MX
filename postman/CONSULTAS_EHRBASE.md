# Consultas EHRbase — Guía rápida

## 1. Abre Swagger

Navega a: `http://localhost:8081/ehrbase/swagger-ui/index.html`

Usuario: `ehrbase` | Contraseña: `ehrbase`

---

## 2. Obtén el ehrId del paciente

En la app Flutter, abre el expediente del paciente → busca el campo **EHR ID** en sus datos.

O desde Postman: **Virtual EHR (Linkage)** → **Verificar linkage FHIR ↔ EHR** con el ID del paciente.

---

## 3. Consultas AQL

En Swagger: sección **query** → **POST /query/aql** → **Try it out**

Cambia el content-type a `application/json` y pega el body.

---

### Ver todos los EHRs registrados

```json
{
  "q": "SELECT e/ehr_id/value, e/time_created/value FROM EHR e"
}
```

---

### Ver composiciones de un paciente

Reemplaza el UUID por el ehrId del paciente:

```json
{
  "q": "SELECT c/uid/value, c/name/value FROM EHR e[ehr_id/value='PEGA-EHR-ID-AQUI'] CONTAINS COMPOSITION c"
}
```

Ejemplo real:
```json
{
  "q": "SELECT c/uid/value, c/name/value FROM EHR e[ehr_id/value='b073a7b9-7cd8-46e5-beec-d13be9d795bd'] CONTAINS COMPOSITION c"
}
```

---

### Ver todo de un paciente (composiciones + fecha + diagnóstico + motivo)

```json
{
  "q": "SELECT c/uid/value, c/context/start_time/value AS fecha, c/content[openEHR-EHR-EVALUATION.reason_for_encounter.v1]/data[at0001]/items[at0002]/value/value AS motivo, c/content[openEHR-EHR-EVALUATION.problem_diagnosis.v1]/data[at0001]/items[at0002]/value/value AS diagnostico FROM EHR e[ehr_id/value='PEGA-EHR-ID-AQUI'] CONTAINS COMPOSITION c"
}
```

---

### Buscar a qué paciente FHIR pertenece un EHR

```json
{
  "q": "SELECT e/ehr_id/value, e/ehr_status/subject/external_ref/id/value AS fhir_patient_id FROM EHR e[ehr_id/value='PEGA-EHR-ID-AQUI']"
}
```

Con el `fhir_patient_id` que devuelve, búscalo en FHIR:
`http://localhost:8080/fhir/Patient/FHIR-PATIENT-ID`

---

### Ver signos vitales de un paciente

```json
{
  "q": "SELECT c/uid/value, c/content[openEHR-EHR-OBSERVATION.blood_pressure.v2]/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude AS sistolica, c/content[openEHR-EHR-OBSERVATION.blood_pressure.v2]/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude AS diastolica FROM EHR e[ehr_id/value='PEGA-EHR-ID-AQUI'] CONTAINS COMPOSITION c"
}
```

---

### Ver diagnósticos de un paciente

```json
{
  "q": "SELECT c/content[openEHR-EHR-EVALUATION.problem_diagnosis.v1]/data[at0001]/items[at0002]/value/value AS diagnostico, c/context/start_time/value AS fecha FROM EHR e[ehr_id/value='PEGA-EHR-ID-AQUI'] CONTAINS COMPOSITION c"
}
```

---

## 4. Resultado esperado

Si `resultsize` es mayor a 0, los datos están guardados correctamente en EHRbase.
