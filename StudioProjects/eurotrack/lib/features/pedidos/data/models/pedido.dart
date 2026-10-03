class DetallePedidoModel {
  final int id;
  final int productoId;
  final String productoNombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetallePedidoModel({
    required this.id,
    required this.productoId,
    required this.productoNombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  // 🔥 MODIFICADO: Ahora los datos vienen planos en el DTO
  factory DetallePedidoModel.fromJson(Map<String, dynamic> json) {
    return DetallePedidoModel(
      id: json['id'],
      productoId: json['productoId'],        // ← Ahora viene directo
      productoNombre: json['productoNombre'], // ← Ahora viene directo
      cantidad: json['cantidad'],
      precioUnitario: json['precioUnitario'] is int
          ? (json['precioUnitario'] as int).toDouble()
          : json['precioUnitario'],
      subtotal: json['subtotal'] is int
          ? (json['subtotal'] as int).toDouble()
          : json['subtotal'],
    );
  }
}

class Pedido {
  final int id;
  final String fecha;
  final String estado;
  final double total;
  final String direccionEntrega;
  final String metodoPago;
  final int usuarioId;           // ← NUEVO
  final String usuarioNombre;    // ← NUEVO
  final List<DetallePedidoModel> detalles;

  Pedido({
    required this.id,
    required this.fecha,
    required this.estado,
    required this.total,
    required this.direccionEntrega,
    required this.metodoPago,
    required this.usuarioId,
    required this.usuarioNombre,
    required this.detalles,
  });

  // 🔥 MODIFICADO: Para lista de pedidos (sin detalles)
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      fecha: json['fecha'],
      estado: json['estado'],
      total: json['total'] is int
          ? (json['total'] as int).toDouble()
          : json['total'],
      direccionEntrega: json['direccionEntrega'] ?? '',
      metodoPago: json['metodoPago'] ?? '',
      usuarioId: json['usuarioId'] ?? 0,
      usuarioNombre: json['usuarioNombre'] ?? '',
      detalles: [],
    );
  }

  // 🔥 MODIFICADO: Para detalle de pedido (con detalles)
  factory Pedido.fromJsonWithDetalles(Map<String, dynamic> json) {
    // El backend devuelve { "pedido": {...}, "detalles": [...] }
    final pedidoJson = json['pedido'];
    final detallesList = json['detalles'] as List? ?? [];

    return Pedido(
      id: pedidoJson['id'],
      fecha: pedidoJson['fecha'],
      estado: pedidoJson['estado'],
      total: pedidoJson['total'] is int
          ? (pedidoJson['total'] as int).toDouble()
          : pedidoJson['total'],
      direccionEntrega: pedidoJson['direccionEntrega'] ?? '',
      metodoPago: pedidoJson['metodoPago'] ?? '',
      usuarioId: pedidoJson['usuarioId'] ?? 0,
      usuarioNombre: pedidoJson['usuarioNombre'] ?? '',
      detalles: detallesList.map((d) => DetallePedidoModel.fromJson(d)).toList(),
    );
  }
}