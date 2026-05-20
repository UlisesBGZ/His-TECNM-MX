package ca.uhn.fhir.jpa.starter.virtualehr.service;

import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.ConsultaClinicaComposition;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BloodPressureAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BloodPressureObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BodyTemperatureAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BodyTemperatureObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BodyWeightAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.BodyWeightObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.HeightLengthAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.HeightLengthObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.ProblemDiagnosisEvaluation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.PulseHeartBeatAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.PulseHeartBeatObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.ReasonForEncounterEvaluation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.ReasonForEncounterPresentingProblemElement;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.RespirationAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.RespirationObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.StoryHistoryAnyEventPointEvent;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.StoryHistoryObservation;
import ca.uhn.fhir.jpa.starter.openehr.generated.consultaclinicacomposition.definition.StoryHistoryStoryElement;
import ca.uhn.fhir.jpa.starter.virtualehr.dto.SaveEncounterCompositionRequestDto;
import com.nedap.archie.rm.generic.PartyIdentified;
import com.nedap.archie.rm.generic.PartySelf;
import java.time.OffsetDateTime;
import java.util.List;
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
public class EhrbaseCompositionService {

    private static final Logger log = LoggerFactory.getLogger(EhrbaseCompositionService.class);

    private final OpenEhrClient openEhrClient;

    public EhrbaseCompositionService(OpenEhrClient openEhrClient) {
        this.openEhrClient = openEhrClient;
    }

    public String saveConsultaClinica(SaveEncounterCompositionRequestDto req) {
        UUID ehrId = UUID.fromString(req.getEhrId());
        ConsultaClinicaComposition composition = buildComposition(req);

        ConsultaClinicaComposition saved = openEhrClient
                .compositionEndpoint(ehrId)
                .mergeCompositionEntity(composition);

        String compositionId = saved.getVersionUid() != null
                ? saved.getVersionUid().toString()
                : "saved";

        log.info("Composition saved for EHR {} — id: {}", ehrId, compositionId);
        return compositionId;
    }

    private ConsultaClinicaComposition buildComposition(SaveEncounterCompositionRequestDto req) {
        ConsultaClinicaComposition c = new ConsultaClinicaComposition();
        c.setCategoryDefiningCode(Category.EVENT);
        c.setLanguage(Language.ES);
        c.setTerritory(Territory.MX);
        c.setSettingDefiningCode(Setting.PRIMARY_MEDICAL_CARE);
        c.setStartTimeValue(OffsetDateTime.now());
        c.setComposer(new PartyIdentified(null, "Hospital La Clemencia", null));

        if (hasText(req.getMotivoConsulta())) {
            c.setReasonForEncounter(buildReasonForEncounter(req.getMotivoConsulta()));
        }
        if (hasText(req.getPadecimientoActual())) {
            c.setStoryHistory(buildStoryHistory(req.getPadecimientoActual()));
        }
        if (hasText(req.getDiagnostico())) {
            c.setProblemDiagnosis(buildProblemDiagnosis(req.getDiagnostico()));
        }
        if (req.getPresionSistolica() != null || req.getPresionDiastolica() != null) {
            c.setBloodPressure(buildBloodPressure(req.getPresionSistolica(), req.getPresionDiastolica()));
        }
        if (req.getPulso() != null) {
            c.setPulseHeartBeat(buildPulse(req.getPulso()));
        }
        if (req.getTemperatura() != null) {
            c.setBodyTemperature(buildTemperature(req.getTemperatura()));
        }
        if (req.getPeso() != null) {
            c.setBodyWeight(buildBodyWeight(req.getPeso()));
        }
        if (req.getTalla() != null) {
            c.setHeightLength(buildHeight(req.getTalla()));
        }
        if (req.getFrecuenciaRespiratoria() != null) {
            c.setRespiration(buildRespiration(req.getFrecuenciaRespiratoria()));
        }

        return c;
    }

    private ReasonForEncounterEvaluation buildReasonForEncounter(String motivo) {
        ReasonForEncounterPresentingProblemElement problem = new ReasonForEncounterPresentingProblemElement();
        problem.setValue(motivo);

        ReasonForEncounterEvaluation eval = new ReasonForEncounterEvaluation();
        eval.setLanguage(Language.ES);
        eval.setSubject(new PartySelf());
        eval.setPresentingProblem(List.of(problem));
        return eval;
    }

    private StoryHistoryObservation buildStoryHistory(String padecimiento) {
        StoryHistoryStoryElement storyEl = new StoryHistoryStoryElement();
        storyEl.setValue(padecimiento);

        StoryHistoryAnyEventPointEvent event = new StoryHistoryAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setStory(List.of(storyEl));

        StoryHistoryObservation obs = new StoryHistoryObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private ProblemDiagnosisEvaluation buildProblemDiagnosis(String diagnostico) {
        ProblemDiagnosisEvaluation eval = new ProblemDiagnosisEvaluation();
        eval.setLanguage(Language.ES);
        eval.setSubject(new PartySelf());
        eval.setProblemDiagnosisNameValue(diagnostico);
        return eval;
    }

    private BloodPressureObservation buildBloodPressure(Double sistolica, Double diastolica) {
        BloodPressureAnyEventPointEvent event = new BloodPressureAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        if (sistolica != null) {
            event.setSystolicMagnitude(sistolica);
            event.setSystolicUnits("mm[Hg]");
        }
        if (diastolica != null) {
            event.setDiastolicMagnitude(diastolica);
            event.setDiastolicUnits("mm[Hg]");
        }

        BloodPressureObservation obs = new BloodPressureObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private PulseHeartBeatObservation buildPulse(Double pulso) {
        PulseHeartBeatAnyEventPointEvent event = new PulseHeartBeatAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setRateMagnitude(pulso);
        event.setRateUnits("/min");

        PulseHeartBeatObservation obs = new PulseHeartBeatObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private BodyTemperatureObservation buildTemperature(Double temp) {
        BodyTemperatureAnyEventPointEvent event = new BodyTemperatureAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setTemperatureMagnitude(temp);
        event.setTemperatureUnits("Cel");

        BodyTemperatureObservation obs = new BodyTemperatureObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private BodyWeightObservation buildBodyWeight(Double peso) {
        BodyWeightAnyEventPointEvent event = new BodyWeightAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setWeightMagnitude(peso);
        event.setWeightUnits("kg");

        BodyWeightObservation obs = new BodyWeightObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private HeightLengthObservation buildHeight(Double talla) {
        HeightLengthAnyEventPointEvent event = new HeightLengthAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setHeightLengthMagnitude(talla);
        event.setHeightLengthUnits("cm");

        HeightLengthObservation obs = new HeightLengthObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private RespirationObservation buildRespiration(Double frecuencia) {
        RespirationAnyEventPointEvent event = new RespirationAnyEventPointEvent();
        event.setTimeValue(OffsetDateTime.now());
        event.setRateMagnitude(frecuencia);
        event.setRateUnits("/min");

        RespirationObservation obs = new RespirationObservation();
        obs.setLanguage(Language.ES);
        obs.setSubject(new PartySelf());
        obs.setOriginValue(OffsetDateTime.now());
        obs.setAnyEvent(List.of(event));
        return obs;
    }

    private boolean hasText(String s) {
        return s != null && !s.isBlank();
    }
}
