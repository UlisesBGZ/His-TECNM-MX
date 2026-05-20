package ca.uhn.fhir.jpa.starter.virtualehr.controller;

import ca.uhn.fhir.jpa.starter.virtualehr.dto.CompositionResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.CreatePatientRequestDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.FullPatientRecordResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.PatientLinkageResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.SaveAntecedentesCompositionRequestDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.SaveEncounterCompositionRequestDto;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.UnifiedPatientRecordResponseDto;
import ca.uhn.fhir.jpa.starter.virtualehr.service.EhrbaseAntecedentesService;
import ca.uhn.fhir.jpa.starter.virtualehr.service.EhrbaseCompositionService;
import ca.uhn.fhir.jpa.starter.virtualehr.service.FullPatientRecordService;
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
    private final EhrbaseCompositionService ehrbaseCompositionService;
    private final EhrbaseAntecedentesService ehrbaseAntecedentesService;
    private final FullPatientRecordService fullPatientRecordService;

    public VirtualEhrPatientController(
            PatientOrchestratorService patientOrchestratorService,
            EhrbaseCompositionService ehrbaseCompositionService,
            EhrbaseAntecedentesService ehrbaseAntecedentesService,
            FullPatientRecordService fullPatientRecordService) {
        this.patientOrchestratorService = patientOrchestratorService;
        this.ehrbaseCompositionService = ehrbaseCompositionService;
        this.ehrbaseAntecedentesService = ehrbaseAntecedentesService;
        this.fullPatientRecordService = fullPatientRecordService;
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

    @PostMapping("/{fhirPatientId}/ehr-composition")
    public ResponseEntity<CompositionResponseDto> saveEncounterComposition(
            @PathVariable("fhirPatientId") String fhirPatientId,
            @RequestBody SaveEncounterCompositionRequestDto request) {
        String compositionId = ehrbaseCompositionService.saveConsultaClinica(request);
        CompositionResponseDto response = new CompositionResponseDto(
                compositionId,
                request.getFhirEncounterId(),
                request.getEhrId(),
                "consulta_clinica");
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/{fhirPatientId}/antecedentes-composition")
    public ResponseEntity<CompositionResponseDto> saveAntecedentesComposition(
            @PathVariable("fhirPatientId") String fhirPatientId,
            @RequestBody SaveAntecedentesCompositionRequestDto request) {
        String compositionId = ehrbaseAntecedentesService.saveAntecedente(request);
        CompositionResponseDto response = new CompositionResponseDto(
                compositionId,
                null,
                request.getEhrId(),
                "antecedentes_clinicos");
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{fhirPatientId}/full-record")
    public ResponseEntity<FullPatientRecordResponseDto> getFullRecord(
            @PathVariable("fhirPatientId") String fhirPatientId) {
        FullPatientRecordResponseDto response = fullPatientRecordService.getFullRecord(fhirPatientId);
        return ResponseEntity.ok(response);
    }
}
