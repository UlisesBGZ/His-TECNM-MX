package ca.uhn.fhir.jpa.starter.virtualehr.config;

import java.net.URI;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.HttpClientBuilder;
import org.ehrbase.openehr.sdk.client.openehrclient.OpenEhrClient;
import org.ehrbase.openehr.sdk.client.openehrclient.OpenEhrClientConfig;
import org.ehrbase.openehr.sdk.client.openehrclient.defaultrestclient.DefaultRestClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class EhrbaseClientConfig {

    @Bean
    public OpenEhrClient openEhrClient(
            @Value("${virtualehr.ehrbase.base-url:http://localhost:8081/ehrbase/}") String baseUrl,
            @Value("${virtualehr.ehrbase.username:ehrbase-user}") String username,
            @Value("${virtualehr.ehrbase.password:SuperSecretPassword}") String password) {

        URI ehrbaseUri = URI.create(baseUrl);

        CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
        int port = ehrbaseUri.getPort() > 0 ? ehrbaseUri.getPort() : 80;
        credentialsProvider.setCredentials(
                new AuthScope(ehrbaseUri.getHost(), port),
                new UsernamePasswordCredentials(username, password));

        OpenEhrClientConfig clientConfig = new OpenEhrClientConfig(ehrbaseUri);
        return new DefaultRestClient(
                clientConfig,
                null,
                HttpClientBuilder.create().setDefaultCredentialsProvider(credentialsProvider).build());
    }
}
