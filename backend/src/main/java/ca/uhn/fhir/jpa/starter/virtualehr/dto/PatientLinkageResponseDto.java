package ca.uhn.fhir.jpa.starter.virtualehr.dto;

public class PatientLinkageResponseDto {

    private String fhirPatientId;
    private String ehrId;
    private String linkageNamespace;
    private boolean linked;

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

    public String getLinkageNamespace() {
        return linkageNamespace;
    }

    public void setLinkageNamespace(String linkageNamespace) {
        this.linkageNamespace = linkageNamespace;
    }

    public boolean isLinked() {
        return linked;
    }

    public void setLinked(boolean linked) {
        this.linked = linked;
    }
}
