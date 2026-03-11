import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fhir_medication_request.dart';
import '../models/user.dart';
import '../services/fhir_service.dart';
import '../providers/auth_provider.dart';
import 'medication_form_screen.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen> {
  final FhirService _fhirService = FhirService();
  List<FhirMedicationRequest> _medications = [];
  List<FhirMedicationRequest> _filteredMedications = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar todas las medications sin filtro de status
      final medications = await _fhirService.getMedicationRequests();
      setState(() {
        _medications = medications;
        _filterMedications();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterMedications() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      // Aplicar filtro de status primero
      List<FhirMedicationRequest> statusFiltered = _selectedStatus == 'all'
          ? _medications
          : _medications.where((med) => med.status == _selectedStatus).toList();

      // Luego aplicar filtro de búsqueda
      if (query.isEmpty) {
        _filteredMedications = statusFiltered;
      } else {
        _filteredMedications = statusFiltered.where((med) {
          return med.medication.toLowerCase().contains(query) ||
              (med.patientName?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _deleteMedication(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta receta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _fhirService.deleteMedicationRequest(id);
        if (mounted) {
          setState(() {
            _medications.removeWhere((m) => m.id == id);
            _filterMedications();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receta eliminada exitosamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'stopped':
        return Colors.orange;
      case 'on-hold':
        return Colors.yellow.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'active':
        return Icons.medication;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'stopped':
        return Icons.stop_circle;
      case 'on-hold':
        return Icons.pause_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          user?.isAdmin ?? false
              ? 'Recetas Médicas (Vista Admin)'
              : 'Mis Recetas',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedications,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Buscar recetas',
                    hintText: 'Buscar por medicamento o paciente',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _filterMedications(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por estado',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.filter_list),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Activas')),
                    DropdownMenuItem(
                        value: 'completed', child: Text('Completadas')),
                    DropdownMenuItem(
                        value: 'cancelled', child: Text('Canceladas')),
                    DropdownMenuItem(
                        value: 'stopped', child: Text('Detenidas')),
                    DropdownMenuItem(
                        value: 'on-hold', child: Text('En espera')),
                    DropdownMenuItem(value: 'draft', child: Text('Borradores')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value ?? 'all';
                      _filterMedications();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(user),
          ),
        ],
      ),
      floatingActionButton: (user?.isAdmin ?? false)
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push<FhirMedicationRequest?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicationFormScreen(),
                  ),
                );
                if (result != null && mounted) {
                  setState(() {
                    _medications.add(result);
                    _filterMedications();
                  });
                }
              },
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildBody(User? user) {
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
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMedications,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              user?.isAdmin ?? false
                  ? 'No hay recetas registradas'
                  : _searchController.text.isNotEmpty
                      ? 'No se encontraron recetas'
                      : 'No hay recetas aún',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (!(user?.isAdmin ?? false) && _searchController.text.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Crea tu primera receta médica',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMedications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredMedications.length,
        itemBuilder: (context, index) {
          return _buildMedicationCard(
            _filteredMedications[index],
            user?.isAdmin ?? false,
          );
        },
      ),
    );
  }

  Widget _buildMedicationCard(FhirMedicationRequest medication, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(medication.status),
          child: Icon(
            _getStatusIcon(medication.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          medication.medication,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (medication.patientName != null)
              Text('Paciente: ${medication.patientName}'),
            if (medication.dosageInstruction != null)
              Text('Dosis: ${medication.dosageInstruction}'),
            if (medication.supplyDisplay != null)
              Text('Cantidad: ${medication.supplyDisplay}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(medication.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    medication.statusDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(medication.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (medication.dateDisplay != null)
                  Text(
                    medication.dateDisplay!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: isAdmin
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    final result = await Navigator.push<FhirMedicationRequest?>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationFormScreen(medication: medication),
                      ),
                    );
                    if (result != null && mounted) {
                      setState(() {
                        final index =
                            _medications.indexWhere((m) => m.id == result.id);
                        if (index != -1) {
                          _medications[index] = result;
                        }
                        _filterMedications();
                      });
                    }
                  } else if (value == 'delete') {
                    await _deleteMedication(medication.id!);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Editar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: isAdmin
            ? null
            : () async {
                final result = await Navigator.push<FhirMedicationRequest?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MedicationFormScreen(medication: medication),
                  ),
                );
                if (result != null && mounted) {
                  setState(() {
                    final index =
                        _medications.indexWhere((m) => m.id == result.id);
                    if (index != -1) {
                      _medications[index] = result;
                    }
                    _filterMedications();
                  });
                }
              },
      ),
    );
  }
}
