import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_appointment.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class AppointmentFormScreen extends StatefulWidget {
  final FhirAppointment? appointment;

  const AppointmentFormScreen({super.key, this.appointment});

  @override
  State<AppointmentFormScreen> createState() => _AppointmentFormScreenState();
}

class _AppointmentFormScreenState extends State<AppointmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  // Controllers
  final _descriptionController = TextEditingController();
  final _commentController = TextEditingController();
  final _practitionerNameController = TextEditingController();

  // State
  String _selectedStatus = 'booked';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _durationMinutes = 30;
  FhirPatient? _selectedPatient;
  List<FhirPatient> _patients = [];
  bool _isLoadingPatients = false;
  bool _isSaving = false;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'proposed', 'label': 'Propuesta'},
    {'value': 'pending', 'label': 'Pendiente'},
    {'value': 'booked', 'label': 'Confirmada'},
    {'value': 'arrived', 'label': 'Paciente llegó'},
    {'value': 'fulfilled', 'label': 'Completada'},
    {'value': 'cancelled', 'label': 'Cancelada'},
    {'value': 'noshow', 'label': 'No asistió'},
  ];

  final List<int> _durationOptions = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.appointment != null) {
      final apt = widget.appointment!;
      _descriptionController.text = apt.description ?? '';
      _commentController.text = apt.comment ?? '';
      _practitionerNameController.text = apt.practitionerName ?? '';
      _selectedStatus = apt.status;
      _selectedDate = apt.start;
      if (apt.start != null) {
        _selectedTime = TimeOfDay.fromDateTime(apt.start!);
      }
      _durationMinutes = apt.minutesDuration ?? 30;
    } else {
      // Default values for new appointment
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedTime = const TimeOfDay(hour: 9, minute: 0);
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

      // Si estamos editando, buscar el paciente seleccionado
      if (widget.appointment?.patientId != null) {
        final patientId = widget.appointment!.patientId!;
        _selectedPatient = _patients.firstWhere(
          (p) => p.id == patientId,
          orElse: () => _patients.first,
        );
      }
    } catch (e) {
      setState(() => _isLoadingPatients = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar pacientes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
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

  Future<void> _saveAppointment() async {
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

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar fecha y hora'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final appointment = FhirAppointment(
        id: widget.appointment?.id,
        status: _selectedStatus,
        description: _descriptionController.text.trim(),
        start: _getStartDateTime(),
        end: _getEndDateTime(),
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        practitionerName: _practitionerNameController.text.trim().isNotEmpty
            ? _practitionerNameController.text.trim()
            : null,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
        minutesDuration: _durationMinutes,
      );

      FhirAppointment savedAppointment;

      if (widget.appointment == null) {
        savedAppointment = await _fhirService.createAppointment(appointment);
      } else {
        savedAppointment = await _fhirService.updateAppointment(appointment);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.appointment == null
                  ? 'Cita creada exitosamente'
                  : 'Cita actualizada exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, savedAppointment);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _commentController.dispose();
    _practitionerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appointment == null ? 'Nueva Cita' : 'Editar Cita'),
      ),
      body: _isLoadingPatients
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Paciente
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
                        return 'Debe seleccionar un paciente';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción/Motivo
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de la cita',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),

                  // Fecha
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

                  // Hora
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

                  // Duración
                  DropdownButtonFormField<int>(
                    value: _durationMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Duración',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    items: _durationOptions.map((minutes) {
                      final hours = minutes ~/ 60;
                      final mins = minutes % 60;
                      String label;
                      if (hours > 0 && mins > 0) {
                        label = '$hours h $mins min';
                      } else if (hours > 0) {
                        label = '$hours h';
                      } else {
                        label = '$mins min';
                      }
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _durationMinutes = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Estado
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status['value'],
                        child: Text(status['label']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedStatus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Médico/Practicante
                  TextFormField(
                    controller: _practitionerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Médico/Especialista',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comentarios
                  TextFormField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: 'Notas/Comentarios',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),

                  // Botón guardar
                  FilledButton.icon(
                    onPressed: _isSaving ? null : _saveAppointment,
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
                          : (widget.appointment == null
                              ? 'Crear Cita'
                              : 'Actualizar Cita'),
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
