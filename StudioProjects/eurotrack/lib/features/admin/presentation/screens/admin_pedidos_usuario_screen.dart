import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';

class AdminPedidosUsuarioScreen extends StatefulWidget {
  final int userId;
  final String userNombre;

  const AdminPedidosUsuarioScreen({
    super.key,
    required this.userId,
    required this.userNombre,
  });

  @override
  State<AdminPedidosUsuarioScreen> createState() => _AdminPedidosUsuarioScreenState();
}

class _AdminPedidosUsuarioScreenState extends State<AdminPedidosUsuarioScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _pedidos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    final pedidos = await _adminService.getPedidosByUsuario(widget.userId);
    setState(() {
      _pedidos = pedidos;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _pedidosFiltrados {
    if (_searchQuery.isEmpty) return _pedidos;
    return _pedidos.where((p) {
      final id = p['id']?.toString() ?? '';
      final estado = p['estado']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return id.contains(query) || estado.contains(query);
    }).toList();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text(
            "Pedidos de ${widget.userNombre}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarPedidos,
              tooltip: 'Recargar',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar pedidos...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
          ),
        ),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando pedidos...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_pedidosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _pedidosFiltrados.length,
      itemBuilder: (context, index) {
        final pedido = _pedidosFiltrados[index];
        return _buildPedidoCardMobile(pedido);
      },
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando pedidos...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_pedidosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: _pedidosFiltrados.map((pedido) {
          return SizedBox(
            width: 380,
            child: _buildPedidoCardDesktop(pedido),
          );
        }).toList(),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No hay pedidos registrados"
                : "No se encontraron pedidos",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "Este usuario no ha realizado ningún pedido"
                : "Prueba con otra búsqueda",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== CARD PEDIDO MÓVIL ====================
  Widget _buildPedidoCardMobile(Map<String, dynamic> pedido) {
    final estado = pedido['estado'] ?? 'PENDIENTE';
    final color = _getEstadoColor(estado);

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
                Text(
                  "Pedido #${pedido['id']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getEstadoIcon(estado)),
                      const SizedBox(width: 4),
                      Text(
                        estado,
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text("Fecha: ${_formatearFecha(pedido['fecha'])}"),
            Text(
              "Total: \$${(pedido['total'] ?? 0).toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.royalBlue),
            ),
            const SizedBox(height: 8),
            Text(
              "Dirección: ${pedido['direccionEntrega'] ?? 'No especificada'}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/detalle-pedido',
                  arguments: pedido['id'],
                );
              },
              child: const Text("Ver detalles", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CARD PEDIDO ESCRITORIO ====================
  Widget _buildPedidoCardDesktop(Map<String, dynamic> pedido) {
    final estado = pedido['estado'] ?? 'PENDIENTE';
    final color = _getEstadoColor(estado);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pedido #${pedido['id']}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.deepNavy,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getEstadoIcon(estado)),
                      const SizedBox(width: 6),
                      Text(
                        estado,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Información en grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 8,
              childAspectRatio: 4,
              children: [
                _buildInfoItem(Icons.calendar_today, "Fecha: ${_formatearFecha(pedido['fecha'])}"),
                _buildInfoItem(Icons.attach_money, "Total: \$${(pedido['total'] ?? 0).toStringAsFixed(2)}", isBold: true),
                _buildInfoItem(Icons.location_on, "Dirección: ${pedido['direccionEntrega'] ?? 'No especificada'}"),
              ],
            ),
            const SizedBox(height: 12),
            // Botón
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/detalle-pedido',
                    arguments: pedido['id'],
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text("Ver detalles"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                color: isBold ? AppColors.royalBlue : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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