package ca.uhn.fhir.jpa.starter.virtualehr.config;

import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

@Component
public class EhrbaseTemplateUploader {

    private static final Logger log = LoggerFactory.getLogger(EhrbaseTemplateUploader.class);

    private static final String[] TEMPLATES = {"consulta_clinica", "antecedentes_clinicos"};

    @Value("${virtualehr.ehrbase.base-url:http://localhost:8081/ehrbase/}")
    private String baseUrl;

    @Value("${virtualehr.ehrbase.username:ehrbase-user}")
    private String username;

    @Value("${virtualehr.ehrbase.password:SuperSecretPassword}")
    private String password;

    @EventListener(ApplicationReadyEvent.class)
    public void uploadTemplates() {
        String ehrbaseUrl = baseUrl.endsWith("/") ? baseUrl : baseUrl + "/";
        String templateApiBase = ehrbaseUrl + "rest/openehr/v1/definition/template/adl1.4";

        CredentialsProvider creds = new BasicCredentialsProvider();
        try {
            java.net.URI uri = new java.net.URI(ehrbaseUrl);
            int port = uri.getPort() > 0 ? uri.getPort() : 80;
            creds.setCredentials(
                    new AuthScope(uri.getHost(), port),
                    new UsernamePasswordCredentials(username, password));
        } catch (Exception e) {
            log.error("EHRbase URL invalida: {}", ehrbaseUrl, e);
            return;
        }

        try (CloseableHttpClient client = HttpClientBuilder.create()
                .setDefaultCredentialsProvider(creds)
                .build()) {

            for (String templateId : TEMPLATES) {
                uploadIfMissing(client, templateApiBase, templateId);
            }

        } catch (Exception e) {
            log.warn("Error al conectar con EHRbase para subir templates: {}", e.getMessage());
        }
    }

    private void uploadIfMissing(CloseableHttpClient client, String apiBase, String templateId) {
        String checkUrl = apiBase + "/" + templateId;
        try {
            HttpGet get = new HttpGet(checkUrl);
            get.setHeader("Accept", "application/xml");
            try (CloseableHttpResponse resp = client.execute(get)) {
                int status = resp.getStatusLine().getStatusCode();
                if (status == 200) {
                    log.info("Template '{}' ya existe en EHRbase.", templateId);
                    return;
                }
            }
        } catch (Exception e) {
            log.debug("No se pudo verificar template '{}': {}", templateId, e.getMessage());
        }

        String resourcePath = "templates/" + templateId + ".opt";
        try (InputStream in = new ClassPathResource(resourcePath).getInputStream()) {
            String xml = new String(in.readAllBytes(), StandardCharsets.UTF_8);

            HttpPost post = new HttpPost(apiBase);
            post.setHeader("Content-Type", "application/xml");
            post.setHeader("Accept", "application/xml");
            post.setEntity(new StringEntity(xml, StandardCharsets.UTF_8));

            try (CloseableHttpResponse resp = client.execute(post)) {
                int status = resp.getStatusLine().getStatusCode();
                String body = EntityUtils.toString(resp.getEntity());
                if (status == 200 || status == 201) {
                    log.info("Template '{}' subido exitosamente a EHRbase.", templateId);
                } else if (status == 409) {
                    log.info("Template '{}' ya existia en EHRbase (409).", templateId);
                } else {
                    log.warn("Error al subir template '{}': {} - {}", templateId, status, body);
                }
            }
        } catch (Exception e) {
            log.warn("No se pudo subir template '{}': {}", templateId, e.getMessage());
        }
    }
}
