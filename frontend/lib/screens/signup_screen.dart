import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isCreatingAdmin = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const _primary = Color(0xFF3B5BDB);
  static const _bg = Color(0xFFF4F6FB);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOutQuart),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      bool success;
      if (_isCreatingAdmin) {
        success = await authProvider.createAdmin(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim().isEmpty
              ? null
              : _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty
              ? null
              : _lastNameController.text.trim(),
        );
      } else {
        success = await authProvider.signup(
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim().isEmpty
              ? null
              : _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim().isEmpty
              ? null
              : _lastNameController.text.trim(),
        );
      }

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isCreatingAdmin
                  ? 'Administrador creado exitosamente'
                  : 'Usuario registrado exitosamente',
            ),
            backgroundColor: const Color(0xFF22C55E),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Error en el registro'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF475569)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isCreatingAdmin ? 'Crear Administrador' : 'Registro',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isAdmin = _isCreatingAdmin;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isAdmin
                  ? [const Color(0xFFEA580C), const Color(0xFFFB923C)]
                  : [_primary, const Color(0xFF5B7FFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (isAdmin ? const Color(0xFFEA580C) : _primary)
                    .withValues(alpha: 0.3),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_add_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'La Clemencia',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isAdmin ? 'Crear cuenta de administrador' : 'Crear nueva cuenta',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAdminToggle(),
            const SizedBox(height: 20),
            _buildLabel('Usuario *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _usernameController,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: _inputDecoration(
                hint: 'Ej: dr.gomez',
                icon: Icons.person_outline_rounded,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa un nombre de usuario';
                if (v.length < 3) return 'Mínimo 3 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Email *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: _inputDecoration(
                hint: 'correo@hospital.com',
                icon: Icons.email_outlined,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa un email';
                if (!v.contains('@')) return 'Email inválido';
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Nombre'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _firstNameController,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: _inputDecoration(
                          hint: 'Juan',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Apellido'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _lastNameController,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: _inputDecoration(
                          hint: 'Pérez',
                          icon: Icons.badge_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Contraseña *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: _inputDecoration(
                hint: 'Mínimo 6 caracteres',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                if (v.length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildLabel('Confirmar Contraseña *'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
              decoration: _inputDecoration(
                hint: 'Repite la contraseña',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                    color: const Color(0xFF94A3B8),
                  ),
                  onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirma la contraseña';
                if (v != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
            const SizedBox(height: 28),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return FilledButton(
                  onPressed: authProvider.isLoading ? null : _handleSignup,
                  style: FilledButton.styleFrom(
                    backgroundColor: _isCreatingAdmin
                        ? const Color(0xFFEA580C)
                        : _primary,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isCreatingAdmin
                              ? 'Crear Administrador'
                              : 'Crear Cuenta',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                );
              },
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Volver al inicio de sesión'),
              style: TextButton.styleFrom(
                foregroundColor: _primary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminToggle() {
    return Container(
      decoration: BoxDecoration(
        color: _isCreatingAdmin
            ? const Color(0xFFFFF7ED)
            : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCreatingAdmin
              ? const Color(0xFFFDBA74)
              : const Color(0xFFBFDBFE),
        ),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        title: Text(
          _isCreatingAdmin ? 'Cuenta de Administrador' : 'Cuenta de Usuario',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _isCreatingAdmin
                ? const Color(0xFFEA580C)
                : const Color(0xFF1D4ED8),
          ),
        ),
        subtitle: Text(
          _isCreatingAdmin
              ? 'Permisos completos del sistema'
              : 'Acceso estándar al sistema',
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        value: _isCreatingAdmin,
        activeColor: const Color(0xFFEA580C),
        inactiveThumbColor: _primary,
        inactiveTrackColor: const Color(0xFFBFDBFE),
        onChanged: (value) => setState(() => _isCreatingAdmin = value),
        secondary: Icon(
          _isCreatingAdmin
              ? Icons.admin_panel_settings_rounded
              : Icons.person_rounded,
          color: _isCreatingAdmin ? const Color(0xFFEA580C) : _primary,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF475569),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
      prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }
}
