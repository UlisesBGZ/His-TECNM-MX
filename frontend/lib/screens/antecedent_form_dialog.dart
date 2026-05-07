import 'package:flutter/material.dart';
import '../models/fhir_antecedent.dart';
import '../services/fhir_service.dart';

class AntecedentFormDialog extends StatefulWidget {
  final String patientId;
  final AntecedentType type;
  final FhirAntecedent? initialAntecedent;
  final Future<void> Function(FhirAntecedent savedAntecedent)? onSaved;

  const AntecedentFormDialog({
    super.key,
    required this.patientId,
    required this.type,
    this.initialAntecedent,
    this.onSaved,
  });

  @override
  State<AntecedentFormDialog> createState() => _AntecedentFormDialogState();

  static Future<FhirAntecedent?> show({
    required BuildContext context,
    required String patientId,
    required AntecedentType type,
    FhirAntecedent? initialAntecedent,
    Future<void> Function(FhirAntecedent savedAntecedent)? onSaved,
  }) {
    return showDialog<FhirAntecedent?>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AntecedentFormDialog(
        patientId: patientId,
        type: type,
        initialAntecedent: initialAntecedent,
        onSaved: onSaved,
      ),
    );
  }
}

class _AntecedentFormDialogState extends State<AntecedentFormDialog> {
  final FhirService _fhirService = FhirService();
  final TextEditingController _contentController = TextEditingController();
  bool _isSaving = false;
  String? _error;

  static const _primary = Color(0xFF3B5BDB);

  @override
  void initState() {
    super.initState();
    if (widget.initialAntecedent != null) {
      _contentController.text = widget.initialAntecedent!.content;
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveAntecedent() async {
    if (_contentController.text.isEmpty) {
      setState(() => _error = 'El contenido no puede estar vacío');
      return;
    }

    setState(() { _isSaving = true; _error = null; });

    try {
      final antecedent = FhirAntecedent(
        id: widget.initialAntecedent?.id,
        patientId: widget.patientId,
        type: widget.type,
        content: _contentController.text.trim(),
        createdAt: widget.initialAntecedent?.createdAt ?? DateTime.now(),
      );

      final saved = await _fhirService.createOrUpdateAntecedent(antecedent);
      await widget.onSaved?.call(saved);

      if (mounted) Navigator.pop(context, saved);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialAntecedent != null;
    final typeIcon = _iconForType(widget.type);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon, color: _primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Editar antecedente' : 'Nuevo antecedente',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          widget.type.displayName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 20),

              // Label
              const Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),

              // TextField
              TextField(
                controller: _contentController,
                maxLines: 6,
                minLines: 4,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  hintText:
                      'Ingresa el detalle de ${widget.type.displayName.toLowerCase()}...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFFCBD5E1)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _primary, width: 1.5),
                  ),
                ),
              ),

              // Error
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 15, color: Color(0xFFEF4444)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFFDC2626)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isSaving ? null : _saveAntecedent,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white),
                          )
                        : Text(isEditing ? 'Actualizar' : 'Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
}

/// Widget para actualización rápida de antecedentes durante captura de encuentro
class QuickAntecedentUpdateButton extends StatelessWidget {
  final String patientId;
  final Future<void> Function(FhirAntecedent savedAntecedent)?
      onAntecedentSaved;

  const QuickAntecedentUpdateButton({
    super.key,
    required this.patientId,
    this.onAntecedentSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Actualizar antecedentes',
      child: IconButton(
        icon: const Icon(Icons.history),
        color: Colors.blue,
        onPressed: () => _showAntecedentSelection(context),
      ),
    );
  }

  void _showAntecedentSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Actualizar antecedente',
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
              ...AntecedentType.values.map((type) => ListTile(
                    leading: const Icon(Icons.edit_outlined,
                        color: Color(0xFF3B5BDB)),
                    title: Text(type.displayName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E293B))),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF94A3B8)),
                    onTap: () {
                      Navigator.pop(context);
                      _showAntecedentDialog(context, type);
                    },
                  )),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAntecedentDialog(
      BuildContext context, AntecedentType type) async {
    final fhirService = FhirService();
    try {
      final existing =
          await fhirService.getLatestAntecedentByType(patientId, type);
      if (context.mounted) {
        await AntecedentFormDialog.show(
          context: context,
          patientId: patientId,
          type: type,
          initialAntecedent: existing,
          onSaved: onAntecedentSaved,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}
