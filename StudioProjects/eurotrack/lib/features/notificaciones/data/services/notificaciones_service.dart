// lib/features/notificaciones/data/services/notificaciones_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';
import 'package:flutter/foundation.dart';

class NotificacionesService {
  final String _baseUrl = "${ApiConfig.domain}/api/notificaciones";

  // ✅ Obtener notificaciones de un usuario
  Future<List<Map<String, dynamic>>> getNotificaciones(int userId) async {
    final url = Uri.parse('$_baseUrl/usuario/$userId');
    try {
      final response = await http.get(url);
      debugPrint('📡 GET Notificaciones - Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        debugPrint('📦 Notificaciones recibidas: ${data.length}');
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getNotificaciones: $e');
      return [];
    }
  }

  // ✅ Marcar una notificación como leída
  Future<void> marcarComoLeido(int notificacionId) async {
    final url = Uri.parse('$_baseUrl/$notificacionId/leer');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode != 200) {
        throw Exception('Error al marcar como leído');
      }
      debugPrint('✅ Notificación $notificacionId marcada como leída');
    } catch (e) {
      debugPrint('❌ Error marcando como leído: $e');
      rethrow;
    }
  }

  // ✅ Eliminar una notificación
  Future<void> eliminarNotificacion(int notificacionId) async {
    final url = Uri.parse('$_baseUrl/$notificacionId');
    try {
      final response = await http.delete(url);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Error al eliminar notificación');
      }
      debugPrint('🗑️ Notificación $notificacionId eliminada');
    } catch (e) {
      debugPrint('❌ Error eliminando notificación: $e');
      rethrow;
    }
  }

  // ✅ Crear una notificación
  Future<void> crearNotificacion(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      debugPrint('📡 POST Notificación - Status: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al crear notificación: ${response.body}');
      }
      debugPrint('✅ Notificación creada: ${data['titulo']}');
    } catch (e) {
      debugPrint('❌ Error crearNotificacion: $e');
      rethrow;
    }
  }

  // ✅ Marcar todas las notificaciones como leídas
  Future<void> marcarTodasComoLeidas(int userId) async {
    final url = Uri.parse('$_baseUrl/usuario/$userId/leer-todas');
    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode != 200) {
        throw Exception('Error al marcar todas como leídas');
      }
      debugPrint('✅ Todas las notificaciones marcadas como leídas');
    } catch (e) {
      debugPrint('❌ Error marcarTodasComoLeidas: $e');
      rethrow;
    }
  }
}