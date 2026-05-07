import 'package:flutter/material.dart';
import '../models/fhir_diagnostic_report.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';
import 'clinical_record_detail_screen.dart';
import 'clinical_record_wizard_screen.dart';

class ClinicalRecordListScreen extends StatefulWidget {
  final FhirPatient patient;

  const ClinicalRecordListScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ClinicalRecordListScreen> createState() =>
      _ClinicalRecordListScreenState();
}

class _ClinicalRecordListScreenState extends State<ClinicalRecordListScreen> {
  final FhirService _fhirService = FhirService();
  bool _isLoading = true;
  String? _error;
  List<FhirDiagnosticReport> _records = [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await _fhirService.getDiagnosticReports(count: 300);
      final filtered = reports
          .where((report) => report.patientId == widget.patient.id)
          .toList().cast<FhirDiagnosticReport>()
        ..sort((a, b) {
          final aTime =
              (a.effectiveDateTime ?? a.issued)?.millisecondsSinceEpoch ?? 0;
          final bTime =
              (b.effectiveDateTime ?? b.issued)?.millisecondsSinceEpoch ?? 0;
          return bTime.compareTo(aTime);
        });

      if (!mounted) return;
      setState(() {
        _records = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateRecord() async {
    final created = await Navigator.of(context).push<FhirDiagnosticReport>(
      MaterialPageRoute(
        builder: (_) => ClinicalRecordWizardScreen(patient: widget.patient),
      ),
    );

    if (created != null && mounted) {
      await _loadRecords();
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.fullName),
        actions: [
          IconButton(
            onPressed: _loadRecords,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRecord,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Expediente Clínico'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 52),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadRecords,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return const Center(
        child: Text('Sin expedientes clínicos aún'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          final date = record.effectiveDateTime ?? record.issued;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.description),
              ),
              title: Text(
                record.code,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                'Médico: ${record.practitionerName ?? 'No definido'}\nFecha: ${_formatDate(date)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ClinicalRecordDetailScreen(
                      report: record,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
