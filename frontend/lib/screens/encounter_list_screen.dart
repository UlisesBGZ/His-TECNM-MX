import 'package:flutter/material.dart';
import '../models/fhir_encounter.dart';
import '../services/fhir_service.dart';
import 'encounter_form_screen.dart';

class EncounterListScreen extends StatefulWidget {
  const EncounterListScreen({super.key});

  @override
  State<EncounterListScreen> createState() => _EncounterListScreenState();
}

class _EncounterListScreenState extends State<EncounterListScreen> {
  final FhirService _fhirService = FhirService();
  List<FhirEncounter> _encounters = [];
  List<FhirEncounter> _filteredEncounters = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';

  final List<Map<String, String>> _statusOptions = const [
    {'value': 'all', 'label': 'Todos'},
    {'value': 'pending', 'label': 'Pendientes'},
    {'value': 'active', 'label': 'Activas'},
    {'value': 'finalized', 'label': 'Finalizadas'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEncounters();
  }

  Future<void> _loadEncounters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final encounters = await _fhirService.getEncounters(count: 100);
      setState(() {
        _encounters = encounters;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedStatus == 'all') {
      _filteredEncounters = List.from(_encounters);
      return;
    }

    _filteredEncounters =
        _encounters.where((enc) => enc.status == _selectedStatus).toList();
  }

  void _onStatusChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedStatus = value;
      _applyFilter();
    });
  }

  Future<void> _deleteEncounter(String id) async {
    try {
      await _fhirService.deleteEncounter(id);
      if (!mounted) return;
      setState(() {
        _encounters.removeWhere((enc) => enc.id == id);
        _applyFilter();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encuentro eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(FhirEncounter encounter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar este encuentro?\n\n'
          'Paciente: ${encounter.patientName ?? "Sin nombre"}\n'
          'Fecha: ${encounter.dateTimeDisplay}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              if (encounter.id != null) {
                _deleteEncounter(encounter.id!);
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm({FhirEncounter? encounter}) async {
    final result = await Navigator.push<FhirEncounter?>(
      context,
      MaterialPageRoute(
        builder: (context) => EncounterFormScreen(encounter: encounter),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      if (encounter == null) {
        _encounters.add(result);
      } else {
        final index = _encounters.indexWhere((enc) => enc.id == result.id);
        if (index != -1) {
          _encounters[index] = result;
        }
      }
      _applyFilter();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade200;
      case 'active':
        return Colors.blue.shade200;
      case 'finalized':
        return Colors.green.shade200;
      default:
        return Colors.grey.shade200;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'active':
        return Icons.play_circle;
      case 'finalized':
        return Icons.check_circle;
      default:
        return Icons.medical_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuentros Clínicos'),
        actions: [
          IconButton(
            onPressed: _loadEncounters,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _statusOptions
                        .map((status) => DropdownMenuItem(
                              value: status['value'],
                              child: Text(status['label']!),
                            ))
                        .toList(),
                    onChanged: _onStatusChanged,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Encuentro'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error al cargar encuentros',
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
              onPressed: _loadEncounters,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredEncounters.isEmpty) {
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
                  ? 'No hay encuentros registrados'
                  : 'No hay encuentros con este estado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Presiona + para crear un nuevo encuentro',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEncounters,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredEncounters.length,
        itemBuilder: (context, index) {
          final encounter = _filteredEncounters[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(encounter.status),
                child: Icon(
                  _getStatusIcon(encounter.status),
                  color: Colors.black87,
                ),
              ),
              title: Text(
                encounter.patientName ?? 'Sin paciente asignado',
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
                      Text(encounter.dateTimeDisplay),
                    ],
                  ),
                  if (encounter.reason != null && encounter.reason!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(encounter.reason!),
                    ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(encounter.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      encounter.statusDisplay,
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
                    _navigateToForm(encounter: encounter);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(encounter);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
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
