package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.rest.api.MethodOutcome;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import ca.uhn.fhir.rest.server.exceptions.UnprocessableEntityException;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.PatientLinkageResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.CreatePatientRequestDto;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.ZoneId;
import java.util.Date;
import java.util.UUID;
import org.hl7.fhir.instance.model.api.IIdType;
import org.hl7.fhir.r4.model.Enumerations;
import org.hl7.fhir.r4.model.Extension;
import org.hl7.fhir.r4.model.Address;
import org.hl7.fhir.r4.model.ContactPoint;
import org.hl7.fhir.r4.model.HumanName;
import org.hl7.fhir.r4.model.Patient;
import org.hl7.fhir.r4.model.StringType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class FhirPatientService {

    private static final String PATERNAL_LAST_NAME_URL =
        "http://hospital.com/fhir/StructureDefinition/paternal-last-name";
    private static final String MATERNAL_LAST_NAME_URL =
        "http://hospital.com/fhir/StructureDefinition/maternal-last-name";
    private static final String BLOOD_TYPE_URL =
        "http://hospital.com/fhir/StructureDefinition/blood-type";
    private static final String CLINICAL_ANTECEDENTS_URL =
        "http://hospital.com/fhir/StructureDefinition/clinical-antecedents";
    private static final String EHR_ID_URL =
        "http://hospital.com/fhir/StructureDefinition/ehr-id";
    private static final String EHR_LINKAGE_NAMESPACE_URL =
        "http://hospital.com/fhir/StructureDefinition/ehr-linkage-namespace";

    private final IGenericClient hapiFhirClient;

    public FhirPatientService(IGenericClient hapiFhirClient) {
        this.hapiFhirClient = hapiFhirClient;
    }

    public String createPatient(CreatePatientRequestDto request) {
        validatePatientRequest(request);
        String familyName = request.getEffectiveFamilyName();

        Patient patient = new Patient();
        patient.addIdentifier()
                .setUse(org.hl7.fhir.r4.model.Identifier.IdentifierUse.OFFICIAL)
                .setSystem("urn:oid:2.16.840.1.113883.2.10.1")
                .setValue(request.getIdentifier().trim());

        HumanName name = patient.addName();
        name.setFamily(familyName);
        name.addGiven(request.getGivenName());

        if (StringUtils.hasText(request.getPaternalLastName())) {
            addStringExtension(patient, PATERNAL_LAST_NAME_URL, request.getPaternalLastName());
        }
        if (StringUtils.hasText(request.getMaternalLastName())) {
            addStringExtension(patient, MATERNAL_LAST_NAME_URL, request.getMaternalLastName());
        }
        if (StringUtils.hasText(request.getBloodType())) {
            addStringExtension(patient, BLOOD_TYPE_URL, request.getBloodType());
        }
        if (StringUtils.hasText(request.getClinicalAntecedents())) {
            addStringExtension(patient, CLINICAL_ANTECEDENTS_URL, request.getClinicalAntecedents());
        }

        if (StringUtils.hasText(request.getPhone())) {
            patient.addTelecom()
                    .setSystem(ContactPoint.ContactPointSystem.PHONE)
                    .setValue(request.getPhone().trim())
                    .setUse(ContactPoint.ContactPointUse.MOBILE);
        }

        if (StringUtils.hasText(request.getEmail())) {
            patient.addTelecom()
                    .setSystem(ContactPoint.ContactPointSystem.EMAIL)
                    .setValue(request.getEmail().trim())
                    .setUse(ContactPoint.ContactPointUse.HOME);
        }

        Address address = null;
        if (StringUtils.hasText(request.getStreetAndNumber())
                || StringUtils.hasText(request.getColony())
                || StringUtils.hasText(request.getMunicipality())
                || StringUtils.hasText(request.getState())
                || StringUtils.hasText(request.getPostalCode())) {
            address = patient.addAddress();
            address.setUse(Address.AddressUse.HOME);
            if (StringUtils.hasText(request.getStreetAndNumber())) {
                address.addLine(request.getStreetAndNumber().trim());
            }
            if (StringUtils.hasText(request.getColony())) {
                address.setDistrict(request.getColony().trim());
            }
            if (StringUtils.hasText(request.getMunicipality())) {
                address.setCity(request.getMunicipality().trim());
            }
            if (StringUtils.hasText(request.getState())) {
                address.setState(request.getState().trim());
            }
            if (StringUtils.hasText(request.getPostalCode())) {
                address.setPostalCode(request.getPostalCode().trim());
            }
        }

        if (StringUtils.hasText(request.getGender())) {
            patient.setGender(Enumerations.AdministrativeGender.fromCode(request.getGender().toLowerCase()));
        }

        if (StringUtils.hasText(request.getBirthDate())) {
            try {
                LocalDate localDate = LocalDate.parse(request.getBirthDate());
                patient.setBirthDate(Date.from(localDate.atStartOfDay(ZoneId.systemDefault()).toInstant()));
            } catch (DateTimeParseException e) {
                throw new UnprocessableEntityException("birthDate must use format yyyy-MM-dd");
            }
        }

        MethodOutcome outcome = hapiFhirClient.create().resource(patient).execute();
        IIdType id = outcome.getId();
        if (id == null || id.getIdPart() == null) {
            throw new IllegalStateException("FHIR server did not return a Patient ID");
        }

        return id.getIdPart();
    }

    private void validatePatientRequest(CreatePatientRequestDto request) {
        if (request == null) {
            throw new UnprocessableEntityException("patient request is required");
        }

        if (!StringUtils.hasText(request.getIdentifier())) {
            throw new UnprocessableEntityException("identifier is required");
        }

        if (!StringUtils.hasText(request.getGivenName())) {
            throw new UnprocessableEntityException("givenName is required");
        }

        if (!StringUtils.hasText(request.getPaternalLastName())
                || !StringUtils.hasText(request.getMaternalLastName())) {
            throw new UnprocessableEntityException("paternalLastName and maternalLastName are required");
        }

        if (!StringUtils.hasText(request.getGender())) {
            throw new UnprocessableEntityException("gender is required");
        }

        if (!StringUtils.hasText(request.getBirthDate())) {
            throw new UnprocessableEntityException("birthDate is required");
        }

        if (!StringUtils.hasText(request.getState())
                || !StringUtils.hasText(request.getMunicipality())
                || !StringUtils.hasText(request.getStreetAndNumber())
                || !StringUtils.hasText(request.getPostalCode())) {
            throw new UnprocessableEntityException(
                    "state, municipality, streetAndNumber and postalCode are required");
        }

        validateEmail(request.getEmail());
        validatePhone(request.getPhone());
        validatePostalCode(request.getPostalCode());
        validateBloodType(request.getBloodType());
    }

    private void validateEmail(String email) {
        if (!StringUtils.hasText(email)) {
            return;
        }

        String normalizedEmail = email.trim();
        if (!normalizedEmail.matches("^[\\w.+-]+@([\\w-]+\\.)+[\\w-]{2,}$")) {
            throw new UnprocessableEntityException("email is invalid");
        }
    }

    private void validatePhone(String phone) {
        if (!StringUtils.hasText(phone)) {
            return;
        }

        String normalizedPhone = phone.trim();
        if (!normalizedPhone.matches("^[0-9]{10,15}$")) {
            throw new UnprocessableEntityException("phone is invalid");
        }
    }

    private void validatePostalCode(String postalCode) {
        if (!StringUtils.hasText(postalCode) || !postalCode.trim().matches("^[0-9]{5}$")) {
            throw new UnprocessableEntityException("postalCode must contain 5 digits");
        }
    }

    private void validateBloodType(String bloodType) {
        if (!StringUtils.hasText(bloodType)) {
            return;
        }

        String normalizedBloodType = bloodType.trim().toUpperCase();
        if (!normalizedBloodType.matches("^(A|B|AB|O)[+-]$")) {
            throw new UnprocessableEntityException("bloodType is invalid");
        }
    }

    public void deletePatient(String patientId) {
        hapiFhirClient.delete().resourceById("Patient", patientId).execute();
    }

    public void attachEhrLinkage(String patientId, UUID ehrId, String linkageNamespace) {
        Patient patient = hapiFhirClient.read()
                .resource(Patient.class)
                .withId(patientId)
                .execute();

        patient.getExtension().removeIf(extension ->
                EHR_ID_URL.equals(extension.getUrl()) || EHR_LINKAGE_NAMESPACE_URL.equals(extension.getUrl()));

        addStringExtension(patient, EHR_ID_URL, ehrId.toString());
        addStringExtension(patient, EHR_LINKAGE_NAMESPACE_URL, linkageNamespace);

        hapiFhirClient.update().resource(patient).execute();
    }

    public PatientLinkageResponseDto getPatientLinkage(String patientId) {
        Patient patient = hapiFhirClient.read()
                .resource(Patient.class)
                .withId(patientId)
                .execute();

        String ehrId = readStringExtension(patient, EHR_ID_URL);
        String linkageNamespace = readStringExtension(patient, EHR_LINKAGE_NAMESPACE_URL);

        PatientLinkageResponseDto response = new PatientLinkageResponseDto();
        response.setFhirPatientId(patientId);
        response.setEhrId(ehrId);
        response.setLinkageNamespace(linkageNamespace);
        response.setLinked(StringUtils.hasText(ehrId) && StringUtils.hasText(linkageNamespace));

        return response;
    }

    private String readStringExtension(Patient patient, String url) {
        return patient.getExtension().stream()
                .filter(extension -> url.equals(extension.getUrl()))
                .map(Extension::getValue)
                .filter(StringType.class::isInstance)
                .map(StringType.class::cast)
                .map(StringType::getValue)
                .filter(StringUtils::hasText)
                .findFirst()
                .orElse(null);
    }

    private void addStringExtension(Patient patient, String url, String value) {
        patient.addExtension(new Extension(url, new StringType(value.trim())));
    }
}
