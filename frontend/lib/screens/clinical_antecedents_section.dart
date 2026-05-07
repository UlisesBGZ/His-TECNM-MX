import 'package:flutter/material.dart';
import '../models/fhir_antecedent.dart';
import '../services/fhir_service.dart';

class ClinicalAntecedentsSection extends StatefulWidget {
  final String patientId;
  final String? patientGender;
  final VoidCallback? onAntecedentUpdated;
  final Function(AntecedentType)? onAddAntecedent;

  const ClinicalAntecedentsSection({
    super.key,
    required this.patientId,
    this.patientGender,
    this.onAntecedentUpdated,
    this.onAddAntecedent,
  });

  @override
  State<ClinicalAntecedentsSection> createState() =>
      ClinicalAntecedentsSectionState();
}

class ClinicalAntecedentsSectionState
    extends State<ClinicalAntecedentsSection> {
  final FhirService _fhirService = FhirService();
  Map<AntecedentType, FhirAntecedent?> _antecedents = {
    AntecedentType.heredofamiliar: null,
    AntecedentType.noPatologico: null,
    AntecedentType.ginecoObstetrico: null,
  };
  bool _isLoading = true;
  String? _error;

  List<AntecedentType> get _visibleTypes => AntecedentType.values;

  @override
  void initState() {
    super.initState();
    _loadAntecedents();
  }

  Future<void> refresh() async => _refreshAntecedents();

  void applySavedAntecedent(FhirAntecedent antecedent) {
    setState(() {
      _antecedents[antecedent.type] = antecedent;
      _isLoading = false;
      _error = null;
    });
    widget.onAntecedentUpdated?.call();
  }

  Future<void> _loadAntecedents() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final Map<AntecedentType, FhirAntecedent?> data = {
        AntecedentType.heredofamiliar: null,
        AntecedentType.noPatologico: null,
        AntecedentType.ginecoObstetrico: null,
      };
      for (final type in AntecedentType.values) {
        data[type] = await _fhirService.getLatestAntecedentByType(
            widget.patientId, type);
      }
      setState(() { _antecedents = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAntecedents() async {
    await _loadAntecedents();
    widget.onAntecedentUpdated?.call();
  }

  void _showAntecedentDialog(AntecedentType type) =>
      widget.onAddAntecedent?.call(type);

  // ── Color per type ────────────────────────────────────────────────────────

  Color _colorForType(AntecedentType type) {
    switch (type) {
      case AntecedentType.heredofamiliar:
        return const Color(0xFF3B5BDB);
      case AntecedentType.noPatologico:
        return const Color(0xFF10B981);
      case AntecedentType.ginecoObstetrico:
        return const Color(0xFFEC4899);
    }
  }

  IconData _iconForType(AntecedentType type) {
    switch (type) {
      case AntecedentType.heredofamiliar:
        return Icons.family_restroom_outlined;
      case AntecedentType.noPatologico:
        return Icons.health_and_safety_outlined;
      case AntecedentType.ginecoObstetrico:
        return Icons.pregnant_woman_outlined;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Antecedentes clínicos',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: _showAntecedentOptions,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Agregar'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B5BDB),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: Color(0xFFF1F5F9)),

        // Body
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.error_outline, color: Colors.red[300], size: 32),
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFFEF4444))),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _refreshAntecedents,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          )
        else
          _buildAntecedentList(),
      ],
    );
  }

  Widget _buildAntecedentList() {
    final existing =
        _visibleTypes.where((t) => _antecedents[t] != null).toList();

    if (existing.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.inbox_outlined, size: 20, color: Colors.grey[300]),
            const SizedBox(width: 10),
            Text(
              'No hay antecedentes registrados',
              style: TextStyle(fontSize: 13, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: existing.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
      itemBuilder: (_, i) =>
          _buildAntecedentTile(existing[i], _antecedents[existing[i]]),
    );
  }

  Widget _buildAntecedentTile(AntecedentType type, FhirAntecedent? antecedent) {
    final color = _colorForType(type);
    final icon = _iconForType(type);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color dot + icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (antecedent != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Actual',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                  ],
                ),
                if (antecedent != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    antecedent.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Actualizado: ${_formatDate(antecedent.updatedAt ?? antecedent.createdAt)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ] else
                  const Text(
                    'Sin registro',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFCBD5E1),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          // Edit / Add button
          const SizedBox(width: 8),
          _EditBtn(
            label: antecedent != null ? 'Editar' : 'Agregar',
            color: color,
            onTap: () => _showAntecedentDialog(type),
          ),
        ],
      ),
    );
  }

  void _showAntecedentOptions() {
    final options = _visibleTypes;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Selecciona el tipo de antecedente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ...options.map((type) {
                final existing = _antecedents[type];
                final isDisabled = existing != null;
                final color = _colorForType(type);

                return ListTile(
                  leading: Icon(
                    _iconForType(type),
                    color: isDisabled ? const Color(0xFF10B981) : color,
                  ),
                  title: Text(
                    type.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isDisabled
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: isDisabled
                      ? const Text('Ya registrado',
                          style: TextStyle(fontSize: 12))
                      : null,
                  trailing: isDisabled
                      ? const Icon(Icons.check_circle,
                          color: Color(0xFF10B981), size: 20)
                      : const Icon(Icons.chevron_right,
                          color: Color(0xFF94A3B8)),
                  enabled: !isDisabled,
                  onTap: isDisabled
                      ? null
                      : () {
                          Navigator.pop(dialogCtx);
                          _showAntecedentDialog(type);
                        },
                );
              }),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

// ── Helper widget ─────────────────────────────────────────────────────────────

class _EditBtn extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EditBtn({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_EditBtn> createState() => _EditBtnState();
}

class _EditBtnState extends State<_EditBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.4)
                  : widget.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.label == 'Editar'
                    ? Icons.edit_outlined
                    : Icons.add,
                size: 13,
                color: widget.color,
              ),
              const SizedBox(width: 4),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
