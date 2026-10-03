import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eurotrack/features/carrito/data/models/carrito_item.dart';

class CarritoService {
  static const String _carritoKey = 'carrito_items';
  final List<CarritoItem> _items = [];

  List<CarritoItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  // ========== MÉTODOS EXISTENTES ==========

  // Cargar carrito desde SharedPreferences
  Future<void> loadCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final String? carritoString = prefs.getString(_carritoKey);
    if (carritoString != null && carritoString.isNotEmpty) {
      final List<dynamic> decoded = jsonDecode(carritoString);
      _items.clear();
      _items.addAll(decoded.map((item) => CarritoItem.fromJson(item)));
    }
  }

  // Guardar carrito en SharedPreferences
  Future<void> _saveCarrito() async {
    final prefs = await SharedPreferences.getInstance();
    final String carritoString = jsonEncode(_items.map((item) => item.toJson()).toList());
    await prefs.setString(_carritoKey, carritoString);
  }

  // ✅ NUEVO: Obtener el carrito como lista de Map (para usar en otras pantallas)
  Future<List<Map<String, dynamic>>> obtenerCarrito(int userId) async {
    await loadCarrito();
    return _items.map((item) => {
      'productoId': item.productoId,
      'nombre': item.nombre,
      'precio': item.precio,
      'cantidad': item.cantidad,
      'imagenUrl': item.imagenUrl,
      'marca': item.marca,
      'subtotal': item.subtotal,
    }).toList();
  }

  // ✅ NUEVO: Obtener el carrito como lista de CarritoItem
  Future<List<CarritoItem>> getCarritoItems() async {
    await loadCarrito();
    return List.from(_items);
  }

  // ✅ NUEVO: Obtener el carrito como lista de Map (alias)
  Future<List<Map<String, dynamic>>> getCarrito(int userId) async {
    return obtenerCarrito(userId);
  }

  // Agregar producto al carrito
  Future<void> agregar({
    required int productoId,
    required String nombre,
    required double precio,
    String? imagenUrl,
    required String marca,
    required int stock,
  }) async {
    final existingIndex = _items.indexWhere((item) => item.productoId == productoId);

    if (existingIndex != -1) {
      // Verificar stock disponible
      if (_items[existingIndex].cantidad + 1 > stock) {
        throw Exception('Stock insuficiente. Solo hay $stock unidades disponibles.');
      }
      _items[existingIndex].cantidad++;
    } else {
      if (1 > stock) {
        throw Exception('Stock insuficiente');
      }
      _items.add(CarritoItem(
        productoId: productoId,
        nombre: nombre,
        precio: precio,
        imagenUrl: imagenUrl,
        marca: marca,
        stock: stock,
        cantidad: 1,
      ));
    }
    await _saveCarrito();
  }

  // Actualizar cantidad de un producto
  Future<void> actualizarCantidad(int productoId, int nuevaCantidad) async {
    final index = _items.indexWhere((item) => item.productoId == productoId);
    if (index != -1) {
      if (nuevaCantidad <= 0) {
        _items.removeAt(index);
      } else {
        // Verificar stock
        if (nuevaCantidad > _items[index].stock) {
          throw Exception('Stock insuficiente. Máximo ${_items[index].stock} unidades.');
        }
        _items[index].cantidad = nuevaCantidad;
      }
      await _saveCarrito();
    }
  }

  // Eliminar producto del carrito
  Future<void> eliminar(int productoId) async {
    _items.removeWhere((item) => item.productoId == productoId);
    await _saveCarrito();
  }

  // Vaciar carrito
  Future<void> vaciar() async {
    _items.clear();
    await _saveCarrito();
  }

  // Verificar si un producto está en el carrito
  bool estaEnCarrito(int productoId) {
    return _items.any((item) => item.productoId == productoId);
  }

  // Obtener cantidad de un producto en el carrito
  int obtenerCantidad(int productoId) {
    final item = _items.firstWhere(
          (item) => item.productoId == productoId,
      orElse: () => CarritoItem(productoId: -1, nombre: '', precio: 0, marca: '', stock: 0),
    );
    return item.productoId != -1 ? item.cantidad : 0;
  }
}