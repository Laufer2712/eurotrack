import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';

class FavoritoService {
  final String _baseUrl = "${ApiConfig.domain}/api/favoritos";

  // Obtener favoritos de un usuario
  Future<List<Map<String, dynamic>>> getFavoritos(int usuarioId) async {
    final url = Uri.parse('$_baseUrl/usuario/$usuarioId');
    try {
      final response = await http.get(url);
      print("📡 Favoritos - Status: ${response.statusCode}");
      print("📄 Respuesta: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Map<String, dynamic>> favoritos = [];
        for (var item in data) {
          favoritos.add({
            'id': item['productoId'],
            'nombre': item['productoNombre'] ?? 'Sin nombre',
            'precio': item['productoPrecio'] is int
                ? (item['productoPrecio'] as int).toDouble()
                : item['productoPrecio']?.toDouble() ?? 0.0,
            'marca': item['productoMarca'] ?? '',
            'imagenUrl': item['productoImagenUrl'],
            'stock': 0,
            'codigo': item['productoCodigo'] ?? '',
          });
        }

        print("✅ Favoritos cargados: ${favoritos.length}");
        return favoritos;
      }
      return [];
    } catch (e) {
      print("Error getFavoritos: $e");
      return [];
    }
  }

  // Agregar a favoritos
  Future<bool> agregarFavorito(int usuarioId, int productoId) async {
    final url = Uri.parse('$_baseUrl/agregar');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuarioId": usuarioId,
          "productoId": productoId,
        }),
      );
      print("📡 Agregar favorito - Status: ${response.statusCode}");
      print("📄 Respuesta: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error agregarFavorito: $e");
      return false;
    }
  }

  // ✅ USANDO TOGGLE - Funciona con POST y es más confiable
  Future<bool> eliminarFavorito(int usuarioId, int productoId) async {
    try {
      final url = Uri.parse('$_baseUrl/toggle');

      print("📡 Toggle favorito - URL: $url");
      print("📡 UsuarioId: $usuarioId, ProductoId: $productoId");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "usuarioId": usuarioId,
          "productoId": productoId,
        }),
      );

      print("📡 Toggle favorito - Status: ${response.statusCode}");
      print("📡 Toggle favorito - Body: ${response.body}");

      // ✅ Si el toggle fue exitoso (200), se eliminó o agregó correctamente
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error toggleFavorito: $e");
      return false;
    }
  }

  // ✅ Alternativa: Usar DELETE directo (por si toggle no funciona)
  Future<bool> eliminarFavoritoDelete(int usuarioId, int productoId) async {
    try {
      final url = Uri.parse('$_baseUrl/eliminar')
          .replace(queryParameters: {
        'usuarioId': usuarioId.toString(),
        'productoId': productoId.toString(),
      });

      print("📡 Eliminar favorito (DELETE) - URL: $url");

      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("📡 Eliminar favorito (DELETE) - Status: ${response.statusCode}");
      print("📡 Eliminar favorito (DELETE) - Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Error eliminarFavorito (DELETE): $e");
      return false;
    }
  }

  // Verificar si un producto está en favoritos
  Future<bool> isFavorito(int usuarioId, int productoId) async {
    try {
      final url = Uri.parse('$_baseUrl/check')
          .replace(queryParameters: {
        'usuarioId': usuarioId.toString(),
        'productoId': productoId.toString(),
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['esFavorito'] ?? false;
      }
      return false;
    } catch (e) {
      print("Error isFavorito: $e");
      return false;
    }
  }
}