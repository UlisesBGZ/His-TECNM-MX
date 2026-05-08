import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/fhir_patient.dart';
import '../services/fhir_service.dart';

class PatientFormScreen extends StatefulWidget {
  final FhirPatient? patient;

  const PatientFormScreen({super.key, this.patient});

  @override
  State<PatientFormScreen> createState() => _PatientFormScreenState();
}

class _PatientFormScreenState extends State<PatientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FhirService _fhirService = FhirService();

  late final TextEditingController _identifierController;
  late final TextEditingController _givenNamesController;
  late final TextEditingController _paternalLastNameController;
  late final TextEditingController _maternalLastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _stateController;
  late final TextEditingController _municipalityController;
  late final TextEditingController _postalCodeController;
  late final TextEditingController _streetAndNumberController;
  late final TextEditingController _colonyController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthDate;
  bool _isSaving = false;

  static const List<String> _bloodTypes = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', 'No especificado',
  ];

  @override
  void initState() {
    super.initState();
    _identifierController =
        TextEditingController(text: widget.patient?.identifier ?? '');
    _givenNamesController =
        TextEditingController(text: widget.patient?.firstName ?? '');
    _paternalLastNameController =
        TextEditingController(text: widget.patient?.paternalLastName ?? '');
    _maternalLastNameController =
        TextEditingController(text: widget.patient?.maternalLastName ?? '');
    _phoneController =
        TextEditingController(text: widget.patient?.phone ?? '');
    _emailController =
        TextEditingController(text: widget.patient?.email ?? '');
    _stateController =
        TextEditingController(text: widget.patient?.state ?? '');
    _municipalityController =
        TextEditingController(text: widget.patient?.municipality ?? '');
    _postalCodeController =
        TextEditingController(text: widget.patient?.postalCode ?? '');
    _streetAndNumberController =
        TextEditingController(text: widget.patient?.streetAndNumber ?? '');
    _colonyController =
        TextEditingController(text: widget.patient?.colony ?? '');

    _selectedGender = widget.patient?.gender;
    _selectedBloodType = widget.patient?.bloodType;

    if (widget.patient?.birthDate != null) {
      try {
        _selectedBirthDate = DateTime.parse(widget.patient!.birthDate!);
      } catch (_) {
        _selectedBirthDate = null;
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _givenNamesController.dispose();
    _paternalLastNameController.dispose();
    _maternalLastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _stateController.dispose();
    _municipalityController.dispose();
    _postalCodeController.dispose();
    _streetAndNumberController.dispose();
    _colonyController.dispose();
    super.dispose();
  }

  // ── Logic (unchanged) ────────────────────────────────────────────────────

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccionar fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() => _selectedBirthDate = picked);
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de nacimiento es requerida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final patient = FhirPatient(
        id: widget.patient?.id,
        identifier: _identifierController.text.trim(),
        firstName: _givenNamesController.text.trim(),
        paternalLastName: _paternalLastNameController.text.trim(),
        maternalLastName: _maternalLastNameController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
            : null,
        bloodType: _selectedBloodType == 'No especificado'
            ? null
            : _selectedBloodType,
        state: _stateController.text.trim(),
        municipality: _municipalityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        streetAndNumber: _streetAndNumberController.text.trim(),
        colony: _colonyController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        ehrId: widget.patient?.ehrId,
        linkageNamespace: widget.patient?.linkageNamespace,
      );

      final FhirPatient savedPatient = widget.patient == null
          ? await _fhirService.createPatient(patient)
          : await _fhirService.updatePatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.patient == null
                ? (savedPatient.ehrId != null
                    ? 'Paciente creado y vinculado a EHR ${savedPatient.ehrId}'
                    : 'Paciente creado exitosamente')
                : 'Paciente actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(savedPatient);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _requiredField(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(value.trim())) {
      return 'El teléfono debe tener entre 10 y 15 dígitos';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El código postal es requerido';
    }
    if (!RegExp(r'^[0-9]{5}$').hasMatch(value.trim())) {
      return 'El código postal debe tener 5 dígitos';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validateBloodType(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    const allowed = {'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'};
    if (!allowed.contains(value.trim().toUpperCase())) {
      return 'Tipo de sangre inválido';
    }
    return null;
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;
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
              isEditing ? 'Editar Paciente' : 'Nuevo Paciente',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
            ),
            Text(
              isEditing
                  ? 'Actualiza los datos del paciente'
                  : 'Completa el registro del paciente',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final isTablet = w >= 600;
          final isDesktop = w >= 1024;
          final hPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 16.0;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(horizontal: hPadding, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 780),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Datos Personales ───────────────────────────
                      _buildSectionCard(
                        title: 'Datos Personales',
                        icon: Icons.badge_outlined,
                        color: const Color(0xFF3B82F6),
                        children: [
                          _buildField(
                            controller: _identifierController,
                            label: 'CURP *',
                            hint: 'Ej: ABCD123456HDFRRL09',
                            icon: Icons.perm_identity_outlined,
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La CURP es requerida';
                              }
                              if (!RegExp(r'^[A-Z0-9]{18}$')
                                  .hasMatch(value.trim().toUpperCase())) {
                                return 'La CURP debe tener 18 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _givenNamesController,
                            label: 'Nombre(s) *',
                            icon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) =>
                                _requiredField(v, 'El nombre es requerido'),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _paternalLastNameController,
                                  label: 'Apellido Paterno *',
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) =>
                                      _requiredField(v, 'Requerido'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _maternalLastNameController,
                                  label: 'Apellido Materno *',
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) =>
                                      _requiredField(v, 'Requerido'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildDatePicker(),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, c) {
                              final narrow = c.maxWidth < 420;
                              final sexo = _buildDropdown(
                                label: 'Sexo *',
                                icon: Icons.wc_outlined,
                                value: _selectedGender,
                                items: const [
                                  'male', 'female', 'other', 'unknown'
                                ],
                                validator: (v) =>
                                    _requiredField(v, 'El sexo es requerido'),
                                onChanged: (v) =>
                                    setState(() => _selectedGender = v),
                              );
                              final blood = _buildDropdown(
                                label: 'Tipo de Sangre',
                                icon: Icons.water_drop_outlined,
                                value: _selectedBloodType,
                                items: _bloodTypes,
                                validator: _validateBloodType,
                                onChanged: (v) =>
                                    setState(() => _selectedBloodType = v),
                              );
                              return narrow
                                  ? Column(children: [
                                      sexo,
                                      const SizedBox(height: 14),
                                      blood
                                    ])
                                  : Row(children: [
                                      Expanded(child: sexo),
                                      const SizedBox(width: 12),
                                      Expanded(child: blood),
                                    ]);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Dirección ─────────────────────────────────
                      _buildSectionCard(
                        title: 'Dirección',
                        icon: Icons.location_on_outlined,
                        color: const Color(0xFF10B981),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _stateController,
                                  label: 'Entidad Federativa *',
                                  icon: Icons.map_outlined,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => _requiredField(
                                      v, 'La entidad es requerida'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _municipalityController,
                                  label: 'Municipio *',
                                  icon: Icons.apartment_outlined,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (v) => _requiredField(
                                      v, 'El municipio es requerido'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              SizedBox(
                                width: 140,
                                child: _buildField(
                                  controller: _postalCodeController,
                                  label: 'C.P. *',
                                  icon: Icons.tag_outlined,
                                  keyboardType: TextInputType.number,
                                  validator: _validatePostalCode,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _colonyController,
                                  label: 'Colonia',
                                  icon: Icons.location_city_outlined,
                                  textCapitalization: TextCapitalization.words,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildField(
                            controller: _streetAndNumberController,
                            label: 'Calle y Número *',
                            icon: Icons.home_outlined,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => _requiredField(
                                v, 'La calle y número son requeridos'),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Contacto ──────────────────────────────────
                      _buildSectionCard(
                        title: 'Contacto',
                        icon: Icons.contact_mail_outlined,
                        color: const Color(0xFF8B5CF6),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildField(
                                  controller: _phoneController,
                                  label: 'Teléfono',
                                  hint: '0000000000',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildField(
                                  controller: _emailController,
                                  label: 'Correo Electrónico',
                                  hint: 'ejemplo@correo.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),


                      const SizedBox(height: 24),

                      // ── Actions ───────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: _isSaving ? null : _savePatient,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                backgroundColor: primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Text(
                                      isEditing
                                          ? 'Actualizar Paciente'
                                          : 'Guardar Paciente',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Section card ─────────────────────────────────────────────────────────

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F36),
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F9)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  // ── Text field ───────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    final primary = Theme.of(context).primaryColor;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F36)),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: Colors.grey[400])
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
    );
  }

  // ── Dropdown ─────────────────────────────────────────────────────────────

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    final primary = Theme.of(context).primaryColor;
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1A1F36)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  // ── Date picker ──────────────────────────────────────────────────────────

  Widget _buildDatePicker() {
    final hasDate = _selectedBirthDate != null;
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18, color: Colors.grey[400]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasDate
                    ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                    : 'Fecha de Nacimiento *',
                style: TextStyle(
                  fontSize: 14,
                  color: hasDate
                      ? const Color(0xFF1A1F36)
                      : Colors.grey[500],
                ),
              ),
            ),
            Icon(Icons.unfold_more_rounded,
                size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
