import 'package:eurotrack/features/auth/data/services/auth_service.dart';

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  final AuthService _authService = AuthService();

  /// Registra un evento en el servidor
  Future<void> logEvent({
    required String accion,
    required String descripcion,
    String? tablaAfectada,
    int? registroId,
    String? datosAnteriores,
    String? datosNuevos,
    bool exitoso = true,
    String? mensajeError,
  }) async {
    try {
      // Obtener usuario actual
      final userData = await _authService.getUserData();
      final usuario = userData?['email'] ?? 'ANONIMO';

      // TODO: Llamar al endpoint de auditoría
      // Por ahora solo imprimimos en consola
      print('''
      📝 LOG:
      Usuario: $usuario
      Acción: $accion
      Descripción: $descripcion
      Tabla: ${tablaAfectada ?? 'N/A'}
      Registro: ${registroId ?? 'N/A'}
      Exitoso: $exitoso
      ${mensajeError != null ? 'Error: $mensajeError' : ''}
      ''');
    } catch (e) {
      print('❌ Error al registrar log: $e');
    }
  }

  /// Eventos de autenticación
  Future<void> loginExitoso(String usuario) async {
    await logEvent(
      accion: 'LOGIN_EXITOSO',
      descripcion: 'Inicio de sesión exitoso: $usuario',
    );
  }

  Future<void> loginFallido(String usuario, String motivo) async {
    await logEvent(
      accion: 'LOGIN_FALLIDO',
      descripcion: 'Intento de login fallido: $usuario - $motivo',
      exitoso: false,
      mensajeError: motivo,
    );
  }

  Future<void> registroExitoso(String usuario) async {
    await logEvent(
      accion: 'REGISTRO',
      descripcion: 'Nuevo usuario registrado: $usuario',
    );
  }

  /// Eventos de productos
  Future<void> productoCreado(Map<String, dynamic> producto, String usuario) async {
    await logEvent(
      accion: 'CREATE_PRODUCTO',
      descripcion: 'Producto creado: ${producto['nombre']}',
      tablaAfectada: 'productos',
      registroId: producto['id'],
      datosNuevos: producto.toString(),
    );
  }

  Future<void> productoActualizado(Map<String, dynamic> producto, String usuario) async {
    await logEvent(
      accion: 'UPDATE_PRODUCTO',
      descripcion: 'Producto actualizado: ${producto['nombre']} (ID: ${producto['id']})',
      tablaAfectada: 'productos',
      registroId: producto['id'],
      datosNuevos: producto.toString(),
    );
  }

  Future<void> productoEliminado(int id, String nombre, String usuario) async {
    await logEvent(
      accion: 'DELETE_PRODUCTO',
      descripcion: 'Producto eliminado: $nombre (ID: $id)',
      tablaAfectada: 'productos',
      registroId: id,
    );
  }

  /// Eventos de categorías
  Future<void> categoriaCreada(Map<String, dynamic> categoria, String usuario) async {
    await logEvent(
      accion: 'CREATE_CATEGORIA',
      descripcion: 'Categoría creada: ${categoria['nombre']}',
      tablaAfectada: 'categorias',
      registroId: categoria['id'],
    );
  }

  Future<void> categoriaActualizada(Map<String, dynamic> categoria, String usuario) async {
    await logEvent(
      accion: 'UPDATE_CATEGORIA',
      descripcion: 'Categoría actualizada: ${categoria['nombre']} (ID: ${categoria['id']})',
      tablaAfectada: 'categorias',
      registroId: categoria['id'],
    );
  }

  Future<void> categoriaEliminada(int id, String nombre, String usuario) async {
    await logEvent(
      accion: 'DELETE_CATEGORIA',
      descripcion: 'Categoría eliminada: $nombre (ID: $id)',
      tablaAfectada: 'categorias',
      registroId: id,
    );
  }
}