package ca.uhn.fhir.jpa.starter.virtualehr.config;

import ca.uhn.fhir.context.FhirContext;
import ca.uhn.fhir.rest.client.api.IGenericClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FhirClientConfig {

    @Bean
    public FhirContext fhirContext() {
        return FhirContext.forR4Cached();
    }

    @Bean
    public IGenericClient hapiFhirClient(
            FhirContext fhirContext,
            @Value("${virtualehr.fhir.base-url:http://localhost:8080/fhir}") String fhirBaseUrl) {
        return fhirContext.newRestfulGenericClient(fhirBaseUrl);
    }
}
