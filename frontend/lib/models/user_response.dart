class UserResponse {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final bool enabled;
  final List<String> roles;
  final String? createdAt;
  final String? updatedAt;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.enabled,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      enabled: json['enabled'] as bool? ?? true,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isAdmin => roles.contains('ADMIN') || roles.contains('ROLE_ADMIN');
  bool get isDoctor =>
      roles.contains('DOCTOR') || roles.contains('ROLE_DOCTOR');
  bool get isNurse => roles.contains('NURSE') || roles.contains('ROLE_NURSE');

  String get roleDisplay {
    if (isAdmin) return 'Administrador';
    if (isDoctor) return 'Doctor';
    if (isNurse) return 'Enfermera';
    return 'Usuario';
  }
}
