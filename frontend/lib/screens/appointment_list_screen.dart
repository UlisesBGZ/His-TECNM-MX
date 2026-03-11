import 'package:flutter/material.dart';
import '../models/fhir_appointment.dart';
import '../services/fhir_service.dart';
import 'appointment_form_screen.dart';

class AppointmentListScreen extends StatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  State<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends State<AppointmentListScreen> {
  final FhirService _fhirService = FhirService();
  List<FhirAppointment> _appointments = [];
  List<FhirAppointment> _filteredAppointments = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusOptions = [
    {'value': 'all', 'label': 'Todas'},
    {'value': 'proposed', 'label': 'Propuestas'},
    {'value': 'pending', 'label': 'Pendientes'},
    {'value': 'booked', 'label': 'Confirmadas'},
    {'value': 'arrived', 'label': 'Paciente llegó'},
    {'value': 'fulfilled', 'label': 'Completadas'},
    {'value': 'cancelled', 'label': 'Canceladas'},
    {'value': 'noshow', 'label': 'No asistió'},
  ];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appointments = await _fhirService.getAppointments(count: 100);
      setState(() {
        _appointments = appointments;
        _filterAppointments();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterAppointments() {
    if (_selectedStatus == 'all') {
      _filteredAppointments = List.from(_appointments);
    } else {
      _filteredAppointments =
          _appointments.where((apt) => apt.status == _selectedStatus).toList();
    }
  }

  void _onStatusChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedStatus = value;
        _filterAppointments();
      });
    }
  }

  Future<void> _deleteAppointment(String id) async {
    try {
      await _fhirService.deleteAppointment(id);
      if (mounted) {
        setState(() {
          _appointments.removeWhere((a) => a.id == id);
          _filterAppointments();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita eliminada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation(FhirAppointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar esta cita?\n\n'
          'Paciente: ${appointment.patientName ?? "Sin nombre"}\n'
          'Fecha: ${appointment.dateTimeDisplay}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAppointment(appointment.id!);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm({FhirAppointment? appointment}) async {
    final result = await Navigator.push<FhirAppointment?>(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentFormScreen(appointment: appointment),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (appointment == null) {
          // Nueva cita: agregar a la lista
          _appointments.add(result);
        } else {
          // Cita editada: actualizar en la lista
          final index = _appointments.indexWhere((a) => a.id == result.id);
          if (index != -1) {
            _appointments[index] = result;
          }
        }
        _filterAppointments();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'proposed':
        return Colors.blue.shade200;
      case 'pending':
        return Colors.orange.shade200;
      case 'booked':
        return Colors.green.shade200;
      case 'arrived':
        return Colors.teal.shade200;
      case 'fulfilled':
        return Colors.purple.shade200;
      case 'cancelled':
        return Colors.red.shade200;
      case 'noshow':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'proposed':
        return Icons.lightbulb_outline;
      case 'pending':
        return Icons.schedule;
      case 'booked':
        return Icons.event_available;
      case 'arrived':
        return Icons.login;
      case 'fulfilled':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'noshow':
        return Icons.person_off;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citas Médicas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por estado
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 12),
                const Text(
                  'Filtrar por:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: _statusOptions.map((status) {
                      return DropdownMenuItem(
                        value: status['value'],
                        child: Text(status['label']!),
                      );
                    }).toList(),
                    onChanged: _onStatusChanged,
                  ),
                ),
              ],
            ),
          ),

          // Lista de citas
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Cita'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar citas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedStatus == 'all'
                  ? Icons.event_busy
                  : Icons.filter_list_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus == 'all'
                  ? 'No hay citas registradas'
                  : 'No hay citas con este estado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Presiona + para crear una nueva cita',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredAppointments.length,
        itemBuilder: (context, index) {
          final appointment = _filteredAppointments[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(appointment.status),
                child: Icon(
                  _getStatusIcon(appointment.status),
                  color: Colors.black87,
                ),
              ),
              title: Text(
                appointment.patientName ?? 'Sin paciente asignado',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 4),
                      Text(appointment.dateTimeDisplay),
                    ],
                  ),
                  if (appointment.durationDisplay != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.timer, size: 16),
                        const SizedBox(width: 4),
                        Text(appointment.durationDisplay!),
                      ],
                    ),
                  ],
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(appointment.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      appointment.statusDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToForm(appointment: appointment);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(appointment);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
