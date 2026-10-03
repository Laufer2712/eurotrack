// lib/features/pedidos/data/services/pedido_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/features/pedidos/data/models/pedido.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:flutter/foundation.dart';

class PedidoService {
  final String _baseUrl = "${ApiConfig.domain}/api/pedidos";

  // ✅ Crear un nuevo pedido (con notificaciones automáticas)
  Future<Map<String, dynamic>> crearPedido({
    required int usuarioId,
    required String direccionEntrega,
    required String metodoPago,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse('$_baseUrl/crear');

    final body = {
      "usuarioId": usuarioId,
      "direccionEntrega": direccionEntrega,
      "metodoPago": metodoPago,
      "items": items,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("📡 Crear pedido - Status: ${response.statusCode}");
      debugPrint("📄 Respuesta: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al crear pedido: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // ✅ Obtener pedidos de un usuario
  Future<List<Pedido>> getPedidosByUsuario(int usuarioId) async {
    final url = Uri.parse('$_baseUrl/usuario/$usuarioId');

    try {
      final response = await http.get(url);
      debugPrint("📡 Get pedidos - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        debugPrint("✅ Pedidos encontrados: ${data.length}");
        return data.map((json) => Pedido.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Error getPedidosByUsuario: $e");
      return [];
    }
  }

  // ✅ Obtener detalle de un pedido específico
  Future<Pedido?> getPedidoDetalle(int pedidoId) async {
    final url = Uri.parse('$_baseUrl/$pedidoId');

    try {
      final response = await http.get(url);
      debugPrint("📡 Get pedido detalle - Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Pedido.fromJsonWithDetalles(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error getPedidoDetalle: $e");
      return null;
    }
  }

  // ✅ Cancelar un pedido
  Future<bool> cancelarPedido(int pedidoId) async {
    final url = Uri.parse('$_baseUrl/cancelar/$pedidoId');

    try {
      final response = await http.put(url);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error cancelarPedido: $e");
      return false;
    }
  }

  // ✅ Actualizar estado del pedido (desde admin)
  Future<bool> actualizarEstadoPedido(int pedidoId, String nuevoEstado) async {
    final url = Uri.parse('$_baseUrl/$pedidoId/estado?estado=$nuevoEstado');

    try {
      final response = await http.put(url);
      debugPrint("📡 Actualizar estado - Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error actualizarEstadoPedido: $e");
      return false;
    }
  }
}