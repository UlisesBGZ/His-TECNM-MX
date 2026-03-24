package ca.uhn.fhir.jpa.starter.virtualehr.dto;

import com.fasterxml.jackson.annotation.JsonAlias;

public class CreatePatientRequestDto {

    @JsonAlias("firstName")
    private String givenName;

    @JsonAlias("lastName")
    private String familyName;
    private String gender;
    private String birthDate;

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
}
