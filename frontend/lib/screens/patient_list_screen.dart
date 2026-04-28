import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';
import '../providers/auth_provider.dart';
import 'clinical_record_list_screen.dart';
import 'clinical_record_wizard_screen.dart';
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

  FhirPatient _patientWithLinkage(
    FhirPatient patient,
    String? ehrId,
    String? linkageNamespace,
  ) {
    return FhirPatient(
      id: patient.id,
      identifier: patient.identifier,
      firstName: patient.firstName,
      paternalLastName: patient.paternalLastName,
      maternalLastName: patient.maternalLastName,
      gender: patient.gender,
      birthDate: patient.birthDate,
      bloodType: patient.bloodType,
      state: patient.state,
      municipality: patient.municipality,
      postalCode: patient.postalCode,
      streetAndNumber: patient.streetAndNumber,
      colony: patient.colony,
      phone: patient.phone,
      email: patient.email,
      clinicalAntecedents: patient.clinicalAntecedents,
      ehrId: ehrId,
      linkageNamespace: linkageNamespace,
      address: patient.address,
    );
  }

  Future<void> _refreshPatientLinkage(FhirPatient patient) async {
    if (patient.id == null) return;

    try {
      final linkage = await _fhirService.verifyPatientLinkage(patient.id!);
      final bool linked = linkage['linked'] == true;

      if (!mounted) return;

      if (linked) {
        final updated = _patientWithLinkage(
          patient,
          linkage['ehrId']?.toString(),
          linkage['linkageNamespace']?.toString(),
        );

        setState(() {
          final index = _patients.indexWhere((p) => p.id == patient.id);
          if (index != -1) {
            _patients[index] = updated;
          }
          _filterPatients();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Paciente vinculado. EHR ID: ${updated.ehrId}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aun sin EHR asignado para este paciente.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo validar enlace EHR: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showCreateEhrPending(FhirPatient patient) async {
    await _refreshPatientLinkage(patient);

    if (!mounted) return;

    final current = _patients.where((p) => p.id == patient.id).isNotEmpty
        ? _patients.firstWhere((p) => p.id == patient.id)
        : patient;

    if (current.ehrId == null || current.ehrId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este paciente aun no tiene EHR. Primero debe vincularse en backend.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClinicalRecordWizardScreen(patient: current),
      ),
    );
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
                hintText: 'Buscar por nombre o CURP...',
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
    final hasEhr = patient.ehrId != null && patient.ehrId!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
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
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    patient.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (!isAdmin)
                  IconButton(
                    onPressed: () => _navigateToForm(patient: patient),
                    icon: const Icon(Icons.edit, color: Colors.green),
                    tooltip: 'Editar',
                  ),
                if (!isAdmin)
                  IconButton(
                    onPressed: () => _confirmDelete(patient),
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (patient.age != null)
                  Text('${patient.age} años',
                      style: const TextStyle(fontSize: 13)),
                if (patient.phone != null && patient.phone!.isNotEmpty)
                  Text('Tel: ${patient.phone}',
                      style: const TextStyle(fontSize: 13)),
                if (patient.bloodType != null && patient.bloodType!.isNotEmpty)
                  Text(patient.bloodType!, style: const TextStyle(fontSize: 13)),
              ],
            ),
            if (patient.identifier != null && patient.identifier!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'CURP: ${patient.identifier}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            if (patient.address != null && patient.address!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  patient.address!,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            if (!hasEhr)
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Sin EHR asignado',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _refreshPatientLinkage(patient),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Actualizar EHR',
                  ),
                  if (!isAdmin)
                    FilledButton.tonalIcon(
                      onPressed: () => _showCreateEhrPending(patient),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar EHR'),
                    ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified, size: 18, color: Colors.green),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'EHR ID: ${patient.ehrId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Expediente clinico disponible',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ClinicalRecordListScreen(
                                  patient: patient,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Abrir'),
                        ),
                        if (!isAdmin)
                          TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClinicalRecordWizardScreen(
                                    patient: patient,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Agregar'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
