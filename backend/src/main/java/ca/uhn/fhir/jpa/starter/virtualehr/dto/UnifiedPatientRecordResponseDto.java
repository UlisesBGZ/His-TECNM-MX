package ca.uhn.fhir.jpa.starter.virtualehr.dto;

public class UnifiedPatientRecordResponseDto {

    private String fhirPatientId;
    private String ehrId;
    private String fullName;
    private String linkageNamespace;

    public UnifiedPatientRecordResponseDto() {
    }

    public UnifiedPatientRecordResponseDto(
            String fhirPatientId, String ehrId, String fullName, String linkageNamespace) {
        this.fhirPatientId = fhirPatientId;
        this.ehrId = ehrId;
        this.fullName = fullName;
        this.linkageNamespace = linkageNamespace;
    }

    public String getFhirPatientId() {
        return fhirPatientId;
    }

    public void setFhirPatientId(String fhirPatientId) {
        this.fhirPatientId = fhirPatientId;
    }

    public String getEhrId() {
        return ehrId;
    }

    public void setEhrId(String ehrId) {
        this.ehrId = ehrId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getLinkageNamespace() {
        return linkageNamespace;
    }

    public void setLinkageNamespace(String linkageNamespace) {
        this.linkageNamespace = linkageNamespace;
    }
}
