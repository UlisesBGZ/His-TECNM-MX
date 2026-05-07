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
                  trailing: IconButton(
                    icon: const Icon(Icons.refresh_outlined,
                        size: 18, color: Color(0xFF64748B)),
                    onPressed: _loadEncounters,
                    tooltip: 'Actualizar',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          InkWell(
            onTap: _navigateToEncounterForm,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 16, color: _green),
                  SizedBox(width: 6),
                  Text(
                    'Agregar Encuentro',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEncounterTile(FhirEncounter encounter) {
    final statusColor = _getStatusColor(encounter.status);
    final statusText = encounter.statusDisplay;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: date + status badge
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          // Motivo
          if (encounter.motivoConsulta != null &&
              encounter.motivoConsulta!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_outlined,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    encounter.motivoConsulta!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF334155)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          // Diagnóstico
          if (encounter.diagnostico != null &&
              encounter.diagnostico!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.assignment_outlined,
                    size: 13, color: Color(0xFF94A3B8)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    encounter.diagnostico!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF334155)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'active':
        return const Color(0xFF3B82F6);
      case 'finalized':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _formatDate(String dateString) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateString));
    } catch (_) {
      return dateString;
    }
  }
}
