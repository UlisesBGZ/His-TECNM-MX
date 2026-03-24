package ca.uhn.fhir.jpa.starter.virtualehr.service;

import com.nedap.archie.rm.datavalues.DvText;
import com.nedap.archie.rm.ehr.EhrStatus;
import com.nedap.archie.rm.generic.PartySelf;
import com.nedap.archie.rm.support.identification.GenericId;
import com.nedap.archie.rm.support.identification.PartyRef;
import java.util.UUID;
import org.ehrbase.openehr.sdk.client.openehrclient.OpenEhrClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class EhrbaseEhrService {

    private final OpenEhrClient openEhrClient;
    private final String linkageNamespace;

    public EhrbaseEhrService(
            OpenEhrClient openEhrClient,
            @Value("${virtualehr.fhir.linkage-namespace:HOSPITAL_FHIR_SYSTEM}") String linkageNamespace) {
        this.openEhrClient = openEhrClient;
        this.linkageNamespace = linkageNamespace;
    }

    public UUID createLinkedEhr(String fhirPatientId) {
        EhrStatus ehrStatus = new EhrStatus();
        ehrStatus.setArchetypeNodeId("openEHR-EHR-EHR_STATUS.generic.v1");
        ehrStatus.setName(new DvText("EHR Status"));
        ehrStatus.setQueryable(true);
        ehrStatus.setModifiable(true);

        PartyRef externalRef = new PartyRef(new GenericId(fhirPatientId, "FHIR_ID"), linkageNamespace, "PERSON");
        ehrStatus.setSubject(new PartySelf(externalRef));

        return openEhrClient.ehrEndpoint().createEhr(ehrStatus);
    }

    public String getLinkageNamespace() {
        return linkageNamespace;
    }
}
