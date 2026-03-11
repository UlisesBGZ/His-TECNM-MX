import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';
import '../providers/auth_provider.dart';
import 'patient_form_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final FhirService _fhirService = FhirService();
  List<FhirPatient> _patients = [];
  List<FhirPatient> _filteredPatients = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final patients = await _fhirService.getPatients();
      print(
          '📋 PatientListScreen: Recibidos ${patients.length} pacientes del servicio');
      for (var i = 0; i < patients.length; i++) {
        print('   [$i] ${patients[i].fullName} (ID: ${patients[i].id})');
      }
      setState(() {
        _patients = patients;
        _filteredPatients = patients;
        _isLoading = false;
      });
      print(
          '✅ PatientListScreen: Estado actualizado con ${_patients.length} pacientes');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterPatients([String? query]) {
    final searchQuery = query ?? _searchController.text;

    setState(() {
      if (searchQuery.isEmpty) {
        _filteredPatients = List.from(_patients);
      } else {
        _filteredPatients = _patients.where((patient) {
          final fullName = patient.fullName.toLowerCase();
          final identifier = patient.identifier?.toLowerCase() ?? '';
          final search = searchQuery.toLowerCase();
          return fullName.contains(search) || identifier.contains(search);
        }).toList();
      }
    });
  }

  Future<void> _confirmDelete(FhirPatient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que deseas eliminar al paciente "${patient.fullName}"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deletePatient(patient);
    }
  }

  Future<void> _deletePatient(FhirPatient patient) async {
    try {
      await _fhirService.deletePatient(patient.id!);

      if (mounted) {
        setState(() {
          _patients.removeWhere((p) => p.id == patient.id);
          _filterPatients();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Paciente ${patient.fullName} eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToForm({FhirPatient? patient}) async {
    final result = await Navigator.of(context).push<FhirPatient?>(
      MaterialPageRoute(
        builder: (_) => PatientFormScreen(patient: patient),
      ),
    );

    if (result != null && mounted) {
      // Actualizar la lista de pacientes
      if (patient == null) {
        // Nuevo paciente: agregar a la lista
        _patients.add(result);
        print(
            '✅ Nuevo paciente agregado: ${result.fullName} (ID: ${result.id})');

        // Mostrar notificación de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${result.fullName} agregado a la lista'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Paciente editado: actualizar en la lista
        final index = _patients.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _patients[index] = result;
          print(
              '✅ Paciente actualizado: ${result.fullName} (ID: ${result.id})');
        }
      }

      // Actualizar lista filtrada
      _filterPatients();

      print(
          '📋 Lista actualizada: ${_patients.length} pacientes totales, ${_filteredPatients.length} filtrados');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Pacientes (Vista Admin)' : 'Mis Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Actualizar',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPatients,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o cédula...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterPatients('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(isAdmin),
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _navigateToForm(),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Paciente'),
            ),
    );
  }

  Widget _buildBody(bool isAdmin) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando pacientes...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar pacientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadPatients,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No hay pacientes registrados'
                  : 'No se encontraron pacientes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? (isAdmin
                      ? 'Los doctores crean sus propios pacientes'
                      : 'Presiona el botón "+" para agregar el primer paciente')
                  : 'Intenta con otro término de búsqueda',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _filteredPatients.length,
        itemBuilder: (context, index) {
          final patient = _filteredPatients[index];
          return _buildPatientCard(patient, isAdmin);
        },
      ),
    );
  }

  Widget _buildPatientCard(FhirPatient patient, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.gender == 'male'
              ? Colors.blue
              : patient.gender == 'female'
                  ? Colors.pink
                  : Colors.grey,
          child: Icon(
            patient.gender == 'male'
                ? Icons.man
                : patient.gender == 'female'
                    ? Icons.woman
                    : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (patient.identifier != null)
              Text('Cédula: ${patient.identifier}'),
            if (patient.age != null)
              Text('${patient.age} años • ${patient.genderDisplay}'),
            if (patient.phone != null)
              Text('Tel: ${patient.phone}',
                  style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: isAdmin
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToForm(patient: patient);
                  } else if (value == 'delete') {
                    _confirmDelete(patient);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title:
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
        onTap: isAdmin ? null : () => _navigateToForm(patient: patient),
      ),
    );
  }
}
