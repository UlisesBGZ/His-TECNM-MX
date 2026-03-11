import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_diagnostic_report.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class ReportFormScreen extends StatefulWidget {
  final FhirDiagnosticReport? report;

  const ReportFormScreen({super.key, this.report});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _conclusionController = TextEditingController();

  List<FhirPatient> _patients = [];
  FhirPatient? _selectedPatient;
  String _selectedStatus = 'preliminary';
  String? _selectedCategory;
  DateTime? _effectiveDate;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    // No llamar _populateFields aquí, se llama después de cargar los pacientes
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoading = true);
    try {
      final patients = await _fhirService.getPatients();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
      // Poblar campos después de cargar los pacientes
      if (widget.report != null) {
        _populateFields();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _populateFields() {
    final report = widget.report!;
    _codeController.text = report.code;
    _conclusionController.text = report.conclusion ?? '';
    _selectedStatus = report.status;
    _selectedCategory = report.category;
    _effectiveDate = report.effectiveDateTime;

    if (report.patientId != null && _patients.isNotEmpty) {
      try {
        _selectedPatient = _patients.firstWhere(
          (p) => p.id == report.patientId,
        );
      } catch (e) {
        // Si no se encuentra el paciente, dejar null
        _selectedPatient = null;
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _effectiveDate = picked;
      });
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seleccione un paciente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final report = FhirDiagnosticReport(
        id: widget.report?.id,
        status: _selectedStatus,
        category: _selectedCategory,
        code: _codeController.text,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        effectiveDateTime: _effectiveDate ?? DateTime.now(),
        conclusion: _conclusionController.text.isNotEmpty
            ? _conclusionController.text
            : null,
      );

      FhirDiagnosticReport savedReport;

      if (widget.report == null) {
        savedReport = await _fhirService.createDiagnosticReport(report);
      } else {
        savedReport = await _fhirService.updateDiagnosticReport(report);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.report == null
                  ? 'Reporte creado exitosamente'
                  : 'Reporte actualizado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, savedReport);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.report == null ? 'Nuevo Reporte' : 'Editar Reporte'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de paciente
                    DropdownButtonFormField<FhirPatient>(
                      value: _selectedPatient,
                      decoration: InputDecoration(
                        labelText: 'Paciente *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      items: _patients.map((patient) {
                        return DropdownMenuItem(
                          value: patient,
                          child: Text(patient.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPatient = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un paciente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de reporte
                    TextFormField(
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Tipo de Reporte *',
                        hintText: 'Ej: Hemograma completo',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el tipo de reporte';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'LAB', child: Text('Laboratorio')),
                        DropdownMenuItem(
                            value: 'RAD', child: Text('Radiología')),
                        DropdownMenuItem(
                            value: 'PATH', child: Text('Patología')),
                        DropdownMenuItem(
                            value: 'MB', child: Text('Microbiología')),
                        DropdownMenuItem(value: 'GE', child: Text('Genética')),
                        DropdownMenuItem(value: 'OTH', child: Text('Otro')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Estado *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.flag),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'registered', child: Text('Registrado')),
                        DropdownMenuItem(
                            value: 'partial', child: Text('Parcial')),
                        DropdownMenuItem(
                            value: 'preliminary', child: Text('Preliminar')),
                        DropdownMenuItem(value: 'final', child: Text('Final')),
                        DropdownMenuItem(
                            value: 'amended', child: Text('Modificado')),
                        DropdownMenuItem(
                            value: 'corrected', child: Text('Corregido')),
                        DropdownMenuItem(
                            value: 'cancelled', child: Text('Cancelado')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha efectiva
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha del Estudio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _effectiveDate != null
                              ? DateFormat('dd/MM/yyyy').format(_effectiveDate!)
                              : 'Seleccionar fecha',
                          style: TextStyle(
                            color: _effectiveDate != null
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Conclusión
                    TextFormField(
                      controller: _conclusionController,
                      decoration: InputDecoration(
                        labelText: 'Conclusión / Observaciones',
                        hintText: 'Ingrese los resultados o conclusiones...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.notes),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 24),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: FilledButton(
                            onPressed: _isSaving ? null : _saveReport,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(widget.report == null
                                    ? 'Crear'
                                    : 'Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _conclusionController.dispose();
    super.dispose();
  }
}
