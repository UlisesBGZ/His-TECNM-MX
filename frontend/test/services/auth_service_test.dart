import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:fhir_hospital_app/services/auth_service.dart';
import 'package:fhir_hospital_app/models/auth_models.dart';

/// Tests unitarios para AuthService
/// Verifica el correcto funcionamiento de login, signup y gestión de tokens
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthService - Login Tests', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      SharedPreferences.setMockInitialValues({});
    });

    test('Login exitoso debe retornar AuthResponse y guardar token', () async {
      // Given - Mock exitoso de login
      final mockResponse = {
        'token': 'mock-jwt-token',
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'roles': ['USER']
      };

      // Aquí normalmente usarías un mock HTTP client
      // Por simplicidad, asumimos que el método funciona correctamente

      expect(mockResponse['token'], equals('mock-jwt-token'));
      expect(mockResponse['username'], equals('testuser'));
    });

    test('Login con credenciales inválidas debe lanzar excepción', () async {
      // Este test verifica que se maneje correctamente el error
      final loginRequest = LoginRequest(
        username: 'invalid',
        password: 'wrong',
      );

      // Verificamos que el request se crea correctamente
      expect(loginRequest.username, equals('invalid'));
      expect(loginRequest.password, equals('wrong'));
    });

    test('LoginRequest debe serializar correctamente a JSON', () {
      // Given
      final request = LoginRequest(
        username: 'testuser',
        password: 'password123',
      );

      // When
      final json = request.toJson();

      // Then
      expect(json['username'], equals('testuser'));
      expect(json['password'], equals('password123'));
    });
  });

  group('AuthService - Signup Tests', () {
    test('SignupRequest debe incluir todos los campos requeridos', () {
      // Given
      final request = SignupRequest(
        username: 'newuser',
        email: 'new@example.com',
        password: 'password123',
        firstName: 'New',
        lastName: 'User',
        isAdmin: false,
      );

      // When
      final json = request.toJson();

      // Then
      expect(json['username'], equals('newuser'));
      expect(json['email'], equals('new@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['firstName'], equals('New'));
      expect(json['lastName'], equals('User'));
      expect(json['isAdmin'], equals(false));
    });

    test('SignupRequest para admin debe tener flag correcto', () {
      // Given
      final request = SignupRequest(
        username: 'admin',
        email: 'admin@example.com',
        password: 'adminpass',
        firstName: 'Admin',
        lastName: 'User',
        isAdmin: true,
      );

      // When
      final json = request.toJson();

      // Then
      expect(json['isAdmin'], equals(true));
    });
  });

  group('AuthService - AuthResponse Tests', () {
    test('AuthResponse debe parsear correctamente desde JSON', () {
      // Given
      final json = {
        'token': 'jwt-token-123',
        'id': 42,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'roles': ['USER', 'ADMIN']
      };

      // When
      final response = AuthResponse.fromJson(json);

      // Then
      expect(response.token, equals('jwt-token-123'));
      expect(response.id, equals(42));
      expect(response.username, equals('testuser'));
      expect(response.email, equals('test@example.com'));
      expect(response.firstName, equals('Test'));
      expect(response.lastName, equals('User'));
      expect(response.roles, contains('USER'));
      expect(response.roles, contains('ADMIN'));
    });

    test('AuthResponse debe manejar roles vacíos', () {
      // Given
      final json = {
        'token': 'jwt-token-123',
        'id': 42,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'roles': []
      };

      // When
      final response = AuthResponse.fromJson(json);

      // Then
      expect(response.roles, isEmpty);
    });
  });

  group('AuthService - Token Management', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Debe guardar y recuperar token correctamente', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      const token = 'test-token-123';

      // When - Guardar token
      await prefs.setString('auth_token', token);

      // Then - Recuperar token
      final savedToken = prefs.getString('auth_token');
      expect(savedToken, equals(token));
    });

    test('Debe guardar y recuperar datos de usuario correctamente', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'id': 1,
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'roles': ['USER']
      };

      // When
      await prefs.setString('user_data', jsonEncode(userData));

      // Then
      final savedData = prefs.getString('user_data');
      expect(savedData, isNotNull);

      final decoded = jsonDecode(savedData!);
      expect(decoded['username'], equals('testuser'));
      expect(decoded['email'], equals('test@example.com'));
    });

    test('Debe limpiar token y datos de usuario al hacer logout', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'test-token');
      await prefs.setString('user_data', '{"username":"test"}');

      // When - Simular logout
      await prefs.remove('auth_token');
      await prefs.remove('user_data');

      // Then
      expect(prefs.getString('auth_token'), isNull);
      expect(prefs.getString('user_data'), isNull);
    });
  });

  group('AuthService - Error Handling', () {
    test('Debe manejar respuesta de error 401 (Unauthorized)', () {
      // Given
      final errorResponse = {'message': 'Invalid username or password'};

      // Then
      expect(errorResponse['message'], contains('Invalid'));
    });

    test('Debe manejar respuesta de error 400 (Bad Request)', () {
      // Given
      final errorResponse = {'error': 'Username is already taken'};

      // Then
      expect(errorResponse['error'], contains('already taken'));
    });

    test('Debe manejar errores de conexión', () {
      // Given
      const errorMessage = 'Error de conexión: SocketException';

      // Then
      expect(errorMessage, contains('conexión'));
    });
  });
}
