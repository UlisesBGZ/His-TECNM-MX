import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fhir_diagnostic_report.dart';
import '../services/fhir_service.dart';
import '../providers/auth_provider.dart';
import 'report_form_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  final FhirService _fhirService = FhirService();
  List<FhirDiagnosticReport> _reports = [];
  List<FhirDiagnosticReport> _filteredReports = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reports = await _fhirService.getDiagnosticReports();
      setState(() {
        _reports = reports;
        _filterReports();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _filterReports() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      // Filtrar por categoría
      List<FhirDiagnosticReport> categoryFiltered = _selectedCategory == 'all'
          ? _reports
          : _reports.where((r) => r.category == _selectedCategory).toList();

      // Filtrar por status
      List<FhirDiagnosticReport> statusFiltered = _selectedStatus == 'all'
          ? categoryFiltered
          : categoryFiltered.where((r) => r.status == _selectedStatus).toList();

      // Filtrar por búsqueda
      if (query.isEmpty) {
        _filteredReports = statusFiltered;
      } else {
        _filteredReports = statusFiltered.where((report) {
          return report.code.toLowerCase().contains(query) ||
              (report.patientName?.toLowerCase().contains(query) ?? false) ||
              (report.conclusion?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _deleteReport(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este reporte?'),
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
        await _fhirService.deleteDiagnosticReport(id);
        if (mounted) {
          setState(() {
            _reports.removeWhere((r) => r.id == id);
            _filterReports();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte eliminado exitosamente'),
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
  }

  void _navigateToForm({FhirDiagnosticReport? report}) async {
    final result = await Navigator.push<FhirDiagnosticReport?>(
      context,
      MaterialPageRoute(
        builder: (context) => ReportFormScreen(report: report),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (report == null) {
          // Nuevo reporte: agregar a la lista
          _reports.add(result);
        } else {
          // Reporte editado: actualizar en la lista
          final index = _reports.indexWhere((r) => r.id == result.id);
          if (index != -1) {
            _reports[index] = result;
          }
        }
        _filterReports();
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'final':
        return Colors.green;
      case 'preliminary':
        return Colors.blue;
      case 'registered':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'amended':
      case 'corrected':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'final':
        return Icons.check_circle;
      case 'preliminary':
        return Icons.pending;
      case 'registered':
        return Icons.assignment;
      case 'cancelled':
        return Icons.cancel;
      case 'amended':
      case 'corrected':
        return Icons.edit;
      default:
        return Icons.description;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'LAB':
        return Icons.science;
      case 'RAD':
        return Icons.medical_services;
      case 'PATH':
        return Icons.biotech;
      case 'MB':
        return Icons.coronavirus;
      case 'GE':
        return Icons.gradient;
      default:
        return Icons.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Reportes (Vista Admin)' : 'Mis Reportes'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Barra de búsqueda y filtros
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Barra de búsqueda
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por tipo, paciente o conclusión...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (value) => _filterReports(),
                ),
                const SizedBox(height: 12),
                // Filtros
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todas')),
                          DropdownMenuItem(
                              value: 'LAB', child: Text('Laboratorio')),
                          DropdownMenuItem(
                              value: 'RAD', child: Text('Radiología')),
                          DropdownMenuItem(
                              value: 'PATH', child: Text('Patología')),
                          DropdownMenuItem(
                              value: 'MB', child: Text('Microbiología')),
                          DropdownMenuItem(
                              value: 'GE', child: Text('Genética')),
                          DropdownMenuItem(value: 'OTH', child: Text('Otro')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? 'all';
                            _filterReports();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Estado',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('Todos')),
                          DropdownMenuItem(
                              value: 'registered', child: Text('Registrado')),
                          DropdownMenuItem(
                              value: 'preliminary', child: Text('Preliminar')),
                          DropdownMenuItem(
                              value: 'final', child: Text('Final')),
                          DropdownMenuItem(
                              value: 'amended', child: Text('Modificado')),
                          DropdownMenuItem(
                              value: 'cancelled', child: Text('Cancelado')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value ?? 'all';
                            _filterReports();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de reportes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 64, color: Colors.red[300]),
                            const SizedBox(height: 16),
                            Text(
                              'Error al cargar reportes',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _loadReports,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _filteredReports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isAdmin
                                      ? Icons.description_outlined
                                      : Icons.add_circle_outline,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isAdmin
                                      ? 'No hay reportes registrados'
                                      : 'No tienes reportes',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (!isAdmin) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Crea tu primer reporte médico',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReports,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredReports.length,
                              itemBuilder: (context, index) {
                                final report = _filteredReports[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          _getStatusColor(report.status)
                                              .withOpacity(0.2),
                                      child: Icon(
                                        _getCategoryIcon(report.category),
                                        color: _getStatusColor(report.status),
                                      ),
                                    ),
                                    title: Text(
                                      report.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        if (report.patientName != null)
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              Text(report.patientName!),
                                            ],
                                          ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Chip(
                                              label: Text(report.statusDisplay),
                                              backgroundColor:
                                                  _getStatusColor(report.status)
                                                      .withOpacity(0.2),
                                              labelStyle: TextStyle(
                                                color: _getStatusColor(
                                                    report.status),
                                                fontSize: 12,
                                              ),
                                              padding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            if (report.category != null) ...[
                                              const SizedBox(width: 8),
                                              Chip(
                                                label: Text(
                                                    report.categoryDisplay),
                                                backgroundColor: Colors.grey
                                                    .withOpacity(0.2),
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                                padding: EdgeInsets.zero,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (report.dateDisplay != null) ...[
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today,
                                                  size: 16),
                                              const SizedBox(width: 4),
                                              Text(report.dateDisplay!),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                    trailing: isAdmin
                                        ? null
                                        : PopupMenuButton<String>(
                                            onSelected: (value) async {
                                              if (value == 'edit') {
                                                _navigateToForm(report: report);
                                              } else if (value == 'delete') {
                                                await _deleteReport(report.id!);
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
                                                    Icon(Icons.delete,
                                                        size: 20,
                                                        color: Colors.red),
                                                    SizedBox(width: 8),
                                                    Text('Eliminar',
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                    onTap: isAdmin
                                        ? null
                                        : () => _navigateToForm(report: report),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? null
          : FloatingActionButton(
              onPressed: () => _navigateToForm(),
              child: const Icon(Icons.add),
            ),
    );
  }
}
