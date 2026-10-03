import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = ApiConfig.authEndpoint;

  // ==================== GET USER DATA ====================
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener datos de usuario: $e');
      return null;
    }
  }

  // ==================== LOGIN ====================
  Future<Map<String, dynamic>?> login(String emailOrUsername, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": emailOrUsername, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(data));
        await prefs.setBool('is_logged_in', true);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ==================== REGISTRO (ACTUALIZADO) ====================
  // ==================== REGISTRO (CORREGIDO) ====================
  Future<Map<String, dynamic>?> register(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/register');
    try {
      final Map<String, dynamic> body = {
        "nombre": data['nombre'] ?? '',
        "cedula": data['cedula'] ?? '',
        "username": data['username'] ?? '',
        "email": data['email'] ?? '',
        "password": data['password'] ?? '',
        "rol": data['rol'] ?? 'CLIENTE',
        "tipoCliente": data['tipoCliente'] ?? 'NATURAL',
        "telefono": data['telefono'] ?? '',
      };

      // Agregar campos específicos para JURIDICO
      if (data['tipoCliente'] == 'JURIDICO') {
        body['razonSocial'] = data['razonSocial'] ?? '';
        body['nit'] = data['nit'] ?? '';
        body['registroMercantil'] = data['registroMercantil'] ?? '';
        body['direccionFiscal'] = data['direccionFiscal'] ?? '';
        body['contribuyenteEspecial'] = data['contribuyenteEspecial'] ?? false;
      }

      // Agregar campos específicos para TRANSPORTISTA
      if (data['tipoCliente'] == 'TRANSPORTISTA') {
        body['licenciaConducir'] = data['licenciaConducir'] ?? '';
        body['aniosExperiencia'] = data['aniosExperiencia'] ?? 0;
        body['tipoVehiculo'] = data['tipoVehiculo'] ?? 'CAMION';
      }

      print('📤 Registrando usuario: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      // ✅ Intentar decodificar la respuesta
      try {
        final responseData = jsonDecode(response.body);

        // ✅ CORRECCIÓN AQUÍ: Aceptar 200, 201 y 202 como éxito
        if (response.statusCode == 200 ||
            response.statusCode == 201 ||
            response.statusCode == 202) {

          // ✅ Verificar si la respuesta contiene un usuario
          if (responseData is Map && responseData.containsKey('id')) {
            // ✅ Es un usuario registrado exitosamente
            return {
              'success': true,
              'data': responseData,
              'message': 'Registro exitoso',
            };
          }

          // ✅ Si es un mensaje de éxito
          if (responseData is Map && responseData.containsKey('mensaje')) {
            return {
              'success': true,
              'data': responseData,
              'message': responseData['mensaje'],
            };
          }

          // ✅ Si la respuesta es un objeto usuario
          return {
            'success': true,
            'data': responseData,
            'message': 'Registro exitoso',
          };
        }

        // ✅ Si es error 400 (validación)
        if (response.statusCode == 400) {
          if (responseData is Map && responseData.containsKey('error')) {
            return {
              'success': false,
              'error': responseData['error'],
            };
          }
          if (responseData is String) {
            return {
              'success': false,
              'error': responseData,
            };
          }
          return {
            'success': false,
            'error': 'Error en los datos enviados',
          };
        }

        // ✅ Si es error 500 (servidor)
        if (response.statusCode == 500) {
          if (responseData is Map && responseData.containsKey('error')) {
            return {
              'success': false,
              'error': responseData['error'],
            };
          }
          return {
            'success': false,
            'error': 'Error interno del servidor. Por favor, intenta más tarde.',
          };
        }

        // ✅ Otros errores
        return {
          'success': false,
          'error': responseData is Map && responseData.containsKey('error')
              ? responseData['error']
              : 'Error en el registro: ${response.statusCode}',
        };

      } catch (e) {
        // ✅ Si no se puede decodificar el JSON
        print('❌ Error al decodificar respuesta: $e');
        return {
          'success': false,
          'error': 'Error al procesar la respuesta del servidor',
        };
      }

    } catch (e) {
      print('❌ Error en registro: $e');
      return {
        'success': false,
        'error': 'Error de conexión: $e',
      };
    }
  }
  // ==================== ACTUALIZAR PERFIL ====================
  Future<bool> updateProfile({
    required int userId,
    required String nombre,
    required String username,
    required String telefono,
    File? imageFile,
  }) async {
    final url = Uri.parse('$_baseUrl/update-profile/$userId');
    String? base64Image;
    if (imageFile != null) {
      List<int> imageBytes = await imageFile.readAsBytes();
      base64Image = base64Encode(imageBytes);
    }

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "username": username,
          "telefono": telefono,
          "fotoPerfil": base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        final String? userDataString = prefs.getString('user_data');
        if (userDataString != null) {
          Map<String, dynamic> userData = jsonDecode(userDataString);
          userData['usuario'] = nombre;
          userData['username'] = username;
          await prefs.setString('user_data', jsonEncode(userData));
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ==================== CAMBIAR CONTRASEÑA ====================
  Future<bool> changePassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse('$_baseUrl/change-password/$userId');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==================== RECUPERACIÓN CON CÓDIGO ====================
  Future<Map<String, dynamic>?> verificarUsuario(String email, String cedula) async {
    final url = Uri.parse('$_baseUrl/verificar-usuario');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "cedula": cedula,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> solicitarRecuperacion(String email, String cedula) async {
    final url = Uri.parse('$_baseUrl/solicitar-recuperacion');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "cedula": cedula,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403) {
        final error = jsonDecode(response.body);
        return {"error": error['error'] ?? "Error en la solicitud"};
      }

      return null;
    } catch (e) {
      return {"error": "Error de conexión: $e"};
    }
  }

  Future<Map<String, dynamic>?> verificarCodigo(String token) async {
    final url = Uri.parse('$_baseUrl/verificar-codigo');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"token": token}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 410 || response.statusCode == 408) {
        final error = jsonDecode(response.body);
        return {"valido": false, "error": error['error'] ?? "Código inválido"};
      }

      return {"valido": false, "error": "Error al verificar código"};
    } catch (e) {
      return {"valido": false, "error": "Error de conexión: $e"};
    }
  }

  Future<Map<String, dynamic>?> cambiarConCodigo(String token, String nuevaPassword) async {
    final url = Uri.parse('$_baseUrl/cambiar-con-codigo');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "nuevaPassword": nuevaPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 410 || response.statusCode == 408) {
        final error = jsonDecode(response.body);
        return {"error": error['error'] ?? "Error al cambiar contraseña"};
      }

      return {"error": "Error al cambiar la contraseña"};
    } catch (e) {
      return {"error": "Error de conexión: $e"};
    }
  }

  Future<Map<String, dynamic>?> restablecerPassword(String token, String nuevaPassword) async {
    final url = Uri.parse('$_baseUrl/restablecer-password');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": token,
          "nuevaPassword": nuevaPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 410 || response.statusCode == 408) {
        final error = jsonDecode(response.body);
        return {"error": error['error'] ?? "Error al restablecer"};
      }

      return {"error": "Error al restablecer la contraseña"};
    } catch (e) {
      return {"error": "Error de conexión: $e"};
    }
  }

  Future<Map<String, dynamic>?> verificarToken(String token) async {
    final url = Uri.parse('$_baseUrl/verificar-token?token=$token');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 400 || response.statusCode == 404 ||
          response.statusCode == 410 || response.statusCode == 408) {
        final error = jsonDecode(response.body);
        return {"valido": false, "error": error['error'] ?? "Token inválido"};
      }

      return {"valido": false, "error": "Error al verificar token"};
    } catch (e) {
      return {"valido": false, "error": "Error de conexión: $e"};
    }
  }
}