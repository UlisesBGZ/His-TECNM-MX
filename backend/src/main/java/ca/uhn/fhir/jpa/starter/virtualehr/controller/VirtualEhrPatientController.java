package ca.uhn.fhir.jpa.starter.virtualehr.controller;

import ca.uhn.fhir.jpa.starter.virtualehr.dto.CreatePatientRequestDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.PatientLinkageResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.UnifiedPatientRecordResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.service.PatientOrchestratorService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/virtual-ehr/patients")
@CrossOrigin(origins = "*", maxAge = 3600)
public class VirtualEhrPatientController {

    private final PatientOrchestratorService patientOrchestratorService;

    public VirtualEhrPatientController(PatientOrchestratorService patientOrchestratorService) {
        this.patientOrchestratorService = patientOrchestratorService;
    }

    @PostMapping
    public ResponseEntity<UnifiedPatientRecordResponseDto> createPatient(@RequestBody CreatePatientRequestDto request) {
        UnifiedPatientRecordResponseDto response = patientOrchestratorService.createUnifiedPatientRecord(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{fhirPatientId}/linkage")
    public ResponseEntity<PatientLinkageResponseDto> getPatientLinkage(
            @PathVariable("fhirPatientId") String fhirPatientId) {
        PatientLinkageResponseDto response = patientOrchestratorService.getPatientLinkage(fhirPatientId);
        return ResponseEntity.ok(response);
    }
}
