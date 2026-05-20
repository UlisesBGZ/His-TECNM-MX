package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.jpa.starter.openehr.generated.antecedentesclinicoscomposition.AntecedentesClinicosComposition;
import ca.uhn.fhir.jpa.starter.openehr.generated.antecedentesclinicoscomposition.definition.FamilyHistorySummaryEvaluation;
import ca.uhn.fhir.jpa.starter.openehr.generated.antecedentesclinicoscomposition.definition.ObstetricSummaryEvaluation;
import ca.uhn.fhir.jpa.starter.openehr.generated.antecedentesclinicoscomposition.definition.SocialSummaryEvaluation;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.SaveAntecedentesCompositionRequestDto;
import com.nedap.archie.rm.generic.PartyIdentified;
import com.nedap.archie.rm.generic.PartySelf;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.ehrbase.openehr.sdk.client.openehrclient.OpenEhrClient;
import org.ehrbase.openehr.sdk.generator.commons.shareddefinition.Category;
import org.ehrbase.openehr.sdk.generator.commons.shareddefinition.Language;
import org.ehrbase.openehr.sdk.generator.commons.shareddefinition.Setting;
import org.ehrbase.openehr.sdk.generator.commons.shareddefinition.Territory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class EhrbaseAntecedentesService {

    private static final Logger log = LoggerFactory.getLogger(EhrbaseAntecedentesService.class);

    private final OpenEhrClient openEhrClient;

    public EhrbaseAntecedentesService(OpenEhrClient openEhrClient) {
        this.openEhrClient = openEhrClient;
    }

    public String saveAntecedente(SaveAntecedentesCompositionRequestDto req) {
        UUID ehrId = UUID.fromString(req.getEhrId());
        AntecedentesClinicosComposition composition = buildComposition(req);

        AntecedentesClinicosComposition saved = openEhrClient
                .compositionEndpoint(ehrId)
                .mergeCompositionEntity(composition);

        String compositionId = saved.getVersionUid() != null
                ? saved.getVersionUid().toString()
                : "saved";

        log.info("Antecedente '{}' guardado en EHRbase para EHR {} — composer: '{}' — id: {}",
                req.getTipoAntecedente(), ehrId, req.getComposerName(), compositionId);
        return compositionId;
    }

    private AntecedentesClinicosComposition buildComposition(SaveAntecedentesCompositionRequestDto req) {
        AntecedentesClinicosComposition c = new AntecedentesClinicosComposition();
        c.setCategoryDefiningCode(Category.EVENT);
        c.setLanguage(Language.ES);
        c.setTerritory(Territory.MX);
        c.setSettingDefiningCode(Setting.PRIMARY_MEDICAL_CARE);
        c.setStartTimeValue(OffsetDateTime.now());
        String composerName = (req.getComposerName() != null && !req.getComposerName().isBlank())
                ? req.getComposerName()
                : "Hospital La Clemencia";
        c.setComposer(new PartyIdentified(null, composerName, null));

        String tipo = req.getTipoAntecedente() != null
                ? req.getTipoAntecedente().toUpperCase()
                : "";
        String contenido = req.getContenido();

        switch (tipo) {
            case "HEREDOFAMILIAR" -> {
                if (hasText(contenido)) {
                    FamilyHistorySummaryEvaluation eval = new FamilyHistorySummaryEvaluation();
                    eval.setLanguage(Language.ES);
                    eval.setSubject(new PartySelf());
                    eval.setSummaryValue(contenido);
                    c.setFamilyHistorySummary(eval);
                }
            }
            case "NO_PATOLOGICO" -> {
                if (hasText(contenido)) {
                    SocialSummaryEvaluation eval = new SocialSummaryEvaluation();
                    eval.setLanguage(Language.ES);
                    eval.setSubject(new PartySelf());
                    eval.setSummaryValue(contenido);
                    c.setSocialSummary(eval);
                }
            }
            case "GINECO_OBSTETRICO" -> {
                if (hasText(contenido)) {
                    ObstetricSummaryEvaluation eval = new ObstetricSummaryEvaluation();
                    eval.setLanguage(Language.ES);
                    eval.setSubject(new PartySelf());
                    eval.setDescriptionValue(contenido);
                    c.setObstetricSummary(eval);
                }
            }
            default -> log.warn("Tipo de antecedente desconocido: {}", tipo);
        }

        return c;
    }

    private boolean hasText(String s) {
        return s != null && !s.isBlank();
    }
}
