import 'package:flutter/material.dart';
import '../models/fhir_diagnostic_report.dart';

class ClinicalRecordDetailScreen extends StatelessWidget {
  final FhirDiagnosticReport report;

  const ClinicalRecordDetailScreen({
    super.key,
    required this.report,
  });

  String _dateText(DateTime? date) {
    if (date == null) return 'Sin fecha';
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String? _extractSectionValue(String key, String? source) {
    if (source == null || source.trim().isEmpty) {
      return null;
    }
    final lines = source.split('\n');
    final prefix = '$key:';
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.toLowerCase().startsWith(prefix.toLowerCase())) {
        return trimmed.substring(prefix.length).trim();
      }
    }
    return null;
  }

  String _vitalValue(String source, String code) {
    final pattern = RegExp('$code:\\s*([^,]+)');
    final match = pattern.firstMatch(source);
    if (match == null) {
      return 'No registrada';
    }
    return match.group(1)?.trim() ?? 'No registrada';
  }

  Widget _kvLine(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 17),
          children: [
            TextSpan(
              text: '$title: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = report.effectiveDateTime ?? report.issued;
    final fullConclusion =
        report.conclusion?.trim().isNotEmpty == true ? report.conclusion! : '';
    final tipoConsulta =
        _extractSectionValue('Tipo de consulta', fullConclusion) ??
            'No registrado';
    final motivo =
        _extractSectionValue('Motivo', fullConclusion) ?? 'No registrado';
    final padecimiento =
        _extractSectionValue('Padecimiento actual', fullConclusion) ??
            'No registrado';
    final heredo =
        _extractSectionValue('Antecedentes heredofamiliares', fullConclusion) ??
            'No registrado';
    final signos = _extractSectionValue('Signos vitales', fullConclusion) ?? '';
    final plan =
        _extractSectionValue('Plan', fullConclusion) ?? 'Sin descripción';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Expediente'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _sectionCard(
            context,
            icon: Icons.info_outline,
            title: 'Información General',
            children: [
              Text('Médico: ${report.practitionerName ?? 'No definido'}'),
              const SizedBox(height: 4),
              Text('Fecha: ${_dateText(date)}'),
              const SizedBox(height: 4),
              Text('UID: ${report.id ?? 'Sin UID'}'),
            ],
          ),
          _sectionCard(
            context,
            icon: Icons.chat_bubble_outline,
            title: 'Motivo de Consulta',
            children: [
              Text('Tipo de Consulta: $tipoConsulta'),
              const SizedBox(height: 4),
              Text('Problema Presentado: $motivo'),
            ],
          ),
          _sectionCard(
            context,
            icon: Icons.monitor_heart_outlined,
            title: 'Padecimiento Actual',
            children: [
              Text(padecimiento),
            ],
          ),
          _sectionCard(
            context,
            icon: Icons.family_restroom,
            title: 'Antecedentes Heredofamiliares',
            children: [
              Text('Resumen: $heredo'),
            ],
          ),
          _sectionCard(
            context,
            icon: Icons.favorite,
            title: 'Signos Vitales',
            children: [
              _kvLine('Presión Arterial', _vitalValue(signos, 'TA')),
              _kvLine('Frecuencia Cardíaca', _vitalValue(signos, 'FC')),
              _kvLine('Frecuencia Respiratoria', _vitalValue(signos, 'FR')),
              _kvLine('Temperatura', _vitalValue(signos, 'Temp')),
              _kvLine('Peso', _vitalValue(signos, 'Peso')),
              _kvLine('Talla', _vitalValue(signos, 'Talla')),
            ],
          ),
          _sectionCard(
            context,
            icon: Icons.medical_information,
            title: 'Diagnóstico',
            children: [
              Text('Diagnóstico: ${report.code}'),
              const SizedBox(height: 4),
              Text('Descripción: $plan'),
            ],
          ),
        ],
      ),
    );
  }
}
