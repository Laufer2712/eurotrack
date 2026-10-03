import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';

class ProductoService {
  //final String _baseUrl = "http://10.0.2.2:8090/api";
  final String _baseUrl = "${ApiConfig.domain}/api";

  // 🔥 MODIFICADO: Ahora los productos tienen categoriaId y categoriaNombre
  Future<List<Map<String, dynamic>>> getCatalogo() async {
    final url = Uri.parse('$_baseUrl/productos/catalogo');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // Transforma los DTOs a mapas que tu UI espera
        List<Map<String, dynamic>> productos = [];
        for (var item in data) {
          productos.add({
            'id': item['id'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'codigo': item['codigo'],
            'numeroParte': item['numeroParte'],
            'marca': item['marca'],
            'precio': item['precio'] is int
                ? (item['precio'] as int).toDouble()
                : item['precio'],
            'stock': item['stock'],
            'imagenUrl': item['imagenUrl'],
            'activo': item['activo'],
            'categoriaId': item['categoriaId'],      // ← NUEVO
            'categoriaNombre': item['categoriaNombre'], // ← NUEVO
          });
        }

        print("✅ Productos cargados: ${productos.length}");
        return productos;
      }
      return [];
    } catch (e) {
      print("Error getCatalogo: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCategorias() async {
    final url = Uri.parse('$_baseUrl/categorias');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Map<String, dynamic>> categorias = [];
        for (var item in data) {
          categorias.add({
            'id': item['id'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'imagenUrl': item['imagenUrl'],
          });
        }

        print("✅ Categorías cargadas: ${categorias.length}");
        return categorias;
      }
      return [];
    } catch (e) {
      print("Error getCategorias: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProductosByCategoria(int categoriaId) async {
    final url = Uri.parse('$_baseUrl/productos/catalogo/categoria/$categoriaId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Map<String, dynamic>> productos = [];
        for (var item in data) {
          productos.add({
            'id': item['id'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'codigo': item['codigo'],
            'numeroParte': item['numeroParte'],
            'marca': item['marca'],
            'precio': item['precio'] is int
                ? (item['precio'] as int).toDouble()
                : item['precio'],
            'stock': item['stock'],
            'imagenUrl': item['imagenUrl'],
            'activo': item['activo'],
            'categoriaId': item['categoriaId'],
            'categoriaNombre': item['categoriaNombre'],
          });
        }
        return productos;
      }
      return [];
    } catch (e) {
      print("Error getProductosByCategoria: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> buscarProductos(String query) async {
    final url = Uri.parse('$_baseUrl/productos/buscar?q=$query');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<Map<String, dynamic>> productos = [];
        for (var item in data) {
          productos.add({
            'id': item['id'],
            'nombre': item['nombre'],
            'descripcion': item['descripcion'],
            'codigo': item['codigo'],
            'numeroParte': item['numeroParte'],
            'marca': item['marca'],
            'precio': item['precio'] is int
                ? (item['precio'] as int).toDouble()
                : item['precio'],
            'stock': item['stock'],
            'imagenUrl': item['imagenUrl'],
            'activo': item['activo'],
            'categoriaId': item['categoriaId'],
            'categoriaNombre': item['categoriaNombre'],
          });
        }
        return productos;
      }
      return [];
    } catch (e) {
      print("Error buscarProductos: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getProductoById(int id) async {
    final url = Uri.parse('$_baseUrl/productos/$id');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final item = jsonDecode(response.body);
        return {
          'id': item['id'],
          'nombre': item['nombre'],
          'descripcion': item['descripcion'],
          'codigo': item['codigo'],
          'numeroParte': item['numeroParte'],
          'marca': item['marca'],
          'precio': item['precio'] is int
              ? (item['precio'] as int).toDouble()
              : item['precio'],
          'stock': item['stock'],
          'imagenUrl': item['imagenUrl'],
          'activo': item['activo'],
          'categoriaId': item['categoriaId'],
          'categoriaNombre': item['categoriaNombre'],
        };
      }
      return null;
    } catch (e) {
      print("Error getProductoById: $e");
      return null;
    }
  }
}