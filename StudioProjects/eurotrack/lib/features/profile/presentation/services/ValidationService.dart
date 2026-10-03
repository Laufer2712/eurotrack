// lib/features/profile/services/validation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';

class ValidationService {
  final String _baseUrl = ApiConfig.authEndpoint;

  /// Verifica si el username ya existe (excluyendo al usuario actual)
  Future<bool> isUsernameAvailable(String username, int currentUserId) async {
    try {
      final url = Uri.parse('$_baseUrl/verificar-username');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username,
          "userId": currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available'] == true;
      }
      return true; // Si hay error, asumimos que está disponible
    } catch (e) {
      return true;
    }
  }

  /// Verifica si el email ya existe (excluyendo al usuario actual)
  Future<bool> isEmailAvailable(String email, int currentUserId) async {
    try {
      final url = Uri.parse('$_baseUrl/verificar-email');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email,
          "userId": currentUserId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['available'] == true;
      }
      return true;
    } catch (e) {
      return true;
    }
  }
}