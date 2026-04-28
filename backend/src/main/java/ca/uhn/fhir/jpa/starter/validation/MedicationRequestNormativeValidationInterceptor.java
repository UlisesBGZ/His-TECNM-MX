package ca.uhn.fhir.jpa.starter.validation;

import ca.uhn.fhir.interceptor.api.Hook;
import ca.uhn.fhir.interceptor.api.Pointcut;
import ca.uhn.fhir.rest.api.server.RequestDetails;
import ca.uhn.fhir.rest.server.exceptions.UnprocessableEntityException;
import java.math.BigDecimal;
import java.util.Set;
import org.hl7.fhir.instance.model.api.IBaseResource;
import org.hl7.fhir.r4.model.MedicationRequest;

public class MedicationRequestNormativeValidationInterceptor {

    private static final Set<MedicationRequest.MedicationRequestStatus> ALLOWED_STATUS = Set.of(
            MedicationRequest.MedicationRequestStatus.DRAFT,
            MedicationRequest.MedicationRequestStatus.ACTIVE,
            MedicationRequest.MedicationRequestStatus.ONHOLD,
            MedicationRequest.MedicationRequestStatus.CANCELLED,
            MedicationRequest.MedicationRequestStatus.COMPLETED);

    @Hook(Pointcut.STORAGE_PRESTORAGE_RESOURCE_CREATED)
    public void validateBeforeCreate(IBaseResource theResource, RequestDetails theRequestDetails) {
        validateMedicationRequest(theResource);
    }

    @Hook(Pointcut.STORAGE_PRESTORAGE_RESOURCE_UPDATED)
    public void validateBeforeUpdate(
            IBaseResource theOldResource,
            IBaseResource theResource,
            RequestDetails theRequestDetails) {
        validateMedicationRequest(theResource);
    }

    private void validateMedicationRequest(IBaseResource theResource) {
        if (!(theResource instanceof MedicationRequest medicationRequest)) {
            return;
        }

        if (!medicationRequest.hasSubject()
                || !medicationRequest.getSubject().hasReference()
                || medicationRequest.getSubject().getReference().isBlank()) {
            throw new UnprocessableEntityException("MedicationRequest requires subject (patient)");
        }

        if (!medicationRequest.hasRequester()
                || !medicationRequest.getRequester().hasReference()
                || medicationRequest.getRequester().getReference().isBlank()) {
            throw new UnprocessableEntityException("MedicationRequest requires requester (prescriber)");
        }

        if (!medicationRequest.hasMedicationCodeableConcept()
                || !medicationRequest.getMedicationCodeableConcept().hasText()
                || medicationRequest.getMedicationCodeableConcept().getText().isBlank()) {
            throw new UnprocessableEntityException(
                    "MedicationRequest requires medicationCodeableConcept.text");
        }

        if (!medicationRequest.hasDosageInstruction()
                || !medicationRequest.getDosageInstructionFirstRep().hasText()
                || medicationRequest.getDosageInstructionFirstRep().getText().isBlank()) {
            throw new UnprocessableEntityException("MedicationRequest requires dosageInstruction.text");
        }

        if (!medicationRequest.hasDispenseRequest()
                || !medicationRequest.getDispenseRequest().hasQuantity()
                || !medicationRequest.getDispenseRequest().getQuantity().hasValue()) {
            throw new UnprocessableEntityException("MedicationRequest requires dispenseRequest.quantity.value");
        }

        BigDecimal quantity = medicationRequest.getDispenseRequest().getQuantity().getValue();
        if (quantity.compareTo(BigDecimal.ZERO) <= 0) {
            throw new UnprocessableEntityException(
                    "MedicationRequest dispenseRequest.quantity.value must be greater than 0");
        }

        if (!medicationRequest.hasAuthoredOn()) {
            throw new UnprocessableEntityException("MedicationRequest requires authoredOn");
        }

        if (!medicationRequest.hasIntent()
                || medicationRequest.getIntent() != MedicationRequest.MedicationRequestIntent.ORDER) {
            throw new UnprocessableEntityException("MedicationRequest intent must be 'order'");
        }

        if (!medicationRequest.hasStatus() || !ALLOWED_STATUS.contains(medicationRequest.getStatus())) {
            throw new UnprocessableEntityException(
                    "MedicationRequest status must be one of: draft, active, on-hold, cancelled, completed");
        }
    }
}