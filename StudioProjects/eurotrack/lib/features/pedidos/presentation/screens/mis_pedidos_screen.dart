import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/pedidos/data/models/pedido.dart';
import 'package:eurotrack/features/pedidos/data/services/pedido_service.dart';

class MisPedidosScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const MisPedidosScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<MisPedidosScreen> createState() => _MisPedidosScreenState();
}

class _MisPedidosScreenState extends State<MisPedidosScreen> {
  final PedidoService _pedidoService = PedidoService();
  List<Pedido> _pedidos = [];
  bool _isLoading = true;
  int _selectedIndex = 4;
  String? _fotoPerfilBase64;

  @override
  void initState() {
    super.initState();
    _cargarPedidos();
    _fetchFotoPerfil();
  }

  Future<void> _fetchFotoPerfil() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.authEndpoint}/profile/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() => _fotoPerfilBase64 = data['fotoPerfil']);
        }
      }
    } catch (e) {
      debugPrint("Error cargando foto: $e");
    }
  }

  Uint8List? _decodificarBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanString);
    } catch (e) {
      return null;
    }
  }

  Future<void> _cargarPedidos() async {
    setState(() => _isLoading = true);
    try {
      final pedidos = await _pedidoService.getPedidosByUsuario(widget.userId);
      setState(() {
        _pedidos = pedidos;
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

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 4) {
      _cargarPedidos();
      return;
    }

    final routes = ['/home', '/productos', '/favoritos', '/carrito', '/mis-pedidos'];
    if (index < routes.length) {
      if (routes[index] == '/home') {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: {
            'id': widget.userId,
            'usuario': widget.nombre,
            'username': widget.username,
            'tipoCliente': widget.tipoCliente,
          },
        );
      } else {
        Navigator.pushNamed(
          context,
          routes[index],
          arguments: {
            'id': widget.userId,
            'usuario': widget.nombre,
            'username': widget.username,
            'tipoCliente': widget.tipoCliente,
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: HomeAppBar(
        nombre: widget.nombre,
        userId: widget.userId,
        tipoCliente: widget.tipoCliente,
        fotoPerfil: fotoPerfil,
        carritoCount: 0,
        onPerfilTap: () => Navigator.pushNamed(
          context,
          '/perfil',
          arguments: {
            'id': widget.userId,
            'usuario': widget.nombre,
            'username': widget.username,
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _pedidos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _cargarPedidos,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _pedidos.length,
          itemBuilder: (context, index) {
            final pedido = _pedidos[index];
            return _buildPedidoCard(pedido);
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No tienes pedidos aún",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/productos',
                arguments: {
                  'id': widget.userId,
                  'usuario': widget.nombre,
                  'username': widget.username,
                  'tipoCliente': widget.tipoCliente,
                },
              );
            },
            child: const Text("Ir a comprar"),
          ),
        ],
      ),
    );
  }

  Widget _buildPedidoCard(Pedido pedido) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detalle-pedido',
            arguments: pedido.id,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pedido #${pedido.id}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.deepNavy,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getEstadoColor(pedido.estado).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getEstadoIcon(pedido.estado),
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pedido.estado,
                          style: TextStyle(
                            color: _getEstadoColor(pedido.estado),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Fecha: ${_formatearFecha(pedido.fecha)}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                "Total: \$${pedido.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: pedido.estado == 'PENDIENTE'
                        ? () => _cancelarPedido(pedido.id)
                        : null,
                    child: const Text("Cancelar pedido"),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/detalle-pedido',
                        arguments: pedido.id,
                      );
                    },
                    child: const Text("Ver detalles"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cancelarPedido(int pedidoId) async {
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
              final success = await _pedidoService.cancelarPedido(pedidoId);
              if (success) {
                _cargarPedidos();
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

  // ============================================================
  // BOTTOM NAVIGATION BAR
  // ============================================================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Inicio',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.inventory_outlined,
                selectedIcon: Icons.inventory_rounded,
                label: 'Productos',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_border,
                selectedIcon: Icons.favorite_rounded,
                label: 'Favoritos',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart_rounded,
                label: 'Carrito',
                index: 3,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                label: 'Pedidos',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? AppColors.royalBlue : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppColors.royalBlue : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}