import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';

class AdminService {
  final String _baseUrl = ApiConfig.adminEndpoint;

  // ============================================================
  // 📊 ESTADÍSTICAS
  // ============================================================
  Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse('$_baseUrl/stats');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {};
    } catch (e) {
      print("Error getStats: $e");
      return {};
    }
  }

  // ============================================================
  // 👥 USUARIOS
  // ============================================================
  Future<List<Map<String, dynamic>>> getUsuarios() async {
    final url = Uri.parse('$_baseUrl/usuarios');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getUsuarios: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUsuarioById(int id) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error getUsuarioById: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> createUsuario(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/usuarios');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error createUsuario: $e");
      return null;
    }
  }

  Future<bool> updateUsuario(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updateUsuario: $e");
      return false;
    }
  }

  Future<bool> deleteUsuario(int id) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleteUsuario: $e");
      return false;
    }
  }

  Future<bool> cambiarRol(int id, String rol) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id/rol');
    try {
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"rol": rol}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error cambiarRol: $e");
      return false;
    }
  }

  Future<bool> toggleUsuarioActivo(int id) async {
    final url = Uri.parse('$_baseUrl/usuarios/$id/toggle-activo');
    try {
      final response = await http.patch(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error toggleUsuarioActivo: $e");
      return false;
    }
  }

  // ============================================================
  // 📦 PRODUCTOS
  // ============================================================
  Future<List<Map<String, dynamic>>> getProductos() async {
    final url = Uri.parse('$_baseUrl/productos');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getProductos: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> createProducto(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/productos');
    try {
      // ✅ Asegurar que la imagen se envía correctamente
      final Map<String, dynamic> body = {
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'codigo': data['codigo'] ?? '',
        'numeroParte': data['numeroParte'] ?? '',
        'marca': data['marca'] ?? '',
        'precio': data['precio'] ?? 0,
        'stock': data['stock'] ?? 0,
        'imagenUrl': data['imagenUrl'] ?? '',
        'activo': data['activo'] ?? true,
        'categoriaId': data['categoriaId'],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error createProducto: $e");
      return null;
    }
  }

  Future<bool> updateProducto(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/productos/$id');
    try {
      // ✅ Asegurar que la imagen se envía correctamente
      final Map<String, dynamic> body = {
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'codigo': data['codigo'] ?? '',
        'numeroParte': data['numeroParte'] ?? '',
        'marca': data['marca'] ?? '',
        'precio': data['precio'] ?? 0,
        'stock': data['stock'] ?? 0,
        'imagenUrl': data['imagenUrl'] ?? '',
        'activo': data['activo'] ?? true,
        'categoriaId': data['categoriaId'],
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updateProducto: $e");
      return false;
    }
  }

  Future<bool> deleteProducto(int id) async {
    final url = Uri.parse('$_baseUrl/productos/$id');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleteProducto: $e");
      return false;
    }
  }

  Future<bool> toggleProductoActivo(int id) async {
    final url = Uri.parse('$_baseUrl/productos/$id/toggle');
    try {
      final response = await http.patch(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error toggleProductoActivo: $e");
      return false;
    }
  }

  // ============================================================
  // 🏷️ CATEGORÍAS (CON SOPORTE PARA IMÁGENES)
  // ============================================================
  Future<List<Map<String, dynamic>>> getCategorias() async {
    final url = Uri.parse('$_baseUrl/categorias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getCategorias: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> createCategoria(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/categorias');
    try {
      // ✅ Incluir imagen de categoría
      final Map<String, dynamic> body = {
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'imagenUrl': data['imagenUrl'] ?? '',  // ✅ Imagen de categoría
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("Error createCategoria: $e");
      return null;
    }
  }

  Future<bool> updateCategoria(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/categorias/$id');
    try {
      // ✅ Incluir imagen de categoría
      final Map<String, dynamic> body = {
        'nombre': data['nombre'] ?? '',
        'descripcion': data['descripcion'] ?? '',
        'imagenUrl': data['imagenUrl'] ?? '',  // ✅ Imagen de categoría
      };

      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error updateCategoria: $e");
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    final url = Uri.parse('$_baseUrl/categorias/$id');
    try {
      final response = await http.delete(url);
      return response.statusCode == 200;
    } catch (e) {
      print("Error deleteCategoria: $e");
      return false;
    }
  }

  // ============================================================
  // 📋 PEDIDOS
  // ============================================================
  Future<List<Map<String, dynamic>>> getPedidos() async {
    final url = Uri.parse('${ApiConfig.domain}/api/pedidos/admin/todos');
    try {
      final response = await http.get(url);
      print("DEBUG URL: $url");
      print("DEBUG STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['id'],
            'estado': item['estado'] ?? 'PENDIENTE',
            'fecha': item['fecha'] ?? DateTime.now().toString(),
            'total': (item['total'] ?? 0.0).toDouble(),
            'usuarioId': item['usuarioId'] ?? 0,
            'usuarioNombre': item['usuario'] != null
                ? item['usuario']['nombre']
                : 'Sin nombre',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print("Error en getPedidos: $e");
      return [];
    }
  }

  Future<bool> actualizarEstadoPedido(int pedidoId, String estado) async {
    final url = Uri.parse('${ApiConfig.domain}/api/pedidos/admin/estado/$pedidoId');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"estado": estado}),
      );
      print("DEBUG URL: $url");
      print("DEBUG STATUS: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      print("Error en actualizarEstadoPedido: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> getPedidoDetalle(int pedidoId) async {
    final url = Uri.parse('${ApiConfig.domain}/api/pedidos/$pedidoId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("JSON COMPLETO RECIBIDO: $data");
        return data;
      }
    } catch (e) {
      print("Error al obtener detalle: $e");
    }
    return {'detalles': []};
  }

  Future<List<Map<String, dynamic>>> getPedidosByUsuario(int usuarioId) async {
    final url = Uri.parse('${ApiConfig.domain}/api/pedidos/usuario/$usuarioId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getPedidosByUsuario: $e");
      return [];
    }
  }

  // ============================================================
  // ⭐ FAVORITOS
  // ============================================================
  Future<List<Map<String, dynamic>>> getFavoritosByUsuario(int usuarioId) async {
    final url = Uri.parse('${ApiConfig.domain}/api/favoritos/usuario/$usuarioId');
    try {
      final response = await http.get(url);
      print("📡 Favoritos usuario - Status: ${response.statusCode}");
      print("📄 Respuesta: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        List<Map<String, dynamic>> favoritos = [];
        for (var item in data) {
          favoritos.add({
            'productoId': item['productoId'],
            'productoNombre': item['productoNombre'],
            'productoMarca': item['productoMarca'],
            'productoPrecio': item['productoPrecio'],
            'productoImagenUrl': item['productoImagenUrl'],
            'productoCodigo': item['productoCodigo'],
          });
        }
        print("✅ Favoritos mapeados: ${favoritos.length}");
        return favoritos;
      }
      return [];
    } catch (e) {
      print("Error getFavoritosByUsuario: $e");
      return [];
    }
  }

  // ============================================================
  // 📊 LOGS / AUDITORÍA
  // ============================================================
  Future<List<Map<String, dynamic>>> getLogs() async {
    final url = Uri.parse('${ApiConfig.domain}/api/auditoria');
    try {
      final response = await http.get(url);
      print("📡 Logs - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("✅ Logs cargados: ${data.length}");
        return List<Map<String, dynamic>>.from(data);
      }
      return [];
    } catch (e) {
      print("❌ Error getLogs: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogsByUsuario(String usuario) async {
    final url = Uri.parse('${ApiConfig.domain}/api/auditoria/usuario/$usuario');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getLogsByUsuario: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLogsByAccion(String accion) async {
    final url = Uri.parse('${ApiConfig.domain}/api/auditoria/accion/$accion');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      }
      return [];
    } catch (e) {
      print("Error getLogsByAccion: $e");
      return [];
    }
  }
}