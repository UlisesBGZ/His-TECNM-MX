import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_encounter.dart';
import '../models/fhir_patient.dart';
import '../models/fhir_antecedent.dart';
import '../services/fhir_service.dart';
import 'antecedent_form_dialog.dart';

class EncounterFormScreen extends StatefulWidget {
  final FhirEncounter? encounter;
  final String? patientId;

  const EncounterFormScreen({
    super.key,
    this.encounter,
    this.patientId,
  });

  @override
  State<EncounterFormScreen> createState() => _EncounterFormScreenState();
}

class _EncounterFormScreenState extends State<EncounterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  final _motivoConsultaController = TextEditingController();
  final _padecimientoActualController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _planTratamientoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  final _frecuenciaCardiacaController = TextEditingController();
  final _frecuenciaRespiratoriaController = TextEditingController();
  final _sistolicaController = TextEditingController();
  final _diastolicaController = TextEditingController();
  final _temperaturaController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  FhirPatient? _selectedPatient;
  List<FhirPatient> _patients = [];
  bool _isLoadingPatients = false;
  bool _isSaving = false;

  static const _primary = Color(0xFF3B5BDB);
  static const _bg = Color(0xFFF4F6FB);

  bool get _isFemalePatient {
    final gender = _selectedPatient?.gender?.toLowerCase().trim();
    return gender == 'female' || gender == 'femenino' || gender == 'mujer';
  }

  List<AntecedentType> get _availableAntecedentTypes {
    if (_isFemalePatient) return AntecedentType.values;
    return AntecedentType.values
        .where((t) => t != AntecedentType.ginecoObstetrico)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.encounter != null) {
      final enc = widget.encounter!;
      _motivoConsultaController.text = enc.motivoConsulta ?? '';
      _padecimientoActualController.text = enc.padecimientoActual ?? '';
      _diagnosticoController.text = enc.diagnostico ?? '';
      _planTratamientoController.text = enc.planTratamiento ?? '';
      if (enc.vitals != null) {
        _pesoController.text = enc.vitals!.weight?.toString() ?? '';
        _tallaController.text = enc.vitals!.height?.toString() ?? '';
        _frecuenciaCardiacaController.text = enc.vitals!.heartRate?.toString() ?? '';
        _frecuenciaRespiratoriaController.text = enc.vitals!.respiratoryRate?.toString() ?? '';
        _sistolicaController.text = enc.vitals!.systolic?.toString() ?? '';
        _diastolicaController.text = enc.vitals!.diastolic?.toString() ?? '';
        _temperaturaController.text = enc.vitals!.temperature?.toString() ?? '';
      }
      _selectedDate = enc.start;
      if (enc.start != null) _selectedTime = TimeOfDay.fromDateTime(enc.start!);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  bool get _patientFixed =>
      widget.patientId != null && widget.patientId!.isNotEmpty;

  Future<void> _loadPatients() async {
    setState(() => _isLoadingPatients = true);
    try {
      if (_patientFixed) {
        // Viene desde la vista clínica: solo necesitamos ese paciente
        final patients = await _fhirService.getPatients(count: 100);
        setState(() { _patients = patients; _isLoadingPatients = false; });
        try {
          final p = _patients.firstWhere((p) => p.id == widget.patientId);
          setState(() => _selectedPatient = p);
        } catch (_) {}
      } else {
        // Abierto de forma general: cargar todos
        final patients = await _fhirService.getPatients(count: 100);
        setState(() { _patients = patients; _isLoadingPatients = false; });
        if (widget.encounter?.patientId != null) {
          final pid = widget.encounter!.patientId!;
          _selectedPatient = _patients.where((p) => p.id == pid).isNotEmpty
              ? _patients.firstWhere((p) => p.id == pid)
              : null;
        }
      }
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar pacientes: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('es', 'ES'),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime? _getStartDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;
    return DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day,
        _selectedTime!.hour, _selectedTime!.minute);
  }

  DateTime? _getEndDateTime() {
    final s = _getStartDateTime();
    return s?.add(const Duration(minutes: 30));
  }

  VitalsData _buildVitalsData() {
    return VitalsData(
      weight: _pesoController.text.isNotEmpty ? double.tryParse(_pesoController.text) : null,
      height: _tallaController.text.isNotEmpty ? double.tryParse(_tallaController.text) : null,
      heartRate: _frecuenciaCardiacaController.text.isNotEmpty ? double.tryParse(_frecuenciaCardiacaController.text) : null,
      respiratoryRate: _frecuenciaRespiratoriaController.text.isNotEmpty ? double.tryParse(_frecuenciaRespiratoriaController.text) : null,
      systolic: _sistolicaController.text.isNotEmpty ? double.tryParse(_sistolicaController.text) : null,
      diastolic: _diastolicaController.text.isNotEmpty ? double.tryParse(_diastolicaController.text) : null,
      temperature: _temperaturaController.text.isNotEmpty ? double.tryParse(_temperaturaController.text) : null,
    );
  }

  Future<void> _saveEncounter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un paciente'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final encounter = FhirEncounter(
        id: widget.encounter?.id,
        status: 'active',
        motivoConsulta: _motivoConsultaController.text.trim(),
        padecimientoActual: _padecimientoActualController.text.trim(),
        vitals: _buildVitalsData(),
        diagnostico: _diagnosticoController.text.trim(),
        planTratamiento: _planTratamientoController.text.trim(),
        start: _getStartDateTime(),
        end: _getEndDateTime(),
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
      );

      final saved = widget.encounter == null
          ? await _fhirService.createEncounter(encounter)
          : await _fhirService.updateEncounter(encounter);

      final enhanced = saved.copyWith(
        diagnostico: saved.diagnostico ?? encounter.diagnostico,
        vitals: saved.vitals ?? encounter.vitals,
        motivoConsulta: saved.motivoConsulta ?? encounter.motivoConsulta,
        padecimientoActual: saved.padecimientoActual ?? encounter.padecimientoActual,
        planTratamiento: saved.planTratamiento ?? encounter.planTratamiento,
        practitionerName: saved.practitionerName ?? encounter.practitionerName,
        practitionerId: saved.practitionerId ?? encounter.practitionerId,
      );

      // Dual-write: guardar composición openEHR en EHRbase (best effort)
      final ehrId = _selectedPatient?.ehrId;
      final fhirPatientId = _selectedPatient?.id;
      final savedEncounterId = saved.id;
      if (ehrId != null && ehrId.isNotEmpty &&
          fhirPatientId != null && savedEncounterId != null) {
        _fhirService.saveEncounterComposition(
          fhirPatientId: fhirPatientId,
          ehrId: ehrId,
          fhirEncounterId: savedEncounterId,
          motivoConsulta: encounter.motivoConsulta,
          padecimientoActual: encounter.padecimientoActual,
          diagnostico: encounter.diagnostico,
          presionSistolica: encounter.vitals?.systolic,
          presionDiastolica: encounter.vitals?.diastolic,
          pulso: encounter.vitals?.heartRate,
          temperatura: encounter.vitals?.temperature,
          peso: encounter.vitals?.weight,
          talla: encounter.vitals?.height,
          frecuenciaRespiratoria: encounter.vitals?.respiratoryRate,
        ); // fire-and-forget: FHIR ya está guardado, EHRbase no bloquea el UI
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.encounter == null
              ? 'Encuentro creado exitosamente'
              : 'Encuentro actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, enhanced);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _openAntecedentQuickUpdate() async {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un paciente primero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final patientId = _selectedPatient!.id ?? '';
    final availableTypes = _availableAntecedentTypes;
    final existingByType = <AntecedentType, FhirAntecedent?>{};
    for (final type in availableTypes) {
      existingByType[type] = await _fhirService.getLatestAntecedentByType(patientId, type);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Actualizar antecedente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ...availableTypes.map((type) {
                final existing = existingByType[type];
                return ListTile(
                  leading: const Icon(Icons.edit_outlined, color: _primary),
                  title: Text(type.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
                  subtitle: Text(
                    existing?.content.isNotEmpty == true
                        ? existing!.content
                        : 'Sin registro',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                  onTap: () async {
                    Navigator.pop(dialogCtx);
                    if (_selectedPatient == null) return;
                    try {
                      if (!mounted) return;
                      await AntecedentFormDialog.show(
                        context: context,
                        patientId: _selectedPatient!.id ?? '',
                        type: type,
                        initialAntecedent: existing,
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                );
              }),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _motivoConsultaController.dispose();
    _padecimientoActualController.dispose();
    _diagnosticoController.dispose();
    _planTratamientoController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _sistolicaController.dispose();
    _diastolicaController.dispose();
    _temperaturaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.encounter != null;

    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 800 ? 40.0 : 16.0;

      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1E293B),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isEditing ? 'Editar Encuentro' : 'Nuevo Encuentro',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                isEditing
                    ? 'Modifica los datos del encuentro'
                    : 'Registra la consulta del paciente',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            Tooltip(
              message: 'Actualizar antecedentes',
              child: IconButton(
                icon: const Icon(Icons.history_outlined),
                onPressed: _openAntecedentQuickUpdate,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE2E8F0)),
          ),
        ),
        body: _isLoadingPatients
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 860),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                          horizontal: hPad, vertical: 24),
                      children: [
                        // Paciente
                        _buildCard(
                          color: _primary,
                          icon: Icons.person_outline,
                          title: 'Paciente',
                          child: _patientFixed
                              ? _buildPatientReadOnly()
                              : _buildPatientDropdown(),
                        ),
                        const SizedBox(height: 16),

                        // Motivo + Padecimiento
                        _buildCard(
                          color: const Color(0xFF10B981),
                          icon: Icons.notes_outlined,
                          title: 'Consulta',
                          child: Column(
                            children: [
                              _buildField(
                                controller: _motivoConsultaController,
                                label: 'Motivo de la consulta',
                                hint: 'Ej: Revisión general, Dolor de cabeza...',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _padecimientoActualController,
                                label: 'Padecimiento actual',
                                hint: 'Descripción de síntomas y queja principal...',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Signos vitales
                        _buildCard(
                          color: const Color(0xFFF59E0B),
                          icon: Icons.monitor_heart_outlined,
                          title: 'Signos vitales',
                          child: _buildVitalsGrid(),
                        ),
                        const SizedBox(height: 16),

                        // Diagnóstico + Plan
                        _buildCard(
                          color: const Color(0xFF8B5CF6),
                          icon: Icons.assignment_outlined,
                          title: 'Evaluación',
                          child: Column(
                            children: [
                              _buildField(
                                controller: _diagnosticoController,
                                label: 'Diagnóstico',
                                hint: 'Diagnóstico clínico...',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _planTratamientoController,
                                label: 'Plan de tratamiento',
                                hint: 'Medicamentos, recomendaciones, etc...',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Fecha y hora
                        _buildCard(
                          color: const Color(0xFFEF4444),
                          icon: Icons.calendar_today_outlined,
                          title: 'Fecha y hora',
                          child: Row(
                            children: [
                              Expanded(child: _buildDateTile()),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTimeTile()),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Botones de acción
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                foregroundColor: const Color(0xFF64748B),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _isSaving ? null : _saveEncounter,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.check, size: 18),
                              label: Text(
                                _isSaving
                                    ? 'Guardando...'
                                    : (isEditing
                                        ? 'Actualizar Encuentro'
                                        : 'Crear Encuentro'),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildCard({
    required Color color,
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientDropdown() {
    return DropdownButtonFormField<FhirPatient>(
      value: _selectedPatient,
      decoration: InputDecoration(
        hintText: 'Selecciona un paciente',
        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        prefixIcon: const Icon(Icons.person_outline, size: 18, color: Color(0xFF94A3B8)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
      ),
      items: _patients
          .map((p) => DropdownMenuItem(value: p, child: Text(p.fullName)))
          .toList(),
      onChanged: (v) => setState(() => _selectedPatient = v),
      validator: (v) => v == null ? 'Seleccione un paciente' : null,
    );
  }

  Widget _buildPatientReadOnly() {
    final patient = _selectedPatient;
    final avatarColor = patient?.gender == 'male'
        ? const Color(0xFF3B82F6)
        : patient?.gender == 'female'
            ? const Color(0xFFEC4899)
            : const Color(0xFF8B5CF6);
    final initial = (patient?.fullName.isNotEmpty == true)
        ? patient!.fullName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient?.fullName ?? '—',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (patient?.identifier != null)
                  Text(
                    'ID: ${patient!.identifier}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, size: 14, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildVitalField('Peso (kg)', _pesoController)),
            const SizedBox(width: 10),
            Expanded(child: _buildVitalField('Talla (cm)', _tallaController)),
            const SizedBox(width: 10),
            Expanded(child: _buildVitalField('FC (lpm)', _frecuenciaCardiacaController)),
            const SizedBox(width: 10),
            Expanded(child: _buildVitalField('FR (rpm)', _frecuenciaRespiratoriaController)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildVitalField('TA Sistólica', _sistolicaController)),
            const SizedBox(width: 10),
            Expanded(child: _buildVitalField('TA Diastólica', _diastolicaController)),
            const SizedBox(width: 10),
            Expanded(child: _buildVitalField('Temp. (°C)', _temperaturaController)),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                    : 'Seleccionar fecha',
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedDate != null
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTile() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined,
                size: 16, color: Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : 'Seleccionar hora',
                style: TextStyle(
                  fontSize: 13,
                  color: _selectedTime != null
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
