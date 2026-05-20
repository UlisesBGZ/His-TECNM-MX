import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_patient.dart';
import '../models/fhir_encounter.dart';
import '../services/fhir_service.dart';
import 'clinical_antecedents_section.dart';
import 'antecedent_form_dialog.dart';
import 'encounter_form_screen.dart';

class PatientClinicalViewScreen extends StatefulWidget {
  final FhirPatient patient;

  const PatientClinicalViewScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientClinicalViewScreen> createState() =>
      _PatientClinicalViewScreenState();
}

class _PatientClinicalViewScreenState extends State<PatientClinicalViewScreen> {
  final FhirService _fhirService = FhirService();
  final GlobalKey<ClinicalAntecedentsSectionState> _antecedentsSectionKey =
      GlobalKey();
  List<FhirEncounter> _encounters = [];
  bool _isLoadingEncounters = false;

  static const _primary = Color(0xFF3B5BDB);
  static const _green = Color(0xFF10B981);
  static const _bg = Color(0xFFF4F6FB);

  @override
  void initState() {
    super.initState();
    _loadEncounters();
  }

  Future<void> _loadEncounters() async {
    setState(() => _isLoadingEncounters = true);
    try {
      final all = await _fhirService.getEncounters(count: 100);
      final filtered =
          all.where((e) => e.patientId == widget.patient.id).toList();
      if (mounted) setState(() { _encounters = filtered; _isLoadingEncounters = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoadingEncounters = false);
    }
  }

  void _navigateToEncounterForm() async {
    final result = await Navigator.push<FhirEncounter?>(
      context,
      MaterialPageRoute(
        builder: (_) => EncounterFormScreen(patientId: widget.patient.id ?? ''),
      ),
    );
    if (result != null && mounted) {
      setState(() => _encounters.insert(0, result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth >= 800;
      final hPad = isWide ? 40.0 : 16.0;

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
                widget.patient.fullName,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Text(
                'Expediente clínico',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE2E8F0)),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              children: [
                _buildPatientInfoCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  icon: Icons.history_edu_outlined,
                  title: 'Antecedentes clínicos',
                  color: _primary,
                ),
                const SizedBox(height: 10),
                _buildAntecedentsCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(
                  icon: Icons.local_hospital_outlined,
                  title: 'Encuentros',
                  color: _green,
                  trailing: _HeaderBtn(
                    icon: Icons.add_rounded,
                    color: _green,
                    tooltip: 'Agregar encuentro',
                    onTap: _navigateToEncounterForm,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 10),
                _buildEncountersCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ── Section header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing,
        ],
      ],
    );
  }

  // ── Patient info card ─────────────────────────────────────────────────────

  Widget _buildPatientInfoCard() {
    final avatarColor = widget.patient.gender == 'male'
        ? const Color(0xFF3B82F6)
        : widget.patient.gender == 'female'
            ? const Color(0xFFEC4899)
            : const Color(0xFF8B5CF6);

    final initial = widget.patient.fullName.isNotEmpty
        ? widget.patient.fullName[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: avatarColor.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: avatarColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patient.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                if (widget.patient.identifier != null)
                  _infoRow(Icons.badge_outlined, 'ID: ${widget.patient.identifier}'),
                if (widget.patient.birthDate != null)
                  _infoRow(Icons.cake_outlined,
                      'Nacimiento: ${_formatDate(widget.patient.birthDate!)}'),
                if (widget.patient.gender != null)
                  _infoRow(Icons.person_outline,
                      widget.patient.gender == 'male' ? 'Masculino' : 'Femenino'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Antecedents card ──────────────────────────────────────────────────────

  Widget _buildAntecedentsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      clipBehavior: Clip.hardEdge,
      child: ClinicalAntecedentsSection(
        key: _antecedentsSectionKey,
        patientId: widget.patient.id ?? '',
        patientGender: widget.patient.gender,
        onAntecedentUpdated: () {},
        onAddAntecedent: (type) async {
          final existing = await _fhirService.getLatestAntecedentByType(
            widget.patient.id ?? '',
            type,
          );
          if (mounted) {
            await AntecedentFormDialog.show(
              context: context,
              patientId: widget.patient.id ?? '',
              ehrId: widget.patient.ehrId,
              type: type,
              initialAntecedent: existing,
              onSaved: (saved) async {
                _antecedentsSectionKey.currentState?.applySavedAntecedent(saved);
              },
            );
          }
        },
      ),
    );
  }

  // ── Encounters card ───────────────────────────────────────────────────────

  Widget _buildEncountersCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          if (_isLoadingEncounters)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_encounters.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.medical_services_outlined,
                      size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No hay encuentros registrados',
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _encounters.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              itemBuilder: (_, i) => _buildEncounterTile(_encounters[i]),
            ),
        ],
      ),
    );
  }

  void _showEditWarning(FhirEncounter encounter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.warning_amber_rounded,
              size: 28, color: Color(0xFFD97706)),
        ),
        title: const Text(
          'Modificar encuentro',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1F36)),
        ),
        content: const Text(
          'Estás a punto de editar un registro clínico existente.\n\n'
          'Cualquier cambio que realices se verá reflejado en el historial clínico del paciente y podría afectar la trazabilidad del expediente.\n\n'
          '¿Deseas continuar?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF64748B),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Cancelar'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await Navigator.push<FhirEncounter?>(
                context,
                MaterialPageRoute(
                  builder: (_) => EncounterFormScreen(
                    encounter: encounter,
                    patientId: widget.patient.id ?? '',
                  ),
                ),
              );
              if (result != null && mounted) {
                setState(() {
                  final idx =
                      _encounters.indexWhere((e) => e.id == result.id);
                  if (idx != -1) _encounters[idx] = result;
                });
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Sí, editar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterTile(FhirEncounter encounter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: date + edit button
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 5),
              Text(
                encounter.dateTimeDisplay,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showEditWarning(encounter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 12, color: Color(0xFF64748B)),
                      SizedBox(width: 4),
                      Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Motivo
          if (encounter.motivoConsulta != null &&
              encounter.motivoConsulta!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _clinicalField(
              icon: Icons.notes_outlined,
              label: 'Motivo de consulta',
              value: encounter.motivoConsulta!,
            ),
          ],

          // Diagnóstico
          if (encounter.diagnostico != null &&
              encounter.diagnostico!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _clinicalField(
              icon: Icons.assignment_outlined,
              label: 'Diagnóstico',
              value: encounter.diagnostico!,
            ),
          ],

          // Signos vitales
          if (encounter.vitals != null && _hasAnyVital(encounter.vitals!)) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (encounter.vitals!.weight != null)
                  _vitalChip('⚖ ${encounter.vitals!.weight!.toStringAsFixed(1)} kg'),
                if (encounter.vitals!.height != null)
                  _vitalChip('📏 ${encounter.vitals!.height!.toStringAsFixed(1)} cm'),
                if (encounter.vitals!.heartRate != null)
                  _vitalChip('❤ ${encounter.vitals!.heartRate!.toStringAsFixed(0)} lpm'),
                if (encounter.vitals!.temperature != null)
                  _vitalChip('🌡 ${encounter.vitals!.temperature!.toStringAsFixed(1)}°C'),
                if (encounter.vitals!.systolic != null &&
                    encounter.vitals!.diastolic != null)
                  _vitalChip(
                      '💉 ${encounter.vitals!.systolic!.toStringAsFixed(0)}/${encounter.vitals!.diastolic!.toStringAsFixed(0)} mmHg'),
                if (encounter.vitals!.respiratoryRate != null)
                  _vitalChip('🫁 ${encounter.vitals!.respiratoryRate!.toStringAsFixed(0)} rpm'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _clinicalField({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFF94A3B8)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF94A3B8),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _vitalChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8)),
      ),
    );
  }

  bool _hasAnyVital(vitals) =>
      vitals.systolic != null ||
      vitals.heartRate != null ||
      vitals.temperature != null ||
      vitals.respiratoryRate != null ||
      vitals.weight != null ||
      vitals.height != null;

  String _formatDate(String dateString) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
    } catch (_) {
      return dateString;
    }
  }
}

// ── Header button ──────────────────────────────────────────────────────────────

class _HeaderBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;

  const _HeaderBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    this.filled = false,
  });

  @override
  State<_HeaderBtn> createState() => _HeaderBtnState();
}

class _HeaderBtnState extends State<_HeaderBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.filled
                  ? widget.color.withValues(alpha: _hovered ? 0.85 : 1.0)
                  : widget.color.withValues(alpha: _hovered ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.color.withValues(alpha: widget.filled ? 0 : 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.icon,
                  size: 14,
                  color: widget.filled ? Colors.white : widget.color,
                ),
                if (widget.filled) ...[
                  const SizedBox(width: 4),
                  Text(
                    'Agregar',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.filled ? Colors.white : widget.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
