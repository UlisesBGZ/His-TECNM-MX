import 'package:flutter/material.dart';
import '../models/fhir_encounter.dart';
import '../services/fhir_service.dart';
import 'encounter_form_screen.dart';

// ── Spanish month names ────────────────────────────────────────────────────────

const _kMonthNames = [
  '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

const _kMonthNamesShort = [
  '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
  'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
];

// ── Screen ─────────────────────────────────────────────────────────────────────

class EncounterListScreen extends StatefulWidget {
  const EncounterListScreen({super.key});

  @override
  State<EncounterListScreen> createState() => _EncounterListScreenState();
}

class _EncounterListScreenState extends State<EncounterListScreen> {
  final FhirService _fhirService = FhirService();
  final TextEditingController _searchController = TextEditingController();

  List<FhirEncounter> _encounters = [];
  List<FhirEncounter> _filtered = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _filterMonth; // null = all

  static const _primary = Color(0xFF3B5BDB);
  static const _green = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _loadEncounters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Data ────────────────────────────────────────────────────────────────────

  Future<void> _loadEncounters() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _fhirService.getEncounters(count: 200);
      setState(() {
        _encounters = data;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase().trim();

    _filtered = _encounters.where((enc) {
      if (query.isNotEmpty) {
        final name = (enc.patientName ?? '').toLowerCase();
        if (!name.contains(query)) return false;
      }
      if (_filterMonth != null) {
        final s = enc.start;
        if (s == null) return false;
        if (s.year != _filterMonth!.year || s.month != _filterMonth!.month) return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => (b.start ?? DateTime(0)).compareTo(a.start ?? DateTime(0)));
  }

  void _showMonthPicker() {
    showDialog(
      context: context,
      builder: (_) => _MonthYearPickerDialog(
        selected: _filterMonth,
        onSelected: (m) => setState(() { _filterMonth = m; _applyFilter(); }),
      ),
    );
  }

  Future<void> _deleteEncounter(String id) async {
    try {
      await _fhirService.deleteEncounter(id);
      if (!mounted) return;
      setState(() {
        _encounters.removeWhere((enc) => enc.id == id);
        _applyFilter();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Encuentro eliminado'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al eliminar: $e'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  void _showDeleteConfirmation(FhirEncounter encounter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar encuentro',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text(
          '¿Deseas eliminar el encuentro de ${encounter.patientName ?? "este paciente"}?\n\nEsta acción no se puede deshacer.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (encounter.id != null) _deleteEncounter(encounter.id!);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _navigateToForm({FhirEncounter? encounter}) async {
    final result = await Navigator.push<FhirEncounter?>(
      context,
      MaterialPageRoute(builder: (_) => EncounterFormScreen(encounter: encounter)),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (encounter == null) {
        _encounters.add(result);
      } else {
        final i = _encounters.indexWhere((e) => e.id == result.id);
        if (i != -1) _encounters[i] = result;
      }
      _applyFilter();
    });
  }

  String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
            const Text('Encuentros Clínicos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
            Text('Historial de consultas',
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: Color(0xFF475569)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _AppBarBtn(icon: Icons.refresh_rounded, tooltip: 'Actualizar', color: _primary, onTap: _loadEncounters),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _AppBarBtn(icon: Icons.add_rounded, tooltip: 'Nuevo encuentro', color: _green, onTap: () => _navigateToForm()),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── Toolbar ──────────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    final hasMonthFilter = _filterMonth != null;
    final monthLabel = hasMonthFilter
        ? '${_kMonthNames[_filterMonth!.month]} ${_filterMonth!.year}'
        : null;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(_applyFilter),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Buscar por nombre del paciente...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[400]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.close, size: 16, color: Colors.grey[400]),
                      onPressed: () { _searchController.clear(); setState(_applyFilter); },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF4F6FB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade200)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 10),
          // Date filter chips
          Row(
            children: [
              // "Todo" chip
              GestureDetector(
                onTap: () => setState(() { _filterMonth = null; _applyFilter(); }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: !hasMonthFilter ? _primary : const Color(0xFFF4F6FB),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: !hasMonthFilter ? _primary : const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 12,
                          color: !hasMonthFilter ? Colors.white : const Color(0xFF64748B)),
                      const SizedBox(width: 5),
                      Text('Todo',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: !hasMonthFilter ? Colors.white : const Color(0xFF64748B))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Month filter chip / picker button
              if (hasMonthFilter) ...[
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _primary),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.date_range_outlined, size: 12, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(monthLabel!,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => setState(() { _filterMonth = null; _applyFilter(); }),
                          child: const Icon(Icons.close_rounded, size: 13, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.date_range_outlined, size: 12, color: Color(0xFF64748B)),
                        SizedBox(width: 5),
                        Text('Por mes / año',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary, strokeWidth: 2.5));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE4E4)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
                  child: const Icon(Icons.error_outline_rounded, size: 32, color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 14),
                const Text('Error al cargar encuentros',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
                const SizedBox(height: 6),
                Text(_error!, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loadEncounters,
                  style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
              child: Icon(Icons.event_busy_rounded, size: 40, color: Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              _filterMonth == null && _searchController.text.isEmpty
                  ? 'Sin encuentros registrados'
                  : 'Sin resultados para este filtro',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36)),
            ),
            const SizedBox(height: 6),
            const Text('Presiona + para crear un nuevo encuentro',
                style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEncounters,
      color: _primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: Row(
                children: [
                  Container(width: 4, height: 16,
                      decoration: BoxDecoration(color: _primary, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(
                    '${_filtered.length} encuentro${_filtered.length == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF4A5568)),
                  ),
                  if (_filtered.length != _encounters.length)
                    Text(' de ${_encounters.length}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EncounterCard(
                    encounter: _filtered[index],
                    initials: _initials(_filtered[index].patientName),
                    onEdit: () => _navigateToForm(encounter: _filtered[index]),
                    onDelete: () => _showDeleteConfirmation(_filtered[index]),
                  ),
                ),
                childCount: _filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Month / year picker dialog ─────────────────────────────────────────────────

class _MonthYearPickerDialog extends StatefulWidget {
  final DateTime? selected;
  final ValueChanged<DateTime?> onSelected;

  const _MonthYearPickerDialog({this.selected, required this.onSelected});

  @override
  State<_MonthYearPickerDialog> createState() => _MonthYearPickerDialogState();
}

class _MonthYearPickerDialogState extends State<_MonthYearPickerDialog> {
  static const _primary = Color(0xFF3B5BDB);
  static const _minYear = 2020;

  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.selected?.year ?? DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final maxYear = now.year;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Seleccionar mes y año',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1F36))),
              ),
              const SizedBox(height: 16),

              // Year navigation
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _year > _minYear
                          ? () => setState(() => _year--)
                          : null,
                      icon: Icon(Icons.chevron_left_rounded,
                          color: _year > _minYear
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                      splashRadius: 18,
                    ),
                    Text('$_year',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1F36))),
                    IconButton(
                      onPressed: _year < maxYear
                          ? () => setState(() => _year++)
                          : null,
                      icon: Icon(Icons.chevron_right_rounded,
                          color: _year < maxYear
                              ? const Color(0xFF475569)
                              : const Color(0xFFCBD5E1)),
                      splashRadius: 18,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Month grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (_, i) {
                  final month = i + 1;
                  final isFuture = _year == now.year && month > now.month;
                  final isSelected = widget.selected != null &&
                      widget.selected!.year == _year &&
                      widget.selected!.month == month;
                  final isCurrent = _year == now.year && month == now.month;

                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () {
                            widget.onSelected(DateTime(_year, month));
                            Navigator.pop(context);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 130),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _primary
                            : isCurrent
                                ? _primary.withValues(alpha: 0.08)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? _primary
                              : isCurrent
                                  ? _primary.withValues(alpha: 0.35)
                                  : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _kMonthNamesShort[month],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected || isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : isFuture
                                    ? const Color(0xFFCBD5E1)
                                    : isCurrent
                                        ? _primary
                                        : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE9EDF5)),
              const SizedBox(height: 4),

              // Clear / Cancel row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      widget.onSelected(null);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all_rounded, size: 15),
                    label: const Text('Ver todo'),
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF94A3B8)),
                    child: const Text('Cancelar',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Encounter card ─────────────────────────────────────────────────────────────

class _EncounterCard extends StatefulWidget {
  final FhirEncounter encounter;
  final String initials;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EncounterCard({
    required this.encounter,
    required this.initials,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_EncounterCard> createState() => _EncounterCardState();
}

class _EncounterCardState extends State<_EncounterCard> {
  bool _hovered = false;

  static const _primary = Color(0xFF3B5BDB);

  Color get _accentColor {
    switch (widget.encounter.status) {
      case 'active':    return _primary;
      case 'pending':   return const Color(0xFFF59E0B);
      case 'finalized': return const Color(0xFF10B981);
      default:          return const Color(0xFF94A3B8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enc = widget.encounter;
    final accent = _accentColor;
    final hasVitals = enc.vitals != null;
    final hasMotivo = enc.motivoConsulta != null && enc.motivoConsulta!.isNotEmpty;
    final hasDiag = enc.diagnostico != null && enc.diagnostico!.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: _hovered ? -3 : 0),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        builder: (_, offset, child) =>
            Transform.translate(offset: Offset(0, offset), child: child),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9EDF5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.03),
                blurRadius: _hovered ? 20 : 6,
                offset: Offset(0, _hovered ? 6 : 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: Text(widget.initials,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: accent)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    enc.patientName ?? 'Sin paciente asignado',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1F36),
                                        height: 1.2),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time_rounded,
                                          size: 12, color: Color(0xFF94A3B8)),
                                      const SizedBox(width: 4),
                                      Text(enc.dateTimeDisplay,
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF94A3B8))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded,
                                  size: 18, color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onSelected: (v) {
                                if (v == 'edit') widget.onEdit();
                                if (v == 'delete') widget.onDelete();
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit',
                                    child: Row(children: [
                                      Icon(Icons.edit_rounded,
                                          size: 16, color: Color(0xFF475569)),
                                      SizedBox(width: 10),
                                      Text('Editar',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF1A1F36))),
                                    ])),
                                PopupMenuItem(
                                    value: 'delete',
                                    child: Row(children: [
                                      Icon(Icons.delete_outline_rounded,
                                          size: 16, color: Color(0xFFEF4444)),
                                      SizedBox(width: 10),
                                      Text('Eliminar',
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFFEF4444))),
                                    ])),
                              ],
                            ),
                          ],
                        ),

                        // Motivo + Diagnóstico
                        if (hasMotivo || hasDiag) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE9EDF5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasMotivo)
                                  _ClinicalRow(
                                    icon: Icons.help_outline_rounded,
                                    color: const Color(0xFF3B5BDB),
                                    label: 'Motivo de consulta',
                                    value: enc.motivoConsulta!,
                                  ),
                                if (hasMotivo && hasDiag)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 7),
                                    child: Divider(
                                        height: 1, color: Color(0xFFE9EDF5)),
                                  ),
                                if (hasDiag)
                                  _ClinicalRow(
                                    icon: Icons.local_hospital_outlined,
                                    color: const Color(0xFF10B981),
                                    label: 'Diagnóstico',
                                    value: enc.diagnostico!,
                                  ),
                              ],
                            ),
                          ),
                        ],

                        // Vital signs
                        if (hasVitals) ...[
                          const SizedBox(height: 10),
                          _VitalSignsRow(vitals: enc.vitals!),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Clinical row ───────────────────────────────────────────────────────────────

class _ClinicalRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _ClinicalRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
              const SizedBox(height: 2),
              Text(value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Vital signs row ────────────────────────────────────────────────────────────

class _VitalSignsRow extends StatelessWidget {
  final VitalsData vitals;

  const _VitalSignsRow({required this.vitals});

  @override
  Widget build(BuildContext context) {
    final chips = <_VitalData>[];

    if (vitals.systolic != null && vitals.diastolic != null) {
      chips.add(_VitalData(icon: Icons.favorite_border_rounded, label: 'TA',
          value: '${vitals.systolic!.toInt()}/${vitals.diastolic!.toInt()}',
          unit: 'mmHg', color: const Color(0xFFEF4444)));
    }
    if (vitals.heartRate != null) {
      chips.add(_VitalData(icon: Icons.monitor_heart_outlined, label: 'FC',
          value: vitals.heartRate!.toInt().toString(), unit: 'lpm', color: const Color(0xFFEC4899)));
    }
    if (vitals.respiratoryRate != null) {
      chips.add(_VitalData(icon: Icons.air_outlined, label: 'FR',
          value: vitals.respiratoryRate!.toInt().toString(), unit: 'rpm', color: const Color(0xFF0EA5E9)));
    }
    if (vitals.temperature != null) {
      chips.add(_VitalData(icon: Icons.thermostat_outlined, label: 'Temp',
          value: vitals.temperature!.toStringAsFixed(1), unit: '°C', color: const Color(0xFFF59E0B)));
    }
    if (vitals.weight != null) {
      chips.add(_VitalData(icon: Icons.scale_outlined, label: 'Peso',
          value: vitals.weight!.toStringAsFixed(1), unit: 'kg', color: const Color(0xFF8B5CF6)));
    }
    if (vitals.height != null) {
      chips.add(_VitalData(icon: Icons.height_outlined, label: 'Talla',
          value: vitals.height!.toStringAsFixed(0), unit: 'cm', color: const Color(0xFF6366F1)));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.monitor_outlined, size: 11, color: Colors.grey[400]),
            const SizedBox(width: 4),
            Text('SIGNOS VITALES',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[400], letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 6, children: chips.map((c) => _VitalChip(data: c)).toList()),
      ],
    );
  }
}

class _VitalData {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _VitalData({
    required this.icon, required this.label,
    required this.value, required this.unit, required this.color,
  });
}

class _VitalChip extends StatelessWidget {
  final _VitalData data;
  const _VitalChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: data.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 13, color: data.color),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.label,
                  style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w700,
                      color: data.color.withValues(alpha: 0.8), letterSpacing: 0.3)),
              Text('${data.value} ${data.unit}',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: data.color)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── AppBar button ──────────────────────────────────────────────────────────────

class _AppBarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _AppBarBtn({
    required this.icon, required this.tooltip,
    required this.color, required this.onTap,
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
