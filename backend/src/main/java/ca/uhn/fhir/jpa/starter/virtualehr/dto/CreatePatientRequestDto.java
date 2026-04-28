package ca.uhn.fhir.jpa.starter.virtualehr.dto;

import com.fasterxml.jackson.annotation.JsonAlias;

public class CreatePatientRequestDto {

    @JsonAlias({"curp", "identifier"})
    private String identifier;

    @JsonAlias("firstName")
    private String givenName;

    @JsonAlias("lastName")
    private String familyName;
    private String paternalLastName;
    private String maternalLastName;
    private String gender;
    private String birthDate;
    private String bloodType;
    private String state;
    private String municipality;
    private String postalCode;
    private String streetAndNumber;
    private String colony;
    private String phone;
    private String email;
    private String clinicalAntecedents;

    public String getIdentifier() {
        return identifier;
    }

    public void setIdentifier(String identifier) {
        this.identifier = identifier;
    }

    public String getGivenName() {
        return givenName;
    }

    public void setGivenName(String givenName) {
        this.givenName = givenName;
    }

    public String getFamilyName() {
        return familyName;
    }

    public void setFamilyName(String familyName) {
        this.familyName = familyName;
    }

    public String getPaternalLastName() {
        return paternalLastName;
    }

    public void setPaternalLastName(String paternalLastName) {
        this.paternalLastName = paternalLastName;
    }

    public String getMaternalLastName() {
        return maternalLastName;
    }

    public void setMaternalLastName(String maternalLastName) {
        this.maternalLastName = maternalLastName;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public void setBirthDate(String birthDate) {
        this.birthDate = birthDate;
    }

    public String getBloodType() {
        return bloodType;
    }

    public void setBloodType(String bloodType) {
        this.bloodType = bloodType;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public String getMunicipality() {
        return municipality;
    }

    public void setMunicipality(String municipality) {
        this.municipality = municipality;
    }

    public String getPostalCode() {
        return postalCode;
    }

    public void setPostalCode(String postalCode) {
        this.postalCode = postalCode;
    }

    public String getStreetAndNumber() {
        return streetAndNumber;
    }

    public void setStreetAndNumber(String streetAndNumber) {
        this.streetAndNumber = streetAndNumber;
    }

    public String getColony() {
        return colony;
    }

    public void setColony(String colony) {
        this.colony = colony;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getClinicalAntecedents() {
        return clinicalAntecedents;
    }

    public void setClinicalAntecedents(String clinicalAntecedents) {
        this.clinicalAntecedents = clinicalAntecedents;
    }

    public String getEffectiveFamilyName() {
        if (familyName != null && !familyName.isBlank()) {
            return familyName;
        }

        StringBuilder builder = new StringBuilder();
        if (paternalLastName != null && !paternalLastName.isBlank()) {
            builder.append(paternalLastName.trim());
        }
        if (maternalLastName != null && !maternalLastName.isBlank()) {
            if (builder.length() > 0) {
                builder.append(' ');
            }
            builder.append(maternalLastName.trim());
        }

        return builder.length() > 0 ? builder.toString() : null;
    }
}
