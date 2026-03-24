package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.rest.api.MethodOutcome;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.rest.server.exceptions.UnprocessableEntityException;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.CreatePatientRequestDto;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;
import org.hl7.fhir.instance.model.api.IIdType;
import org.hl7.fhir.r4.model.Enumerations;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.Patient;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class FhirPatientService {

    private final IGenericClient hapiFhirClient;

    public FhirPatientService(IGenericClient hapiFhirClient) {
        this.hapiFhirClient = hapiFhirClient;
    }

    public String createPatient(CreatePatientRequestDto request) {
        if (!StringUtils.hasText(request.getGivenName()) || !StringUtils.hasText(request.getFamilyName())) {
            throw new UnprocessableEntityException("givenName and familyName are required");
        }

        Patient patient = new Patient();
        HumanName name = patient.addName();
        name.setFamily(request.getFamilyName());
        name.addGiven(request.getGivenName());

        if (StringUtils.hasText(request.getGender())) {
            patient.setGender(Enumerations.AdministrativeGender.fromCode(request.getGender().toLowerCase()));
        }

        if (StringUtils.hasText(request.getBirthDate())) {
            LocalDate localDate = LocalDate.parse(request.getBirthDate());
            patient.setBirthDate(Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant()));
        }

        MethodOutcome outcome = hapiFhirClient.create().resource(patient).execute();
        IIdType id = outcome.getId();
        if (id == null || id.getIdPart() == null) {
            throw new IllegalStateException("FHIR server did not return a Patient ID");
        }

        return id.getIdPart();
    }

    public void deletePatient(String patientId) {
        hapiFhirClient.delete().resourceById("Patient", patientId).execute();
    }
}
