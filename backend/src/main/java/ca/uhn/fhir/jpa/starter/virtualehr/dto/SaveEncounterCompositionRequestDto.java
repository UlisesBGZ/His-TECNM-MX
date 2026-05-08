package ca.uhn.fhir.jpa.starter.virtualehr.dto;

public class SaveEncounterCompositionRequestDto {

    private String ehrId;
    private String fhirEncounterId;
    private String motivoConsulta;
    private String padecimientoActual;
    private String diagnostico;
    private Double presionSistolica;
    private Double presionDiastolica;
    private Double pulso;
    private Double temperatura;
    private Double peso;
    private Double talla;
    private Double frecuenciaRespiratoria;

    public String getEhrId() { return ehrId; }
    public void setEhrId(String ehrId) { this.ehrId = ehrId; }

    public String getFhirEncounterId() { return fhirEncounterId; }
    public void setFhirEncounterId(String fhirEncounterId) { this.fhirEncounterId = fhirEncounterId; }

    public String getMotivoConsulta() { return motivoConsulta; }
    public void setMotivoConsulta(String motivoConsulta) { this.motivoConsulta = motivoConsulta; }

    public String getPadecimientoActual() { return padecimientoActual; }
    public void setPadecimientoActual(String padecimientoActual) { this.padecimientoActual = padecimientoActual; }

    public String getDiagnostico() { return diagnostico; }
    public void setDiagnostico(String diagnostico) { this.diagnostico = diagnostico; }

    public Double getPresionSistolica() { return presionSistolica; }
    public void setPresionSistolica(Double presionSistolica) { this.presionSistolica = presionSistolica; }

    public Double getPresionDiastolica() { return presionDiastolica; }
    public void setPresionDiastolica(Double presionDiastolica) { this.presionDiastolica = presionDiastolica; }

    public Double getPulso() { return pulso; }
    public void setPulso(Double pulso) { this.pulso = pulso; }

    public Double getTemperatura() { return temperatura; }
    public void setTemperatura(Double temperatura) { this.temperatura = temperatura; }

    public Double getPeso() { return peso; }
    public void setPeso(Double peso) { this.peso = peso; }

    public Double getTalla() { return talla; }
    public void setTalla(Double talla) { this.talla = talla; }

    public Double getFrecuenciaRespiratoria() { return frecuenciaRespiratoria; }
    public void setFrecuenciaRespiratoria(Double frecuenciaRespiratoria) { this.frecuenciaRespiratoria = frecuenciaRespiratoria; }
}
