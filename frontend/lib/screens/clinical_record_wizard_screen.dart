import 'package:flutter/material.dart';
import '../models/fhir_diagnostic_report.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class ClinicalRecordWizardScreen extends StatefulWidget {
  final FhirPatient patient;

  const ClinicalRecordWizardScreen({
    super.key,
    required this.patient,
  });

  @override
  State<ClinicalRecordWizardScreen> createState() =>
      _ClinicalRecordWizardScreenState();
}

class _ClinicalRecordWizardScreenState
    extends State<ClinicalRecordWizardScreen> {
  final FhirService _fhirService = FhirService();

  final TextEditingController _doctorController =
      TextEditingController(text: 'Dr. Arturo ITSUR');
  final TextEditingController _motivoController = TextEditingController();
  final TextEditingController _padecimientoController = TextEditingController();
  final TextEditingController _heredoController = TextEditingController();
  final TextEditingController _viviendaController = TextEditingController();
  final TextEditingController _ginecoController = TextEditingController();
  final TextEditingController _sistolicaController = TextEditingController();
  final TextEditingController _diastolicaController = TextEditingController();
  final TextEditingController _frecuenciaCardiacaController =
      TextEditingController();
  final TextEditingController _frecuenciaRespiratoriaController =
      TextEditingController();
  final TextEditingController _temperaturaController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController _exploracionController = TextEditingController();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _planController = TextEditingController();

  String _tabaquismo = 'No fuma';
  String _alcoholismo = 'No consume alcohol';
  String _tipoConsulta = 'Consulta general';

  int _stepIndex = 0;
  bool _isSaving = false;

  static const List<String> _stepTitles = [
    'Informacion Basica',
    'Motivo de Consulta',
    'Padecimiento Actual',
    'Antecedentes Heredofamiliares',
    'Antecedentes Personales',
    'Antecedentes Gineco-Obstetricos',
    'Signos Vitales',
    'Exploracion Fisica',
    'Diagnostico y Plan',
  ];

  @override
  void dispose() {
    _doctorController.dispose();
    _motivoController.dispose();
    _padecimientoController.dispose();
    _heredoController.dispose();
    _viviendaController.dispose();
    _ginecoController.dispose();
    _sistolicaController.dispose();
    _diastolicaController.dispose();
    _frecuenciaCardiacaController.dispose();
    _frecuenciaRespiratoriaController.dispose();
    _temperaturaController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    _exploracionController.dispose();
    _diagnosticoController.dispose();
    _planController.dispose();
    super.dispose();
  }

  String _composeNoPatologicos() {
    final vivienda = _viviendaController.text.trim();
    final sections = [
      'Tabaquismo: $_tabaquismo',
      'Alcoholismo: $_alcoholismo',
      if (vivienda.isNotEmpty) 'Vivienda: $vivienda',
    ];
    return sections.join(', ');
  }

  String _composeSignosVitales() {
    final sections = <String>[];

    final sistolica = _sistolicaController.text.trim();
    final diastolica = _diastolicaController.text.trim();
    if (sistolica.isNotEmpty || diastolica.isNotEmpty) {
      sections.add(
          'TA: ${sistolica.isEmpty ? '-' : sistolica}/${diastolica.isEmpty ? '-' : diastolica} mmHg');
    }

    if (_frecuenciaCardiacaController.text.trim().isNotEmpty) {
      sections.add('FC: ${_frecuenciaCardiacaController.text.trim()} lpm');
    }
    if (_frecuenciaRespiratoriaController.text.trim().isNotEmpty) {
      sections.add('FR: ${_frecuenciaRespiratoriaController.text.trim()} rpm');
    }
    if (_temperaturaController.text.trim().isNotEmpty) {
      sections.add('Temp: ${_temperaturaController.text.trim()} °C');
    }
    if (_pesoController.text.trim().isNotEmpty) {
      sections.add('Peso: ${_pesoController.text.trim()} kg');
    }
    if (_tallaController.text.trim().isNotEmpty) {
      sections.add('Talla: ${_tallaController.text.trim()} cm');
    }

    return sections.join(', ');
  }

  Future<void> _saveRecord() async {
    if (_diagnosticoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Capture el diagnostico principal')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final sections = [
        'Tipo de consulta: $_tipoConsulta',
        'Motivo: ${_motivoController.text.trim()}',
        'Padecimiento actual: ${_padecimientoController.text.trim()}',
        'Antecedentes heredofamiliares: ${_heredoController.text.trim()}',
        'Antecedentes no patologicos: ${_composeNoPatologicos()}',
        'Antecedentes gineco-obstetricos: ${_ginecoController.text.trim()}',
        'Signos vitales: ${_composeSignosVitales()}',
        'Exploracion fisica: ${_exploracionController.text.trim()}',
        'Plan: ${_planController.text.trim()}',
      ].where((line) => !line.endsWith(': ')).join('\n');

      final report = FhirDiagnosticReport(
        status: 'final',
        category: 'OTH',
        code: _diagnosticoController.text.trim(),
        patientId: widget.patient.id,
        patientName: widget.patient.fullName,
        effectiveDateTime: DateTime.now(),
        conclusion: sections,
      );

      final created = await _fhirService.createDiagnosticReport(report);

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar expediente: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _nextStep() {
    if (_stepIndex < _stepTitles.length - 1) {
      setState(() => _stepIndex++);
    }
  }

  void _previousStep() {
    if (_stepIndex > 0) {
      setState(() => _stepIndex--);
    }
  }

  Widget _buildStepContent() {
    switch (_stepIndex) {
      case 0:
        return _section(
          title: 'Informacion del Medico y Consulta',
          child: Column(
            children: [
              TextField(
                controller: _doctorController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Medico',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Paciente',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Nombre: ${widget.patient.fullName}'),
                      Text(
                          'EHR ID: ${widget.patient.ehrId ?? 'Sin EHR asignado'}'),
                      Text('Fecha: ${DateTime.now().toIso8601String()}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return _section(
          title: 'Motivo de Consulta',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _tipoConsulta,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Consulta',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Consulta general',
                    child: Text('Consulta general'),
                  ),
                  DropdownMenuItem(
                    value: 'Primera vez',
                    child: Text('Primera vez'),
                  ),
                  DropdownMenuItem(
                    value: 'Subsecuente',
                    child: Text('Subsecuente'),
                  ),
                  DropdownMenuItem(
                    value: 'Urgencias',
                    child: Text('Urgencias'),
                  ),
                  DropdownMenuItem(
                    value: 'Interconsulta',
                    child: Text('Interconsulta'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tipoConsulta = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _motivoController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Problema Presentado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Describe brevemente el motivo principal de la consulta',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        );
      case 2:
        return _singleFieldSection(
          title: 'Padecimiento Actual',
          controller: _padecimientoController,
          label: 'Historia del Padecimiento',
          helper:
              'Incluye: inicio, duracion, evolucion, sintomas asociados, tratamientos previos.',
        );
      case 3:
        return _singleFieldSection(
          title: 'Antecedentes Heredofamiliares',
          controller: _heredoController,
          label: 'Resumen de Antecedentes Familiares',
          helper:
              'Incluye: diabetes, hipertension, cancer, enfermedades cardiacas, etc.',
        );
      case 4:
        return _section(
          title: 'Antecedentes Personales No Patologicos',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _tabaquismo,
                decoration: const InputDecoration(
                  labelText: 'Tabaquismo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'No fuma', child: Text('No fuma')),
                  DropdownMenuItem(
                      value: 'Fumador ocasional',
                      child: Text('Fumador ocasional')),
                  DropdownMenuItem(
                      value: 'Fumador activo', child: Text('Fumador activo')),
                  DropdownMenuItem(
                      value: 'Exfumador', child: Text('Exfumador')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _tabaquismo = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _alcoholismo,
                decoration: const InputDecoration(
                  labelText: 'Alcoholismo',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'No consume alcohol',
                      child: Text('No consume alcohol')),
                  DropdownMenuItem(
                      value: 'Consumo social', child: Text('Consumo social')),
                  DropdownMenuItem(
                      value: 'Consumo frecuente',
                      child: Text('Consumo frecuente')),
                  DropdownMenuItem(
                      value: 'Abstinente', child: Text('Abstinente')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _alcoholismo = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _viviendaController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Vivienda',
                  hintText: 'Ej: Casa propia, servicios basicos completos',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      case 5:
        return _singleFieldSection(
          title: 'Antecedentes Gineco-Obstetricos',
          controller: _ginecoController,
          label: 'Resumen',
        );
      case 6:
        return _section(
          title: 'Signos Vitales',
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Presion Arterial',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _vitalField(
                      controller: _sistolicaController,
                      label: 'Sistolica',
                      unit: 'mmHg',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _vitalField(
                      controller: _diastolicaController,
                      label: 'Diastolica',
                      unit: 'mmHg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Frecuencia Cardiaca',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _vitalField(
                controller: _frecuenciaCardiacaController,
                label: 'Valor',
                unit: 'lpm',
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Frecuencia Respiratoria',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _vitalField(
                controller: _frecuenciaRespiratoriaController,
                label: 'Valor',
                unit: 'rpm',
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Temperatura',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _vitalField(
                controller: _temperaturaController,
                label: 'Valor',
                unit: '°C',
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Peso',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _vitalField(
                controller: _pesoController,
                label: 'Valor',
                unit: 'kg',
              ),
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Talla',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              _vitalField(
                controller: _tallaController,
                label: 'Valor',
                unit: 'cm',
              ),
            ],
          ),
        );
      case 7:
        return _singleFieldSection(
          title: 'Exploracion Fisica',
          controller: _exploracionController,
          label: 'Descripcion de la exploracion',
          helper:
              'Incluye: inspeccion, palpacion, percusion y auscultacion por sistemas.',
        );
      default:
        return _section(
          title: 'Diagnostico y Plan de Tratamiento',
          child: Column(
            children: [
              TextField(
                controller: _diagnosticoController,
                decoration: const InputDecoration(
                  labelText: 'Diagnostico Principal',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _planController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Descripcion Clinica / Plan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Expediente Clinico Completado\nRevise los datos y presione Guardar.',
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _vitalField({
    required TextEditingController controller,
    required String label,
    required String unit,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _singleFieldSection({
    required String title,
    required TextEditingController controller,
    required String label,
    String? helper,
  }) {
    return _section(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: controller,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 8),
            Text(
              helper,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _stepIndex + 1;
    final total = _stepTitles.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expediente Clinico'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveRecord,
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: current / total,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Paso $current de $total'),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey.shade100,
            child: Text(
              _stepTitles[_stepIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepContent(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _stepIndex == 0 ? null : _previousStep,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _stepIndex == total - 1 ? null : _nextStep,
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                        _stepIndex == total - 1 ? 'Finalizado' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
