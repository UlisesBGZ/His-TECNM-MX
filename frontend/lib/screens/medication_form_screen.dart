import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/fhir_medication_request.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class MedicationFormScreen extends StatefulWidget {
  final FhirMedicationRequest? medication;

  const MedicationFormScreen({super.key, this.medication});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _daysSupplyController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<FhirPatient> _patients = [];
  FhirPatient? _selectedPatient;
  String _selectedStatus = 'active';
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
      if (widget.medication != null) {
        _populateFields();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar pacientes: $e')),
        );
      }
    }
  }

  void _populateFields() {
    final med = widget.medication!;
    _medicationController.text = med.medication;
    _dosageController.text = med.dosageInstruction ?? '';
    _quantityController.text = med.quantityValue?.toString() ?? '';
    _daysSupplyController.text = med.daysSupply?.toString() ?? '';
    _noteController.text = med.note ?? '';
    _selectedStatus = med.status;

    if (med.patientId != null && _patients.isNotEmpty) {
      try {
        _selectedPatient = _patients.firstWhere(
          (p) => p.id == med.patientId,
        );
      } catch (e) {
        // Si no se encuentra el paciente, dejar null
        _selectedPatient = null;
      }
    }
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _quantityController.dispose();
    _daysSupplyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un paciente')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final int? quantity = _quantityController.text.isEmpty
          ? null
          : int.tryParse(_quantityController.text);
      final int? daysSupply = _daysSupplyController.text.isEmpty
          ? null
          : int.tryParse(_daysSupplyController.text);

      final medication = FhirMedicationRequest(
        id: widget.medication?.id,
        status: _selectedStatus,
        intent: 'order',
        medication: _medicationController.text,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        dosageInstruction:
            _dosageController.text.isNotEmpty ? _dosageController.text : null,
        quantityValue: quantity,
        daysSupply: daysSupply,
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        authoredOn: widget.medication?.authoredOn ?? DateTime.now(),
      );

      FhirMedicationRequest savedMedication;

      if (widget.medication == null) {
        savedMedication =
            await _fhirService.createMedicationRequest(medication);
      } else {
        savedMedication =
            await _fhirService.updateMedicationRequest(medication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.medication == null
                  ? 'Receta creada exitosamente'
                  : 'Receta actualizada exitosamente',
            ),
          ),
        );
        Navigator.pop(context, savedMedication);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.medication == null ? 'Nueva Receta' : 'Editar Receta',
        ),
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
                    DropdownButtonFormField<FhirPatient>(
                      value: _selectedPatient,
                      decoration: const InputDecoration(
                        labelText: 'Paciente *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: _patients.map((patient) {
                        return DropdownMenuItem(
                          value: patient,
                          child: Text(patient.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedPatient = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un paciente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _medicationController,
                      decoration: const InputDecoration(
                        labelText: 'Medicamento *',
                        hintText: 'Ej: Paracetamol 500mg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el medicamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        labelText: 'Instrucciones de dosificación',
                        hintText: 'Ej: 1 comprimido cada 8 horas',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad',
                              hintText: '30',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.pin),
                              suffixText: 'comp.',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _daysSupplyController,
                            decoration: const InputDecoration(
                              labelText: 'Días suministro',
                              hintText: '10',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                              suffixText: 'días',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Estado *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'active', child: Text('Activa')),
                        DropdownMenuItem(
                            value: 'on-hold', child: Text('En espera')),
                        DropdownMenuItem(
                            value: 'cancelled', child: Text('Cancelada')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completada')),
                        DropdownMenuItem(
                            value: 'entered-in-error', child: Text('Error')),
                        DropdownMenuItem(
                            value: 'stopped', child: Text('Detenida')),
                        DropdownMenuItem(
                            value: 'draft', child: Text('Borrador')),
                      ],
                      onChanged: (value) {
                        setState(() => _selectedStatus = value ?? 'active');
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Notas',
                        hintText: 'Observaciones adicionales',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSaving ? null : _saveMedication,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.medication == null
                                  ? 'Crear Receta'
                                  : 'Actualizar Receta',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
