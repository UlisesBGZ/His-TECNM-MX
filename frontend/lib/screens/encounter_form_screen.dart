import 'package:flutter/material.dart';
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

  String _formatHeaderDateTime() {
    final now = DateTime.now();
    const meses = [
      '', 'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    final mes = meses[now.month];
    final hora = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minuto = now.minute.toString().padLeft(2, '0');
    final periodo = now.hour >= 12 ? 'PM' : 'AM';
    return '${now.day} de $mes del ${now.year} • $hora:$minuto $periodo';
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
    final existingByType = <AntecedentType, FhirAntecedent?>{};
    for (final type in AntecedentType.values) {
      existingByType[type] =
          await _fhirService.getLatestAntecedentByType(patientId, type);
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ─────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history_outlined,
                          color: Color(0xFFF59E0B), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Antecedentes clínicos',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B)),
                          ),
                          Text(
                            'Selecciona el que deseas actualizar',
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // ── Tarjetas por tipo ───────────────────────────────
                ...AntecedentType.values.map((type) {
                  final existing = existingByType[type];
                  final hasData = existing?.content.isNotEmpty == true;

                  final (Color typeColor, IconData typeIcon) = switch (type) {
                    AntecedentType.heredofamiliar => (
                      const Color(0xFF3B5BDB),
                      Icons.family_restroom_outlined,
                    ),
                    AntecedentType.noPatologico => (
                      const Color(0xFF10B981),
                      Icons.health_and_safety_outlined,
                    ),
                    AntecedentType.ginecoObstetrico => (
                      const Color(0xFFEC4899),
                      Icons.pregnant_woman_outlined,
                    ),
                  };

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          Navigator.pop(dialogCtx);
                          if (!mounted) return;
                          try {
                            await AntecedentFormDialog.show(
                              context: context,
                              patientId: _selectedPatient!.id ?? '',
                              ehrId: _selectedPatient!.ehrId,
                              type: type,
                              initialAntecedent: existing,
                              onBack: _openAntecedentQuickUpdate,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                            color: const Color(0xFFF8FAFC),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      typeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(typeIcon,
                                    size: 18, color: typeColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      type.displayName,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      hasData
                                          ? existing!.content
                                          : 'Sin registro',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: hasData
                                            ? const Color(0xFF64748B)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasData
                                      ? const Color(0xFF10B981)
                                          .withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  hasData ? 'Actual' : 'Nuevo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: hasData
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right,
                                  color: Color(0xFF94A3B8), size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
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
                _formatHeaderDateTime(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            _AntecedentHeaderBtn(onTap: _openAntecedentQuickUpdate),
            const SizedBox(width: 12),
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
                                label: 'Motivo de consulta',
                                hint: 'Razón principal de la visita (ej: dolor de cabeza, revisión anual, control de presión...)',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _padecimientoActualController,
                                label: 'Historia del padecimiento actual',
                                hint: 'Descripción detallada: inicio, duración, intensidad, síntomas asociados y evolución...',
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
                                hint: 'ej: Hipertensión arterial esencial, Diabetes mellitus tipo 2...',
                                maxLines: 2,
                              ),
                              const SizedBox(height: 14),
                              _buildField(
                                controller: _planTratamientoController,
                                label: 'Plan de tratamiento',
                                hint: 'ej: Metformina 850mg cada 12h, dieta baja en carbohidratos, control en 4 semanas...',
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 12),

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
                                _isSaving ? 'Guardando...' : 'Guardar',
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

  String? _validateVital(
      String? value, double min, double max, String rangeLabel) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Ingresa un número válido';
    if (parsed < min || parsed > max) return 'Rango válido: $rangeLabel';
    return null;
  }

  Widget _buildVitalsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildVitalField(
                'Peso (kg)',
                _pesoController,
                hint: 'ej: 70',
                validator: (v) => _validateVital(v, 0.5, 300, '0.5 – 300 kg'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildVitalField(
                'Talla (cm)',
                _tallaController,
                hint: 'ej: 170',
                validator: (v) => _validateVital(v, 30, 250, '30 – 250 cm'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildVitalField(
                'FC (lpm)',
                _frecuenciaCardiacaController,
                hint: 'ej: 75',
                validator: (v) => _validateVital(v, 20, 300, '20 – 300 lpm'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildVitalField(
                'FR (rpm)',
                _frecuenciaRespiratoriaController,
                hint: 'ej: 16',
                validator: (v) => _validateVital(v, 4, 60, '4 – 60 rpm'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildVitalField(
                'TA Sistólica (mmHg)',
                _sistolicaController,
                hint: 'ej: 120',
                validator: (v) {
                  final base = _validateVital(v, 50, 300, '50 – 300 mmHg');
                  if (base != null) return base;
                  final sist = double.tryParse(v?.trim() ?? '');
                  final dias = double.tryParse(_diastolicaController.text.trim());
                  if (sist != null && dias != null && sist <= dias) {
                    return 'Debe ser mayor que diastólica';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildVitalField(
                'TA Diastólica (mmHg)',
                _diastolicaController,
                hint: 'ej: 80',
                validator: (v) {
                  final base = _validateVital(v, 20, 200, '20 – 200 mmHg');
                  if (base != null) return base;
                  final sist = double.tryParse(_sistolicaController.text.trim());
                  final dias = double.tryParse(v?.trim() ?? '');
                  if (sist != null && dias != null && dias >= sist) {
                    return 'Debe ser menor que sistólica';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildVitalField(
                'Temp. (°C)',
                _temperaturaController,
                hint: 'ej: 36.5',
                validator: (v) => _validateVital(v, 25, 45, '25 – 45 °C'),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalField(
    String label,
    TextEditingController controller, {
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFFCBD5E1)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            errorStyle: const TextStyle(fontSize: 10, height: 1.2),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

}

class _AntecedentHeaderBtn extends StatefulWidget {
  final VoidCallback onTap;
  const _AntecedentHeaderBtn({required this.onTap});

  @override
  State<_AntecedentHeaderBtn> createState() => _AntecedentHeaderBtnState();
}

class _AntecedentHeaderBtnState extends State<_AntecedentHeaderBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFFF59E0B);
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered
                ? color.withValues(alpha: 0.18)
                : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: _hovered ? 0.5 : 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_outlined, size: 16, color: color),
              SizedBox(width: 6),
              Text(
                'Actualizar antecedentes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
