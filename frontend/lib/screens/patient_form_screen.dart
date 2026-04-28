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
  late final TextEditingController _generalAntecedentsController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedBirthDate;
  bool _isSaving = false;

  static const List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'No especificado',
  ];

  @override
  void initState() {
    super.initState();

    _identifierController = TextEditingController(
      text: widget.patient?.identifier ?? '',
    );
    _givenNamesController = TextEditingController(
      text: widget.patient?.firstName ?? '',
    );
    _paternalLastNameController = TextEditingController(
      text: widget.patient?.paternalLastName ?? '',
    );
    _maternalLastNameController = TextEditingController(
      text: widget.patient?.maternalLastName ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.patient?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.patient?.email ?? '',
    );
    _stateController = TextEditingController(
      text: widget.patient?.state ?? '',
    );
    _municipalityController = TextEditingController(
      text: widget.patient?.municipality ?? '',
    );
    _postalCodeController = TextEditingController(
      text: widget.patient?.postalCode ?? '',
    );
    _streetAndNumberController = TextEditingController(
      text: widget.patient?.streetAndNumber ?? '',
    );
    _colonyController = TextEditingController(
      text: widget.patient?.colony ?? '',
    );
    _generalAntecedentsController = TextEditingController(
      text: widget.patient?.clinicalAntecedents ?? '',
    );

    _selectedGender = widget.patient?.gender;
    _selectedBloodType = widget.patient?.bloodType;

    if (widget.patient?.birthDate != null) {
      try {
        _selectedBirthDate = DateTime.parse(widget.patient!.birthDate!);
      } catch (e) {
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
    _generalAntecedentsController.dispose();
    super.dispose();
  }

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
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de nacimiento es requerida'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

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
        bloodType:
            _selectedBloodType == 'No especificado' ? null : _selectedBloodType,
        state: _stateController.text.trim(),
        municipality: _municipalityController.text.trim(),
        postalCode: _postalCodeController.text.trim(),
        streetAndNumber: _streetAndNumberController.text.trim(),
        colony: _colonyController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        clinicalAntecedents: _generalAntecedentsController.text.trim(),
      );

      FhirPatient savedPatient;

      if (widget.patient == null) {
        savedPatient = await _fhirService.createPatient(patient);
      } else {
        savedPatient = await _fhirService.updatePatient(patient);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.patient == null
                  ? (savedPatient.ehrId != null
                      ? 'Paciente creado y vinculado a EHR ${savedPatient.ehrId}'
                      : 'Paciente creado exitosamente')
                  : 'Paciente actualizado exitosamente',
            ),
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
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
    );
  }

  String? _requiredField(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

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
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (!RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())) {
      return 'Correo inválido';
    }
    return null;
  }

  String? _validateBloodType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    const allowed = {'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'};
    if (!allowed.contains(value.trim().toUpperCase())) {
      return 'Tipo de sangre inválido';
    }
    return null;
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Paciente' : 'Nuevo Paciente'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'Datos Personales',
              icon: Icons.badge,
              children: [
                _buildTextField(
                  controller: _identifierController,
                  label: 'CURP *',
                  hint: 'Ej: ABCD123456HDFRRL09',
                  icon: Icons.perm_identity,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'La CURP es requerida';
                    }
                    final normalizedCurp = value.trim().toUpperCase();
                    if (!RegExp(r'^[A-Z0-9]{18}$').hasMatch(normalizedCurp)) {
                      return 'La CURP debe tener 18 caracteres alfanuméricos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _givenNamesController,
                  label: 'Nombre(s) *',
                  icon: Icons.person,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    return _requiredField(value, 'El nombre es requerido');
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _paternalLastNameController,
                        label: 'Apellido Paterno *',
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          return _requiredField(value, 'Requerido');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _maternalLastNameController,
                        label: 'Apellido Materno *',
                        icon: Icons.person_outline,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          return _requiredField(value, 'Requerido');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de Nacimiento (YYYY-MM-DD) *',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedBirthDate != null
                          ? DateFormat('yyyy-MM-dd').format(_selectedBirthDate!)
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: _selectedBirthDate != null
                            ? Colors.black
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final useColumn = constraints.maxWidth < 430;

                    final sexoField = _buildDropdownField(
                      label: 'Sexo',
                      icon: Icons.wc,
                      value: _selectedGender,
                      items: const [
                        'male',
                        'female',
                        'other',
                        'unknown',
                      ],
                      validator: (value) =>
                          _requiredField(value, 'El sexo es requerido'),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    );

                    final bloodTypeField = _buildDropdownField(
                      label: 'Tipo de Sangre',
                      icon: Icons.bloodtype,
                      value: _selectedBloodType,
                      items: _bloodTypes,
                      validator: _validateBloodType,
                      onChanged: (value) {
                        setState(() {
                          _selectedBloodType = value;
                        });
                      },
                    );

                    if (useColumn) {
                      return Column(
                        children: [
                          sexoField,
                          const SizedBox(height: 16),
                          bloodTypeField,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: sexoField),
                        const SizedBox(width: 16),
                        Expanded(child: bloodTypeField),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Dirección',
              icon: Icons.location_on,
              children: [
                _buildTextField(
                  controller: _stateController,
                  label: 'Entidad Federativa',
                  icon: Icons.map,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => _requiredField(
                      value, 'La entidad federativa es requerida'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _municipalityController,
                  label: 'Municipio',
                  icon: Icons.apartment,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      _requiredField(value, 'El municipio es requerido'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _postalCodeController,
                  label: 'Código Postal',
                  icon: Icons.tag,
                  keyboardType: TextInputType.number,
                  validator: _validatePostalCode,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _streetAndNumberController,
                  label: 'Calle y Número',
                  icon: Icons.home,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      _requiredField(value, 'La calle y número son requeridos'),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _colonyController,
                  label: 'Colonia',
                  icon: Icons.location_city,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Contacto',
              icon: Icons.contact_mail,
              children: [
                _buildTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: 'Ej: 0000000000',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hint: 'ejemplo@correo.com',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Antecedentes Clínicos',
              icon: Icons.medical_information,
              children: [
                _buildTextField(
                  controller: _generalAntecedentsController,
                  label: 'Antecedentes Generales',
                  icon: Icons.notes,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isSaving ? null : () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Cancelar'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _savePatient,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(isEditing ? 'Actualizar' : 'Crear Paciente'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
