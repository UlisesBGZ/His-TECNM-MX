import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user_response.dart';

class UserService {
  static const String _tokenKey = 'auth_token';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Get all users
  Future<List<UserResponse>> getAllUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => UserResponse.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver usuarios');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener usuarios');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Get user by ID
  Future<UserResponse> getUserById(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para ver este usuario');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al obtener usuario');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para eliminar usuarios');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'No puedes eliminar este usuario');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al eliminar usuario');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }

  // Toggle user status (enable/disable)
  Future<UserResponse> toggleUserStatus(int id) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/users/$id/toggle-status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Usuario no encontrado');
      } else if (response.statusCode == 403) {
        throw Exception('No tienes permisos para modificar usuarios');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'No puedes modificar este usuario');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error al modificar usuario');
      }
    } catch (e) {
      if (e is Exception) {
        throw e;
      }
      throw Exception('Error de conexión: ${e.toString()}');
    }
  }
}
