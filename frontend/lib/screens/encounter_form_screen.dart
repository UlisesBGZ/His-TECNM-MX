import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_encounter.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class EncounterFormScreen extends StatefulWidget {
  final FhirEncounter? encounter;

  const EncounterFormScreen({super.key, this.encounter});

  @override
  State<EncounterFormScreen> createState() => _EncounterFormScreenState();
}

class _EncounterFormScreenState extends State<EncounterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  final _reasonController = TextEditingController();

  String _selectedStatus = 'pending';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 30;
  FhirPatient? _selectedPatient;
  List<FhirPatient> _patients = [];
  bool _isLoadingPatients = false;
  bool _isSaving = false;

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'pending', 'label': 'Pendiente'},
    {'value': 'active', 'label': 'Activa'},
    {'value': 'finalized', 'label': 'Finalizada'},
  ];

  final List<int> _durationOptions = const [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.encounter != null) {
      final enc = widget.encounter!;
      _reasonController.text = enc.reason ?? '';
      _selectedStatus = enc.status;
      _selectedDate = enc.start;
      if (enc.start != null) {
        _selectedTime = TimeOfDay.fromDateTime(enc.start!);
      }
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  Future<void> _loadPatients() async {
    setState(() => _isLoadingPatients = true);

    try {
      final patients = await _fhirService.getPatients(count: 100);
      setState(() {
        _patients = patients;
        _isLoadingPatients = false;
      });

      if (widget.encounter?.patientId != null) {
        final patientId = widget.encounter!.patientId!;
        _selectedPatient = _patients.where((p) => p.id == patientId).isNotEmpty
            ? _patients.firstWhere((p) => p.id == patientId)
            : null;
      }
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar pacientes: $e'),
          backgroundColor: Colors.red,
        ),
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

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime? _getStartDateTime() {
    if (_selectedDate == null || _selectedTime == null) return null;

    return DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
  }

  DateTime? _getEndDateTime() {
    final start = _getStartDateTime();
    if (start == null) return null;
    return start.add(Duration(minutes: _durationMinutes));
  }

  Future<void> _saveEncounter() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar un paciente'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final encounter = FhirEncounter(
        id: widget.encounter?.id,
        status: _selectedStatus,
        reason: _reasonController.text.trim(),
        start: _getStartDateTime(),
        end: _getEndDateTime(),
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
      );

      final savedEncounter = widget.encounter == null
          ? await _fhirService.createEncounter(encounter)
          : await _fhirService.updateEncounter(encounter);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.encounter == null
                ? 'Encuentro creado exitosamente'
                : 'Encuentro actualizado exitosamente',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, savedEncounter);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.encounter == null ? 'Nuevo Encuentro' : 'Editar Encuentro',
        ),
      ),
      body: _isLoadingPatients
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
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
                    onChanged: (value) =>
                        setState(() => _selectedPatient = value),
                    validator: (value) =>
                        value == null ? 'Seleccione paciente' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Motivo del encuentro',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Seleccionar fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Hora *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Seleccionar hora',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: _durationMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Duración',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: _durationOptions
                        .map((minutes) => DropdownMenuItem(
                              value: minutes,
                              child: Text('$minutes min'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _durationMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.flag),
                    ),
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                              value: status['value'],
                              child: Text(status['label']!),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveEncounter,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isSaving
                          ? 'Guardando...'
                          : (widget.encounter == null
                              ? 'Crear Encuentro'
                              : 'Actualizar Encuentro'),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
