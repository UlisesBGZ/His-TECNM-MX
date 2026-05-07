import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';
import '../providers/auth_provider.dart';
import 'patient_clinical_view_screen.dart';
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
      _loadAllLinkages(patients);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAllLinkages(List<FhirPatient> patients) async {
    for (final patient in patients) {
      if (patient.id == null) continue;
      try {
        final linkage = await _fhirService.verifyPatientLinkage(patient.id!);
        if (linkage['linked'] == true && mounted) {
          final updated = _patientWithLinkage(
            patient,
            linkage['ehrId']?.toString(),
            linkage['linkageNamespace']?.toString(),
          );
          setState(() {
            final index = _patients.indexWhere((p) => p.id == patient.id);
            if (index != -1) _patients[index] = updated;
            _filterPatients();
          });
        }
      } catch (_) {
        // silencioso — si falla un paciente, continúa con los demás
      }
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
            content: Text('Paciente ${patient.fullName} eliminado exitosamente'),
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
      if (patient == null) {
        _patients.add(result);
        print(
            '✅ Nuevo paciente agregado: ${result.fullName} (ID: ${result.id})');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${result.fullName} agregado a la lista'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        final index = _patients.indexWhere((p) => p.id == result.id);
        if (index != -1) {
          _patients[index] = result;
          print(
              '✅ Paciente actualizado: ${result.fullName} (ID: ${result.id})');
        }
      }

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

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdmin = user?.isAdmin ?? false;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Color(0xFF1A1F36)),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isAdmin ? 'Pacientes (Admin)' : 'Mis Pacientes',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
            ),
            Text(
              'Gestión de pacientes',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          _AppBarIconBtn(
            icon: Icons.refresh_outlined,
            tooltip: 'Actualizar',
            color: const Color(0xFF3B5BDB),
            onTap: _loadPatients,
          ),
          if (!isAdmin) ...[
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _AppBarIconBtn(
                icon: Icons.person_add_outlined,
                tooltip: 'Nuevo paciente',
                color: const Color(0xFF10B981),
                onTap: () => _navigateToForm(),
              ),
            ),
          ] else
            const SizedBox(width: 12),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final isTablet = w >= 600;
          final isDesktop = w >= 1024;
          final hPadding = isDesktop ? 48.0 : isTablet ? 28.0 : 16.0;

          return Column(
            children: [
              // ── Search bar ───────────────────────────────────────────
              Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(hPadding, 10, hPadding, 14),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterPatients,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o CURP...',
                        hintStyle:
                            TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey[400], size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close,
                                    color: Colors.grey[400], size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterPatients('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF4F6FB),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: Colors.grey.shade200, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────
              Expanded(
                child: _buildBody(
                  isAdmin: isAdmin,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                  hPadding: hPadding,
                  primary: primary,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: null,
    );
  }

  Widget _buildBody({
    required bool isAdmin,
    required bool isTablet,
    required bool isDesktop,
    required double hPadding,
    required Color primary,
  }) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: primary),
            const SizedBox(height: 16),
            Text(
              'Cargando pacientes...',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline,
                      size: 36, color: Colors.red[400]),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Error al cargar pacientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F36),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loadPatients,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.people_outline,
                  size: 44, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No hay pacientes registrados'
                  : 'Sin resultados para "${_searchController.text}"',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchController.text.isEmpty
                  ? (isAdmin
                      ? 'Los doctores crean sus propios pacientes'
                      : 'Usa el botón superior para agregar el primero')
                  : 'Intenta con otro término de búsqueda',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPatients,
      color: primary,
      child: CustomScrollView(
        slivers: [
          // ── Contador ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, 14, hPadding, 6),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_filteredPatients.length} paciente${_filteredPatients.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      if (_filteredPatients.length != _patients.length) ...[
                        Text(
                          ' de ${_patients.length}',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[400]),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Lista / Grid ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 20),
                  child: isTablet
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredPatients.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isDesktop ? 3 : 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            mainAxisExtent: 168,
                          ),
                          itemBuilder: (context, index) => _buildPatientCard(
                            _filteredPatients[index],
                            isAdmin,
                            isTablet: true,
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0;
                                i < _filteredPatients.length;
                                i++) ...[
                              if (i > 0) const SizedBox(height: 10),
                              _buildPatientCard(
                                _filteredPatients[i],
                                isAdmin,
                                isTablet: false,
                              ),
                            ],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(FhirPatient patient, bool isAdmin,
      {required bool isTablet}) {
    final hasEhr = patient.ehrId != null && patient.ehrId!.trim().isNotEmpty;

    final avatarColor = patient.gender == 'male'
        ? const Color(0xFF3B82F6)
        : patient.gender == 'female'
            ? const Color(0xFFEC4899)
            : const Color(0xFF8B5CF6);

    final avatarIcon = patient.gender == 'male'
        ? Icons.man_outlined
        : patient.gender == 'female'
            ? Icons.woman_outlined
            : Icons.person_outline;

    final initial = patient.fullName.isNotEmpty
        ? patient.fullName[0].toUpperCase()
        : '?';

    return _HoverCardWrapper(
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: avatarColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: avatarColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Nombre + datos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1F36),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          if (patient.age != null)
                            _buildInfoChip(
                                Icons.cake_outlined, '${patient.age} años'),
                          if (patient.bloodType != null &&
                              patient.bloodType!.isNotEmpty)
                            _buildInfoChip(
                                Icons.water_drop_outlined, patient.bloodType!),
                          if (patient.phone != null &&
                              patient.phone!.isNotEmpty)
                            _buildInfoChip(
                                Icons.phone_outlined, patient.phone!),
                        ],
                      ),
                      if (patient.identifier != null &&
                          patient.identifier!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'CURP: ${patient.identifier}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[400]),
                        ),
                      ],
                      if (patient.id != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'FHIR ID: ${patient.id}',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                            ),
                            const SizedBox(width: 4),
                            _CopyEhrBtn(ehrId: patient.id!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Acciones + badge de género
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: avatarColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(avatarIcon, size: 12, color: avatarColor),
                          const SizedBox(width: 3),
                          Text(
                            patient.gender == 'male'
                                ? 'Masculino'
                                : patient.gender == 'female'
                                    ? 'Femenino'
                                    : 'Otro',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: avatarColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isAdmin) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionBtn(
                            icon: Icons.edit_outlined,
                            color: const Color(0xFF10B981),
                            tooltip: 'Editar',
                            onTap: () => _navigateToForm(patient: patient),
                          ),
                          const SizedBox(width: 2),
                          _buildActionBtn(
                            icon: Icons.delete_outline,
                            color: const Color(0xFFEF4444),
                            tooltip: 'Eliminar',
                            onTap: () => _confirmDelete(patient),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // ── EHR section ───────────────────────────────────────────
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F9)),
          if (!hasEhr)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_off,
                            size: 13, color: Colors.deepPurple[400]),
                        const SizedBox(width: 4),
                        Text(
                          'Sin EHR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _buildTextBtn(
                    icon: Icons.refresh,
                    label: 'Verificar',
                    color: Colors.grey.shade600,
                    onTap: () => _refreshPatientLinkage(patient),
                  ),
                  if (!isAdmin) ...[
                    const SizedBox(width: 6),
                    _buildTextBtn(
                      icon: Icons.add,
                      label: 'Agregar EHR',
                      color: const Color(0xFF3B5BDB),
                      onTap: () => _showCreateEhrPending(patient),
                    ),
                  ],
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_outlined,
                        size: 16, color: Color(0xFF10B981)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'EHR: ${patient.ehrId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    _CopyEhrBtn(ehrId: patient.ehrId!),
                    const SizedBox(width: 6),
                    _HoverTextBtn(
                      icon: Icons.folder_open,
                      label: 'Abrir',
                      color: const Color(0xFF10B981),
                      filled: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              PatientClinicalViewScreen(patient: patient),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.grey[400]),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) =>
      _HoverIconBtn(icon: icon, color: color, tooltip: tooltip, onTap: onTap);

  Widget _buildTextBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      _HoverTextBtn(icon: icon, label: label, color: color, onTap: onTap);
}

// ── Hover widgets ─────────────────────────────────────────────────────────────

class _HoverIconBtn extends StatefulWidget {
  const _HoverIconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  State<_HoverIconBtn> createState() => _HoverIconBtnState();
}

class _HoverIconBtnState extends State<_HoverIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _hovered ? 0.18 : 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(widget.icon, size: 16, color: widget.color),
          ),
        ),
      ),
    );
  }
}

class _HoverTextBtn extends StatefulWidget {
  const _HoverTextBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  @override
  State<_HoverTextBtn> createState() => _HoverTextBtnState();
}

class _HoverTextBtnState extends State<_HoverTextBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.filled
        ? (_hovered
            ? widget.color.withValues(alpha: 0.82)
            : widget.color)
        : widget.color.withValues(alpha: _hovered ? 0.15 : 0.08);

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: widget.filled
                ? null
                : Border.all(
                    color: widget.color
                        .withValues(alpha: _hovered ? 0.35 : 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: widget.filled ? 14 : 13,
                color: widget.filled ? Colors.white : widget.color,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.filled ? 12 : 11,
                  fontWeight: FontWeight.w600,
                  color: widget.filled ? Colors.white : widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoverCardWrapper extends StatefulWidget {
  final Widget child;
  const _HoverCardWrapper({required this.child});

  @override
  State<_HoverCardWrapper> createState() => _HoverCardWrapperState();
}

class _HoverCardWrapperState extends State<_HoverCardWrapper> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _hovered ? -4 : 0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        builder: (context, offset, child) {
          return Transform.translate(
            offset: Offset(0, offset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: _hovered ? 0.10 : 0.04),
                    blurRadius: _hovered ? 20 : 8,
                    offset: Offset(0, _hovered ? 8 : 2),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _CopyEhrBtn extends StatefulWidget {
  final String ehrId;
  const _CopyEhrBtn({required this.ehrId});

  @override
  State<_CopyEhrBtn> createState() => _CopyEhrBtnState();
}

class _CopyEhrBtnState extends State<_CopyEhrBtn> {
  bool _hovered = false;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.ehrId));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final color = _copied ? const Color(0xFF10B981) : const Color(0xFF64748B);
    return Tooltip(
      message: _copied ? 'Copiado' : 'Copiar EHR ID',
      child: GestureDetector(
        onTap: _copy,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: _hovered ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              _copied ? Icons.check : Icons.copy_outlined,
              size: 13,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarIconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _AppBarIconBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
