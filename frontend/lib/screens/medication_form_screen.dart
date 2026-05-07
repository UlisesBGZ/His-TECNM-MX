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

  final TextEditingController _medicationGenericController =
      TextEditingController();
  final TextEditingController _presentationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _daysSupplyController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<FhirPatient> _patients = [];
  List<FhirMedicationRequest> _groupedMedications = [];
  FhirPatient? _selectedPatient;
  String _selectedStatus = 'active';
  String? _currentBatchGroupId;
  bool _isLoading = false;
  bool _isLoadingGroupedMedications = false;
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
        await _loadGroupedMedications();
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

  Future<void> _loadGroupedMedications() async {
    final current = widget.medication;
    if (current == null ||
        current.groupIdentifier == null ||
        current.groupIdentifier!.trim().isEmpty) {
      return;
    }

    setState(() => _isLoadingGroupedMedications = true);
    try {
      final grouped = await _fhirService.getMedicationRequestsByGroupIdentifier(
        current.groupIdentifier!,
        patientId: current.patientId,
        excludeMedicationId: current.id,
      );
      if (!mounted) return;
      setState(() {
        _groupedMedications = grouped;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _groupedMedications = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingGroupedMedications = false);
      }
    }
  }

  void _populateFields() {
    final med = widget.medication!;
    final medicationParts = med.medication.split(' - ');
    if (medicationParts.length >= 2) {
      _medicationGenericController.text = medicationParts.first.trim();
      _presentationController.text =
          medicationParts.sublist(1).join(' - ').trim();
    } else {
      _medicationGenericController.text = med.medication;
    }

    _applyDosageFieldsFromMedication(med.dosageInstruction);
    _quantityController.text = med.quantityValue?.toString() ?? '';
    _daysSupplyController.text = med.daysSupply?.toString() ?? '';
    _noteController.text = med.note ?? '';
    _selectedStatus = med.status;
    _currentBatchGroupId = med.groupIdentifier;

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

  void _applyDosageFieldsFromMedication(String? dosageInstruction) {
    if (dosageInstruction == null || dosageInstruction.trim().isEmpty) {
      return;
    }

    final raw = dosageInstruction.trim();
    if (!raw.contains('|')) {
      _instructionsController.text = raw;
      return;
    }

    final parts = raw
        .split('|')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isNotEmpty) {
      _doseController.text = parts[0];
    }
    if (parts.length > 1) {
      _frequencyController.text = parts[1];
    }
    if (parts.length > 2) {
      final routePart = parts[2];
      _routeController.text = routePart.toLowerCase().startsWith('via ')
          ? routePart.substring(4).trim()
          : routePart;
    }
    if (parts.length > 3) {
      _instructionsController.text = parts.sublist(3).join(' | ');
    } else {
      _instructionsController.text = '';
    }
  }

  String _ensureBatchGroupId() {
    _currentBatchGroupId ??=
        'RX-${DateTime.now().millisecondsSinceEpoch}-${_selectedPatient?.id ?? 'NA'}';
    return _currentBatchGroupId!;
  }

  void _clearMedicationFieldsForNextItem() {
    _medicationGenericController.clear();
    _presentationController.clear();
    _doseController.clear();
    _routeController.clear();
    _frequencyController.clear();
    _instructionsController.clear();
    _quantityController.clear();
    _daysSupplyController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    _medicationGenericController.dispose();
    _presentationController.dispose();
    _doseController.dispose();
    _routeController.dispose();
    _frequencyController.dispose();
    _diagnosisController.dispose();
    _instructionsController.dispose();
    _quantityController.dispose();
    _daysSupplyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String _composeDosageInstruction() {
    final parts = <String>[];

    if (_doseController.text.trim().isNotEmpty) {
      parts.add(_doseController.text.trim());
    }
    if (_frequencyController.text.trim().isNotEmpty) {
      parts.add(_frequencyController.text.trim());
    }
    if (_routeController.text.trim().isNotEmpty) {
      parts.add('via ${_routeController.text.trim()}');
    }
    if (_instructionsController.text.trim().isNotEmpty) {
      parts.add(_instructionsController.text.trim());
    }

    return parts.join(' | ');
  }

  String _composeClinicalNote() {
    final segments = <String>[];

    if (_diagnosisController.text.trim().isNotEmpty) {
      segments.add('Diagnostico: ${_diagnosisController.text.trim()}');
    }
    if (_noteController.text.trim().isNotEmpty) {
      segments.add(_noteController.text.trim());
    }

    return segments.join(' | ');
  }

  Future<void> _saveMedication({bool addAnother = false}) async {
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
      final keepFormOpen = addAnother && widget.medication == null;
      final int? quantity = int.tryParse(_quantityController.text);
      final int? daysSupply = _daysSupplyController.text.isEmpty
          ? null
          : int.tryParse(_daysSupplyController.text);

      if (quantity == null || quantity <= 0) {
        throw Exception('La cantidad total debe ser mayor a 0');
      }

      if (daysSupply != null && daysSupply <= 0) {
        throw Exception('Los dias de suministro deben ser mayores a 0');
      }

      final medicationText =
          '${_medicationGenericController.text.trim()} - ${_presentationController.text.trim()}';
      final dosageInstruction = _composeDosageInstruction();
      final note = _composeClinicalNote();
      final groupIdentifier = widget.medication?.groupIdentifier ??
          (keepFormOpen ? _ensureBatchGroupId() : _currentBatchGroupId);

      final medication = FhirMedicationRequest(
        id: widget.medication?.id,
        status: _selectedStatus,
        intent: 'order',
        medication: medicationText,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        dosageInstruction: dosageInstruction,
        quantityValue: quantity,
        daysSupply: daysSupply,
        note: note.isNotEmpty ? note : null,
        authoredOn: widget.medication?.authoredOn ?? DateTime.now(),
        groupIdentifier: groupIdentifier,
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
        if (keepFormOpen) {
          _clearMedicationFieldsForNextItem();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Medicamento agregado. Puede capturar el siguiente para el mismo paciente.',
              ),
            ),
          );
        } else {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
                      controller: _medicationGenericController,
                      decoration: const InputDecoration(
                        labelText: 'Medicamento (nombre generico) *',
                        hintText: 'Ej: Paracetamol',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese el nombre generico del medicamento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _presentationController,
                      decoration: const InputDecoration(
                        labelText: 'Presentacion y concentracion *',
                        hintText: 'Ej: Tableta 500 mg',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese presentacion y concentracion';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _doseController,
                      decoration: const InputDecoration(
                        labelText: 'Dosis *',
                        hintText: 'Ej: 1 tableta',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.schedule),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese la dosis';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _routeController,
                            decoration: const InputDecoration(
                              labelText: 'Via de administracion *',
                              hintText: 'Ej: oral',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.route),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _frequencyController,
                            decoration: const InputDecoration(
                              labelText: 'Frecuencia *',
                              hintText: 'Ej: cada 8 horas',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.repeat),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Indicaciones al paciente *',
                        hintText: 'Ej: tomar despues de alimentos',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingrese indicaciones al paciente';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Cantidad total a surtir *',
                              hintText: '30',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.pin),
                              suffixText: 'comp.',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Requerido';
                              }
                              final parsed = int.tryParse(value);
                              if (parsed == null || parsed <= 0) {
                                return '> 0';
                              }
                              return null;
                            },
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.blueGrey.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Para varios medicamentos del mismo paciente, registre uno por uno. Cada registro crea un MedicationRequest valido y puede agruparse en la misma receta clinica.',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (widget.medication != null &&
                        _currentBatchGroupId != null &&
                        _currentBatchGroupId!.isNotEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medicamentos en esta receta agrupada',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Grupo: $_currentBatchGroupId',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isLoadingGroupedMedications)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: LinearProgressIndicator(),
                                )
                              else if (_groupedMedications.isEmpty)
                                const Text(
                                  'No hay otros medicamentos en este grupo.',
                                )
                              else
                                ..._groupedMedications.map(
                                  (item) => ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: const Icon(Icons.medication),
                                    title: Text(item.medication),
                                    subtitle: Text(
                                      'Estado: ${item.statusDisplay}${item.supplyDisplay != null ? ' • ${item.supplyDisplay}' : ''}',
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (widget.medication != null &&
                        _currentBatchGroupId != null &&
                        _currentBatchGroupId!.isNotEmpty)
                      const SizedBox(height: 16),
                    TextFormField(
                      controller: _diagnosisController,
                      decoration: const InputDecoration(
                        labelText: 'Diagnostico o motivo terapeutico',
                        hintText: 'Recomendado para trazabilidad clinica',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_information),
                      ),
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
                            value: 'draft', child: Text('Borrador')),
                        DropdownMenuItem(
                            value: 'active', child: Text('Activa')),
                        DropdownMenuItem(
                            value: 'on-hold', child: Text('En espera')),
                        DropdownMenuItem(
                            value: 'cancelled', child: Text('Cancelada')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completada')),
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
                    if (widget.medication == null)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _isSaving
                                  ? null
                                  : () => _saveMedication(addAnother: true),
                              icon: const Icon(Icons.playlist_add),
                              label: const Text('Guardar y agregar otro'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _saveMedication(addAnother: false),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                  : const Text(
                                      'Guardar y cerrar',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      )
                    else
                      FilledButton(
                        onPressed: _isSaving
                            ? null
                            : () => _saveMedication(addAnother: false),
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
                            : const Text(
                                'Actualizar Receta',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
