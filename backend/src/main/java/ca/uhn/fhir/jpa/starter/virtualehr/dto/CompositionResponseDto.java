package ca.uhn.fhir.jpa.starter.virtualehr.dto;

public class CompositionResponseDto {

    private String compositionId;
    private String fhirEncounterId;
    private String ehrId;
    private String templateId;

    public CompositionResponseDto(String compositionId, String fhirEncounterId, String ehrId, String templateId) {
        this.compositionId = compositionId;
        this.fhirEncounterId = fhirEncounterId;
        this.ehrId = ehrId;
        this.templateId = templateId;
    }

    public String getCompositionId() { return compositionId; }
    public String getFhirEncounterId() { return fhirEncounterId; }
    public String getEhrId() { return ehrId; }
    public String getTemplateId() { return templateId; }
}
