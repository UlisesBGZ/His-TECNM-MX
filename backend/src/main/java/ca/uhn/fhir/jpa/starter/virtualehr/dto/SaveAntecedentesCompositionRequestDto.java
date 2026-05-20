package ca.uhn.fhir.jpa.starter.virtualehr.dto;

public class SaveAntecedentesCompositionRequestDto {

    private String ehrId;
    /** HEREDOFAMILIAR | NO_PATOLOGICO | GINECO_OBSTETRICO */
    private String tipoAntecedente;
    private String contenido;
    /** Nombre completo del médico que registra o actualiza el antecedente */
    private String composerName;

    public String getEhrId() { return ehrId; }
    public void setEhrId(String ehrId) { this.ehrId = ehrId; }

    public String getTipoAntecedente() { return tipoAntecedente; }
    public void setTipoAntecedente(String tipoAntecedente) { this.tipoAntecedente = tipoAntecedente; }

    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }

    public String getComposerName() { return composerName; }
    public void setComposerName(String composerName) { this.composerName = composerName; }
}
