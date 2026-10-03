import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';
import 'dart:convert';

class AdminPedidosScreen extends StatefulWidget {
  const AdminPedidosScreen({super.key});

  @override
  State<AdminPedidosScreen> createState() => _AdminPedidosScreenState();
}

class _AdminPedidosScreenState extends State<AdminPedidosScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _pedidos = [];
  bool _isLoading = true;
  bool _isUpdating = false;

  final List<String> _estados = ["PENDIENTE", "PAGADO", "CANCELADO"];

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final pedidos = await _adminService.getPedidos();
    final usuarios = await _adminService.getUsuarios();

    final List<Map<String, dynamic>> pedidosUnidos = pedidos.map((pedido) {
      final usuario = usuarios.firstWhere((u) => u['id'] == pedido['usuarioId'], orElse: () => {'nombre': 'Usuario desconocido'});
      return { ...pedido, 'usuarioNombre': usuario['nombre'] ?? 'Sin nombre' };
    }).toList();

    if (mounted) setState(() { _pedidos = pedidosUnidos; _isLoading = false; });
  }

  // --- LOGICA DE DETALLE ESTILO USUARIO ---
  Future<void> _verDetallePedido(int pedidoId) async {
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()));

    final data = await _adminService.getPedidoDetalle(pedidoId);
    if (!mounted) return;
    Navigator.pop(context);

    final detalles = data['detalles'] as List? ?? [];
    // Asegúrate de que el backend envíe el objeto 'pedido' con la info general
    final pedidoInfo = data['pedido'] ?? {};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Fondo transparente para el modal
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Detalle #$pedidoId", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: detalles.length,
                // En tu ListView.builder, dentro de _verDetallePedido:
                itemBuilder: (context, index) {
                  final item = detalles[index];

                  final nombre = item['productoNombre'] ?? 'Producto sin nombre';
                  final codigo = item['productoCodigo'] ?? 'N/A';
                  final base64Image = item['productoImagenUrl']; // Tu cadena base64 larga

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          // Lógica para Base64:
                          child: (base64Image != null && base64Image.toString().length > 100)
                              ? Image.memory(base64Decode(base64Image.toString()), width: 60, height: 60, fit: BoxFit.cover)
                              : Container(width: 60, height: 60, color: Colors.blue[50], child: const Icon(Icons.inventory_2, color: AppColors.royalBlue)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 2),
                              // Como no hay marca, ocultamos la línea o ponemos un texto fijo
                               Text("Cód: $codigo", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("x${item['cantidad'] ?? 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text("\$${(item['subtotal'] ?? 0.0).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Pie de modal con el total
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Total del pedido:", style: TextStyle(fontSize: 16)),
                  Text("\$${(pedidoInfo['total'] ?? 0.0).toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.royalBlue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _actualizarEstado(int pedidoId, String nuevoEstado) async {
    setState(() => _isUpdating = true);
    final success = await _adminService.actualizarEstadoPedido(pedidoId, nuevoEstado);
    if (success) {
      await _cargarPedidos();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Estado: $nuevoEstado")));
    }
    setState(() => _isUpdating = false);
  }

  // --- ESTILOS COMPARTIDOS ---
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'PENDIENTE': return Colors.orange;
      case 'PAGADO': return Colors.blue;
     // case 'ENTREGADO': return Colors.green;
      case 'CANCELADO': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getEstadoIcon(String estado) {
    switch (estado) {
      case 'PENDIENTE': return '⏳';
      case 'PAGADO': return '💰';
     // case 'ENTREGADO': return '✅';
      case 'CANCELADO': return '❌';
      default: return '📦';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text("Gestión de Pedidos", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _cargarPedidos)],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _pedidos.length,
        itemBuilder: (context, index) => _buildPedidoCard(_pedidos[index]),
      ),
    );
  }

  Widget _buildPedidoCard(Map<String, dynamic> pedido) {
    String currentEstado = _estados.contains(pedido['estado']) ? pedido['estado'] : "PENDIENTE";
    bool esEditable = (currentEstado == "PENDIENTE");

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pedido #${pedido['id']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _getEstadoColor(currentEstado).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [Text(_getEstadoIcon(currentEstado)), const SizedBox(width: 4), Text(currentEstado, style: TextStyle(color: _getEstadoColor(currentEstado), fontSize: 12, fontWeight: FontWeight.bold))]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Cliente: ${pedido['usuarioNombre']}", style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Fecha: ${pedido['fecha']}"),
            Text("Total: \$${(pedido['total'] ?? 0).toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.royalBlue)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(onPressed: () => _verDetallePedido(pedido['id']), icon: const Icon(Icons.list_alt), label: const Text("Detalles")),
                esEditable
                    ? Container(padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                    value: currentEstado,
                    onChanged: _isUpdating ? null : (n) => _actualizarEstado(pedido['id'], n!),
                    items: _estados.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                  )),
                )
                    : const Text("Finalizado", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}