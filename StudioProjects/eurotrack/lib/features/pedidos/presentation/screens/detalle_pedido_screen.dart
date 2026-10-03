import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/pedidos/data/models/pedido.dart';
import 'package:eurotrack/features/pedidos/data/services/pedido_service.dart';

class DetallePedidoScreen extends StatefulWidget {
  final int pedidoId;

  const DetallePedidoScreen({super.key, required this.pedidoId});

  @override
  State<DetallePedidoScreen> createState() => _DetallePedidoScreenState();
}

class _DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final PedidoService _pedidoService = PedidoService();
  Pedido? _pedido;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() => _isLoading = true);
    try {
      final pedido = await _pedidoService.getPedidoDetalle(widget.pedidoId);
      setState(() {
        _pedido = pedido;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'PENDIENTE': return Colors.orange;
      case 'PAGADO': return Colors.blue;
      case 'ENVIADO': return Colors.purple;
      case 'ENTREGADO': return Colors.green;
      case 'CANCELADO': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getEstadoIcon(String estado) {
    switch (estado) {
      case 'PENDIENTE': return '⏳';
      case 'PAGADO': return '💰';
      case 'ENVIADO': return '🚚';
      case 'ENTREGADO': return '✅';
      case 'CANCELADO': return '❌';
      default: return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: Text(
          "Pedido #${widget.pedidoId}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _pedido == null
          ? _buildErrorState()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEstadoCard(),
            const SizedBox(height: 16),
            _buildInfoEntrega(),
            const SizedBox(height: 16),
            _buildProductosList(),
            const SizedBox(height: 16),
            _buildResumenPago(),
            if (_pedido!.estado == 'PENDIENTE')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildCancelarButton(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("No se pudo cargar el pedido"),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _cargarDetalle,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getEstadoColor(_pedido!.estado).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _getEstadoIcon(_pedido!.estado),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Estado del pedido",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  Text(
                    _pedido!.estado,
                    style: TextStyle(
                      color: _getEstadoColor(_pedido!.estado),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatearFecha(_pedido!.fecha),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoEntrega() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información de entrega",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _pedido!.direccionEntrega.isNotEmpty
                        ? _pedido!.direccionEntrega
                        : "No especificada",
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.payment, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _pedido!.metodoPago.isNotEmpty ? _pedido!.metodoPago : "No especificado",
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosList() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Productos",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const Divider(),
            ..._pedido!.detalles.map((detalle) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.settings, size: 20, color: AppColors.royalBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detalle.productoNombre,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "${detalle.cantidad} x \$${detalle.precioUnitario.toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "\$${detalle.subtotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenPago() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de pago",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("\$${_pedido!.total.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Envío"),
                const Text("Incluido"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${_pedido!.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelarButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _cancelarPedido(),
        child: const Text(
          "Cancelar pedido",
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _cancelarPedido() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Cancelar pedido"),
        content: const Text("¿Estás seguro de que quieres cancelar este pedido?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _pedidoService.cancelarPedido(widget.pedidoId);
              if (success) {
                _cargarDetalle();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pedido cancelado")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("No se pudo cancelar el pedido"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Sí, cancelar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return fecha;
    }
  }
}