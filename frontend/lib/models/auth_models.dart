class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}

class SignupRequest {
  final String username;
  final String email;
  final String password;
  final String? firstName;
  final String? lastName;
  final bool? isAdmin;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    this.firstName,
    this.lastName,
    this.isAdmin,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'isAdmin': isAdmin ?? false,
    };
  }
}

class AuthResponse {
  final String token;
  final String type;
  final int? id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final List<String> roles;

  AuthResponse({
    required this.token,
    required this.type,
    this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    required this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      type: json['type'] as String? ?? 'Bearer',
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          [],
    );
  }
}
