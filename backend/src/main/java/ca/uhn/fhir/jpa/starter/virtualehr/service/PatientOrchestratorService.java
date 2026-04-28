package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.jpa.starter.virtualehr.dto.CreatePatientRequestDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.PatientLinkageResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.UnifiedPatientRecordResponseDto;
import java.util.UUID;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PatientOrchestratorService {

    private final FhirPatientService fhirPatientService;
    private final EhrbaseEhrService ehrbaseEhrService;

    public PatientOrchestratorService(
            FhirPatientService fhirPatientService,
            EhrbaseEhrService ehrbaseEhrService) {
        this.fhirPatientService = fhirPatientService;
        this.ehrbaseEhrService = ehrbaseEhrService;
    }

    @Transactional
    public UnifiedPatientRecordResponseDto createUnifiedPatientRecord(CreatePatientRequestDto request) {
        String fhirPatientId = fhirPatientService.createPatient(request);
        String displayName = request.getGivenName();
        String familyName = request.getEffectiveFamilyName();
        if (familyName != null && !familyName.isBlank()) {
            displayName = displayName + " " + familyName;
        }

        try {
            UUID ehrId = ehrbaseEhrService.createLinkedEhr(fhirPatientId);
            fhirPatientService.attachEhrLinkage(
                fhirPatientId,
                ehrId,
                ehrbaseEhrService.getLinkageNamespace());

            return new UnifiedPatientRecordResponseDto(
                    fhirPatientId,
                    ehrId.toString(),
                    displayName,
                    ehrbaseEhrService.getLinkageNamespace());
        } catch (Exception ex) {
            try {
                fhirPatientService.deletePatient(fhirPatientId);
            } catch (Exception compensationEx) {
                throw new IllegalStateException(
                        "EHRbase creation failed and FHIR compensation also failed. Manual reconciliation required.",
                        compensationEx);
            }

            throw new IllegalStateException(
                    "EHRbase creation failed. FHIR Patient was compensated (deleted).", ex);
        }
    }

    public PatientLinkageResponseDto getPatientLinkage(String fhirPatientId) {
        return fhirPatientService.getPatientLinkage(fhirPatientId);
    }
}
