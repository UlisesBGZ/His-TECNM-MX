import 'package:flutter/foundation.dart';

class ApiConfig {
  // ⚙️ CONFIGURACIÓN DINÁMICA DE RED
  // Detecta automáticamente si estás en web o móvil

  // 🔧 SOLO CAMBIA ESTA IP si corres en dispositivo móvil
  // Para encontrar tu IP: En PowerShell ejecuta: ipconfig | Select-String "IPv4"
  static const String _mobileBaseUrl = 'http://192.168.0.181:8080';
  static const String _webBaseUrl = 'http://localhost:8080';

  // Getter dinámico que detecta la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      return _webBaseUrl; // Web usa localhost
    } else {
      return _mobileBaseUrl; // Móvil usa IP de red
    }
  }

  static String get apiAuth => '$baseUrl/api/auth';

  static String get loginEndpoint => '$apiAuth/login';
  static String get signupEndpoint => '$apiAuth/signup';
  static String get createAdminEndpoint => '$apiAuth/create-admin';
  static String get checkAuthEndpoint => '$apiAuth/check';
}
