import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'user_management_screen.dart';
import 'patient_list_screen.dart';
import 'encounter_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _slideAnimations = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              user?.isAdmin == true ? 'Panel Administrativo' : 'La Clemencia',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1F36),
              ),
            ),
            Text(
              'Sistema de Gestión Clínica',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF1A1F36)),
            tooltip: 'Notificaciones',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sin notificaciones nuevas')),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Tooltip(
              message: 'Cerrar sesión',
              child: InkWell(
                onTap: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                  ),
                  child: const Icon(Icons.logout_outlined,
                      size: 18, color: Color(0xFFEF4444)),
                ),
              ),
            ),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final isTablet = w >= 600;
                final isDesktop = w >= 1024;
                final hPadding = isDesktop ? 48.0 : isTablet ? 32.0 : 20.0;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: hPadding, vertical: 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── User card ────────────────────────────────────
                          FadeTransition(
                            opacity: _fadeAnimations[0],
                            child: SlideTransition(
                              position: _slideAnimations[0],
                              child: _buildUserCard(
                                username: user.username,
                                fullName: user.fullName,
                                email: user.email,
                                isAdmin: user.isAdmin,
                                isTablet: isTablet,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // ── Section header ───────────────────────────────
                          FadeTransition(
                            opacity: _fadeAnimations[1],
                            child: _buildSectionHeader(
                              title: user.isAdmin
                                  ? 'Módulos de Administración'
                                  : 'Módulos Clínicos',
                              icon: user.isAdmin
                                  ? Icons.tune
                                  : Icons.apps_outlined,
                              primary: primary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Module cards (responsive) ────────────────────
                          _buildModulesSection(
                              context, user, isTablet, isDesktop),

                          const SizedBox(height: 28),

                          // ── System info ──────────────────────────────────
                          FadeTransition(
                            opacity: _fadeAnimations[5],
                            child: SlideTransition(
                              position: _slideAnimations[5],
                              child: _buildSystemInfoCard(isTablet: isTablet),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── Modules section ──────────────────────────────────────────────────────

  Widget _buildModulesSection(
      BuildContext context, user, bool isTablet, bool isDesktop) {
    if (!user.isAdmin) {
      final modules = [
        _ModuleInfo(
          icon: Icons.groups_2_outlined,
          title: 'Pacientes',
          subtitle: 'Registro de pacientes',
          color: const Color(0xFF3B82F6),
          animIndex: 2,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PatientListScreen())),
        ),
        _ModuleInfo(
          icon: Icons.medical_services_outlined,
          title: 'Encuentros',
          subtitle: 'Historial de consultas',
          color: const Color(0xFF10B981),
          animIndex: 3,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EncounterListScreen())),
        ),
      ];

      if (isDesktop) {
        return _buildCardRow(context, modules);
      } else if (isTablet) {
        return Column(
          children: [
            _buildCardRow(context, [modules[0], modules[1]]),
            const SizedBox(height: 10),
            _buildAnimatedCard(context, modules[2]),
          ],
        );
      } else {
        return _buildCardColumn(context, modules);
      }
    } else {
      final modules = [
        _ModuleInfo(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Configuración',
          subtitle: 'Ajustes del sistema',
          color: const Color(0xFFEF4444),
          animIndex: 2,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Función "Configuración" en desarrollo')),
          ),
        ),
        _ModuleInfo(
          icon: Icons.manage_accounts_outlined,
          title: 'Usuarios',
          subtitle: 'Gestión de cuentas y permisos',
          color: const Color(0xFF14B8A6),
          animIndex: 3,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const UserManagementScreen())),
        ),
      ];

      return isTablet || isDesktop
          ? _buildCardRow(context, modules)
          : _buildCardColumn(context, modules);
    }
  }

  Widget _buildCardRow(BuildContext context, List<_ModuleInfo> modules) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < modules.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _buildAnimatedCard(context, modules[i])),
          ],
        ],
      ),
    );
  }

  Widget _buildCardColumn(BuildContext context, List<_ModuleInfo> modules) {
    return Column(
      children: [
        for (int i = 0; i < modules.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildAnimatedCard(context, modules[i]),
        ],
      ],
    );
  }

  Widget _buildAnimatedCard(BuildContext context, _ModuleInfo info) {
    final fade = info.animIndex < _fadeAnimations.length
        ? _fadeAnimations[info.animIndex]
        : _fadeAnimations.last;
    final slide = info.animIndex < _slideAnimations.length
        ? _slideAnimations[info.animIndex]
        : _slideAnimations.last;
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: _buildModuleCard(context, info: info),
      ),
    );
  }

  // ── Widgets ──────────────────────────────────────────────────────────────

  Widget _buildUserCard({
    required String username,
    required String fullName,
    required String email,
    required bool isAdmin,
    required bool isTablet,
  }) {
    final gradient = isAdmin
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF97316), Color(0xFFFB923C)],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B5BDB), Color(0xFF5C7CFA)],
          );
    final shadowColor =
        isAdmin ? const Color(0xFFF97316) : const Color(0xFF3B5BDB);
    final avatarSize = isTablet ? 68.0 : 56.0;
    final nameFontSize = isTablet ? 20.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: isTablet ? 13 : 12,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    isAdmin ? 'Administrador' : 'Médico',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color primary,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1F36),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard(BuildContext context, {required _ModuleInfo info}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: info.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
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
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(info.icon, color: info.color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      info.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1F36),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      info.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.grey[300], size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard({required bool isTablet}) {
    const items = [
      _StatusItem(
        label: 'Servidor FHIR',
        value: 'Conectado',
        color: Color(0xFF10B981),
        icon: Icons.cloud_done_outlined,
      ),
      _StatusItem(
        label: 'Versión',
        value: '1.0.0',
        color: Color(0xFF3B5BDB),
        icon: Icons.info_outline_rounded,
      ),
      _StatusItem(
        label: 'Base de Datos',
        value: 'PostgreSQL',
        color: Color(0xFF8B5CF6),
        icon: Icons.storage_outlined,
      ),
      _StatusItem(
        label: 'Estándar',
        value: 'HL7 FHIR R4',
        color: Color(0xFFF59E0B),
        icon: Icons.verified_outlined,
      ),
    ];

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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Color(0xFF3B5BDB),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Estado del Sistema',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F3F9)),

          // Tablet/desktop: 2 columnas; mobile: lista vertical
          if (isTablet)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildStatusRow(items[0])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatusRow(items[1])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildStatusRow(items[2])),
                        const SizedBox(width: 8),
                        Expanded(child: _buildStatusRow(items[3])),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: _buildStatusRowContent(items[i]),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 64,
                        color: Color(0xFFF1F3F9)),
                ],
              );
            }),
        ],
      ),
    );
  }

  // Tablet: cada item como contenedor con borde
  Widget _buildStatusRow(_StatusItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: item.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.color.withValues(alpha: 0.15)),
      ),
      child: _buildStatusRowContent(item),
    );
  }

  // Contenido compartido entre layouts
  Widget _buildStatusRowContent(_StatusItem item) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, color: item.color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4A5568),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: item.color.withValues(alpha: 0.2)),
          ),
          child: Text(
            item.value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Data classes ─────────────────────────────────────────────────────────────

class _ModuleInfo {
  const _ModuleInfo({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.animIndex,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final int animIndex;
  final VoidCallback onTap;
}

class _StatusItem {
  const _StatusItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String label;
  final String value;
  final Color color;
  final IconData icon;
}
