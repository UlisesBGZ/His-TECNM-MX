package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.FullPatientRecordResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.FullPatientRecordResponseDto.AntecedentesDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.FullPatientRecordResponseDto.ConsultaDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.FullPatientRecordResponseDto.SignosVitalesDto;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.hl7.fhir.r4.model.ContactPoint;
import org.hl7.fhir.r4.model.Extension;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.StringType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class FullPatientRecordService {

    private static final Logger log = LoggerFactory.getLogger(FullPatientRecordService.class);

    private static final String EHR_ID_URL =
            "http://hospital.com/fhir/StructureDefinition/ehr-id";
    private static final String BLOOD_TYPE_URL =
            "http://hospital.com/fhir/StructureDefinition/blood-type";

    private static final String AQL_ANTECEDENTES =
            "SELECT" +
            " c/content[openEHR-EHR-EVALUATION.family_history.v2]/data[at0001]/items[at0002]/value/value," +
            " c/content[openEHR-EHR-EVALUATION.social_summary.v1]/data[at0001]/items[at0002]/value/value," +
            " c/content[openEHR-EHR-EVALUATION.obstetric_summary.v1]/data[at0001]/items[at0025]/value/value" +
            " FROM EHR e[ehr_id/value='%s'] CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.health_summary.v1]";

    private static final String AQL =
            "SELECT c/uid/value, c/context/start_time/value," +
            " c/content[openEHR-EHR-EVALUATION.reason_for_encounter.v1]/data[at0001]/items[at0004]/value/value," +
            " c/content[openEHR-EHR-EVALUATION.problem_diagnosis.v1]/data[at0001]/items[at0002]/value/value," +
            " c/content[openEHR-EHR-OBSERVATION.blood_pressure.v2]/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.blood_pressure.v2]/data[at0001]/events[at0006]/data[at0003]/items[at0005]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.pulse.v2]/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.body_temperature.v2]/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.body_weight.v2]/data[at0002]/events[at0003]/data[at0001]/items[at0004]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.height.v2]/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude," +
            " c/content[openEHR-EHR-OBSERVATION.respiration.v2]/data[at0001]/events[at0002]/data[at0003]/items[at0004]/value/magnitude" +
            " FROM EHR e[ehr_id/value='%s'] CONTAINS COMPOSITION c[openEHR-EHR-COMPOSITION.encounter.v1] ORDER BY c/context/start_time/value DESC";

    private final IGenericClient hapiFhirClient;
    private final String ehrbaseUrl;
    private final String ehrbaseUsername;
    private final String ehrbasePassword;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public FullPatientRecordService(
            IGenericClient hapiFhirClient,
            @Value("${virtualehr.ehrbase.base-url:http://localhost:8081/ehrbase/}") String ehrbaseBaseUrl,
            @Value("${virtualehr.ehrbase.username:ehrbase}") String ehrbaseUsername,
            @Value("${virtualehr.ehrbase.password:ehrbase}") String ehrbasePassword) {
        this.hapiFhirClient = hapiFhirClient;
        String base = ehrbaseBaseUrl.endsWith("/") ? ehrbaseBaseUrl : ehrbaseBaseUrl + "/";
        this.ehrbaseUrl = base + "rest/openehr/v1/query/aql";
        this.ehrbaseUsername = ehrbaseUsername;
        this.ehrbasePassword = ehrbasePassword;
    }

    public FullPatientRecordResponseDto getFullRecord(String fhirPatientId) {
        Patient patient = hapiFhirClient.read().resource(Patient.class).withId(fhirPatientId).execute();

        FullPatientRecordResponseDto dto = new FullPatientRecordResponseDto();
        dto.setFhirPatientId(fhirPatientId);
        dto.setNombre(buildName(patient));
        dto.setGenero(traducirGenero(patient.getGender() != null ? patient.getGender().toCode() : null));
        dto.setFechaNacimiento(patient.getBirthDateElement().getValueAsString());
        dto.setTipoSangre(readExtension(patient, BLOOD_TYPE_URL));
        dto.setTelefono(getTelefono(patient, ContactPoint.ContactPointSystem.PHONE));
        dto.setEmail(getTelefono(patient, ContactPoint.ContactPointSystem.EMAIL));
        dto.setDireccion(buildDireccion(patient));

        String ehrId = readExtension(patient, EHR_ID_URL);
        dto.setEhrId(ehrId);
        dto.setEhrVinculado(StringUtils.hasText(ehrId));

        if (StringUtils.hasText(ehrId)) {
            dto.setConsultas(fetchConsultas(ehrId));
            dto.setAntecedentes(fetchAntecedentes(ehrId));
        }

        return dto;
    }

    private List<ConsultaDto> fetchConsultas(String ehrId) {
        List<ConsultaDto> result = new ArrayList<>();
        String query = String.format(AQL, ehrId);
        String body = "{\"q\": " + objectMapper.createObjectNode().put("q", query).get("q").toString() + "}";

        String credentials = Base64.getEncoder()
                .encodeToString((ehrbaseUsername + ":" + ehrbasePassword).getBytes(StandardCharsets.UTF_8));

        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(ehrbaseUrl);
            post.setHeader("Content-Type", "application/json");
            post.setHeader("Accept", "application/json");
            post.setHeader("Authorization", "Basic " + credentials);
            post.setEntity(new StringEntity("{\"q\":\"" + query.replace("\"", "\\\"") + "\"}", StandardCharsets.UTF_8));

            try (CloseableHttpResponse resp = client.execute(post)) {
                String json = EntityUtils.toString(resp.getEntity());
                JsonNode root = objectMapper.readTree(json);
                JsonNode rows = root.path("rows");
                for (JsonNode row : rows) {
                    result.add(mapRow(row));
                }
            }
        } catch (Exception e) {
            log.warn("Error al consultar composiciones en EHRbase para EHR {}: {}", ehrId, e.getMessage());
        }
        return result;
    }

    private AntecedentesDto fetchAntecedentes(String ehrId) {
        AntecedentesDto dto = new AntecedentesDto();
        String query = String.format(AQL_ANTECEDENTES, ehrId);
        String credentials = Base64.getEncoder()
                .encodeToString((ehrbaseUsername + ":" + ehrbasePassword).getBytes(StandardCharsets.UTF_8));

        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpPost post = new HttpPost(ehrbaseUrl);
            post.setHeader("Content-Type", "application/json");
            post.setHeader("Accept", "application/json");
            post.setHeader("Authorization", "Basic " + credentials);
            post.setEntity(new StringEntity("{\"q\":\"" + query.replace("\"", "\\\"") + "\"}", StandardCharsets.UTF_8));

            try (CloseableHttpResponse resp = client.execute(post)) {
                String json = EntityUtils.toString(resp.getEntity());
                JsonNode rows = objectMapper.readTree(json).path("rows");
                for (JsonNode row : rows) {
                    if (dto.getHeredofamiliar() == null) dto.setHeredofamiliar(textOrNull(row, 0));
                    if (dto.getNoPatologico() == null)   dto.setNoPatologico(textOrNull(row, 1));
                    if (dto.getGinecoObstetrico() == null) dto.setGinecoObstetrico(textOrNull(row, 2));
                    if (dto.getHeredofamiliar() != null && dto.getNoPatologico() != null && dto.getGinecoObstetrico() != null) break;
                }
            }
        } catch (Exception e) {
            log.warn("Error al consultar antecedentes en EHRbase para EHR {}: {}", ehrId, e.getMessage());
        }
        return dto;
    }

    private ConsultaDto mapRow(JsonNode row) {
        ConsultaDto c = new ConsultaDto();
        c.setComposicionId(textOrNull(row, 0));
        c.setFecha(textOrNull(row, 1));
        c.setMotivoConsulta(textOrNull(row, 2));
        c.setDiagnostico(textOrNull(row, 3));

        SignosVitalesDto sv = new SignosVitalesDto();
        sv.setPresionSistolica(doubleOrNull(row, 4));
        sv.setPresionDiastolica(doubleOrNull(row, 5));
        sv.setPulso(doubleOrNull(row, 6));
        sv.setTemperatura(doubleOrNull(row, 7));
        sv.setPeso(doubleOrNull(row, 8));
        sv.setTalla(doubleOrNull(row, 9));
        sv.setFrecuenciaRespiratoria(doubleOrNull(row, 10));
        c.setSignosVitales(sv);

        return c;
    }

    private String textOrNull(JsonNode row, int index) {
        JsonNode node = row.get(index);
        return (node == null || node.isNull()) ? null : node.asText();
    }

    private Double doubleOrNull(JsonNode row, int index) {
        JsonNode node = row.get(index);
        return (node == null || node.isNull()) ? null : node.asDouble();
    }

    private String buildName(Patient patient) {
        if (patient.hasName()) {
            var name = patient.getNameFirstRep();
            List<String> parts = new ArrayList<>();
            name.getGiven().stream()
                    .map(g -> g.getValue().trim())
                    .filter(StringUtils::hasText)
                    .forEach(parts::add);
            if (StringUtils.hasText(name.getFamily())) parts.add(name.getFamily().trim());
            return String.join(" ", parts);
        }
        return null;
    }

    private String buildDireccion(Patient patient) {
        if (!patient.hasAddress()) return null;
        var addr = patient.getAddressFirstRep();
        List<String> parts = new ArrayList<>();
        addr.getLine().forEach(l -> parts.add(l.getValue()));
        if (StringUtils.hasText(addr.getDistrict())) parts.add(addr.getDistrict());
        if (StringUtils.hasText(addr.getCity())) parts.add(addr.getCity());
        if (StringUtils.hasText(addr.getState())) parts.add(addr.getState());
        if (StringUtils.hasText(addr.getPostalCode())) parts.add(addr.getPostalCode());
        return String.join(", ", parts);
    }

    private String getTelefono(Patient patient, ContactPoint.ContactPointSystem system) {
        return patient.getTelecom().stream()
                .filter(t -> system.equals(t.getSystem()))
                .map(ContactPoint::getValue)
                .findFirst().orElse(null);
    }

    private String traducirGenero(String fhirGender) {
        if (fhirGender == null) return null;
        return switch (fhirGender) {
            case "male"    -> "Masculino";
            case "female"  -> "Femenino";
            case "other"   -> "Otro";
            case "unknown" -> "Desconocido";
            default        -> fhirGender;
        };
    }

    private String readExtension(Patient patient, String url) {
        return patient.getExtension().stream()
                .filter(e -> url.equals(e.getUrl()))
                .map(Extension::getValue)
                .filter(StringType.class::isInstance)
                .map(v -> ((StringType) v).getValue())
                .filter(StringUtils::hasText)
                .findFirst().orElse(null);
    }
}
