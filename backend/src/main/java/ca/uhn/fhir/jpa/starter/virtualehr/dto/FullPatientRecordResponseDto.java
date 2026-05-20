package ca.uhn.fhir.jpa.starter.virtualehr.dto;

import java.util.ArrayList;
import java.util.List;

public class FullPatientRecordResponseDto {

    private String fhirPatientId;
    private String nombre;
    private String genero;
    private String fechaNacimiento;
    private String tipoSangre;
    private String telefono;
    private String email;
    private String direccion;
    private String ehrId;
    private boolean ehrVinculado;
    private List<ConsultaDto> consultas = new ArrayList<>();
    private AntecedentesDto antecedentes;

    public static class ConsultaDto {
        private String composicionId;
        private String fecha;
        private String motivoConsulta;
        private String diagnostico;
        private SignosVitalesDto signosVitales;

        public String getComposicionId() { return composicionId; }
        public void setComposicionId(String composicionId) { this.composicionId = composicionId; }
        public String getFecha() { return fecha; }
        public void setFecha(String fecha) { this.fecha = fecha; }
        public String getMotivoConsulta() { return motivoConsulta; }
        public void setMotivoConsulta(String motivoConsulta) { this.motivoConsulta = motivoConsulta; }
        public String getDiagnostico() { return diagnostico; }
        public void setDiagnostico(String diagnostico) { this.diagnostico = diagnostico; }
        public SignosVitalesDto getSignosVitales() { return signosVitales; }
        public void setSignosVitales(SignosVitalesDto signosVitales) { this.signosVitales = signosVitales; }
    }

    public static class SignosVitalesDto {
        private Double presionSistolica;
        private Double presionDiastolica;
        private Double pulso;
        private Double temperatura;
        private Double peso;
        private Double talla;
        private Double frecuenciaRespiratoria;

        public Double getPresionSistolica() { return presionSistolica; }
        public void setPresionSistolica(Double v) { this.presionSistolica = v; }
        public Double getPresionDiastolica() { return presionDiastolica; }
        public void setPresionDiastolica(Double v) { this.presionDiastolica = v; }
        public Double getPulso() { return pulso; }
        public void setPulso(Double v) { this.pulso = v; }
        public Double getTemperatura() { return temperatura; }
        public void setTemperatura(Double v) { this.temperatura = v; }
        public Double getPeso() { return peso; }
        public void setPeso(Double v) { this.peso = v; }
        public Double getTalla() { return talla; }
        public void setTalla(Double v) { this.talla = v; }
        public Double getFrecuenciaRespiratoria() { return frecuenciaRespiratoria; }
        public void setFrecuenciaRespiratoria(Double v) { this.frecuenciaRespiratoria = v; }
    }

    public static class AntecedentesDto {
        private String heredofamiliar;
        private String noPatologico;
        private String ginecoObstetrico;

        public String getHeredofamiliar() { return heredofamiliar; }
        public void setHeredofamiliar(String v) { this.heredofamiliar = v; }
        public String getNoPatologico() { return noPatologico; }
        public void setNoPatologico(String v) { this.noPatologico = v; }
        public String getGinecoObstetrico() { return ginecoObstetrico; }
        public void setGinecoObstetrico(String v) { this.ginecoObstetrico = v; }
    }

    public String getFhirPatientId() { return fhirPatientId; }
    public void setFhirPatientId(String v) { this.fhirPatientId = v; }
    public String getNombre() { return nombre; }
    public void setNombre(String v) { this.nombre = v; }
    public String getGenero() { return genero; }
    public void setGenero(String v) { this.genero = v; }
    public String getFechaNacimiento() { return fechaNacimiento; }
    public void setFechaNacimiento(String v) { this.fechaNacimiento = v; }
    public String getTipoSangre() { return tipoSangre; }
    public void setTipoSangre(String v) { this.tipoSangre = v; }
    public String getTelefono() { return telefono; }
    public void setTelefono(String v) { this.telefono = v; }
    public String getEmail() { return email; }
    public void setEmail(String v) { this.email = v; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String v) { this.direccion = v; }
    public String getEhrId() { return ehrId; }
    public void setEhrId(String v) { this.ehrId = v; }
    public boolean isEhrVinculado() { return ehrVinculado; }
    public void setEhrVinculado(boolean v) { this.ehrVinculado = v; }
    public List<ConsultaDto> getConsultas() { return consultas; }
    public void setConsultas(List<ConsultaDto> v) { this.consultas = v; }
    public AntecedentesDto getAntecedentes() { return antecedentes; }
    public void setAntecedentes(AntecedentesDto v) { this.antecedentes = v; }
}
