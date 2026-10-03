import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';
import 'package:eurotrack/features/carrito/data/models/carrito_item.dart';

class CarritoScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const CarritoScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  final CarritoService _carritoService = CarritoService();
  List<CarritoItem> _items = [];
  bool _isLoading = true;
  int _selectedIndex = 3; // Carrito está en índice 3
  String? _fotoPerfilBase64;

  @override
  void initState() {
    super.initState();
    _cargarCarrito();
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

  // --- LÓGICA DE IMAGEN UNIFICADA ---
  Widget _buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Center(child: Icon(Icons.shopping_bag, size: 30, color: AppColors.royalBlue));
    }

    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
      );
    } else {
      try {
        final cleanBase64 = imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
        imageWidget = Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 30),
        );
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image, size: 30);
      }
    }
    return SizedBox.expand(child: imageWidget);
  }

  Future<void> _cargarCarrito() async {
    setState(() => _isLoading = true);
    await _carritoService.loadCarrito();
    setState(() {
      _items = _carritoService.items;
      _isLoading = false;
    });
  }

  Future<void> _actualizarCantidad(int productoId, int nuevaCantidad) async {
    try {
      await _carritoService.actualizarCantidad(productoId, nuevaCantidad);
      _cargarCarrito();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _eliminarProducto(int productoId) async {
    await _carritoService.eliminar(productoId);
    _cargarCarrito();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Producto eliminado del carrito")),
    );
  }

  Future<void> _vaciarCarrito() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Vaciar carrito"),
        content: const Text("¿Estás seguro de que quieres vaciar el carrito?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _carritoService.vaciar();
              _cargarCarrito();
            },
            child: const Text("Vaciar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _realizarPedido() {
    if (_items.isEmpty) return;
    final itemsMap = _items.map((item) => {
      'productoId': item.productoId,
      'nombre': item.nombre,
      'precio': item.precio,
      'cantidad': item.cantidad,
      'marca': item.marca,
      'subtotal': item.subtotal,
    }).toList();

    Navigator.pushNamed(context, '/checkout', arguments: {
      'userId': widget.userId,
      'items': itemsMap,
      'total': _carritoService.total,
    }).then((_) => _cargarCarrito());
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 3) {
      _cargarCarrito();
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
        carritoCount: _items.length,
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
          : _items.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              itemBuilder: (context, index) => _buildCarritoItem(_items[index]),
            ),
          ),
          _buildResumen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCarritoItem(CarritoItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildImage(item.imagenUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    item.marca,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    "\$${item.precio.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 28),
                      color: Colors.red,
                      onPressed: item.cantidad > 1
                          ? () => _actualizarCantidad(item.productoId, item.cantidad - 1)
                          : null,
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        item.cantidad.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 28),
                      color: Colors.green,
                      onPressed: item.cantidad < item.stock
                          ? () => _actualizarCantidad(item.productoId, item.cantidad + 1)
                          : null,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _eliminarProducto(item.productoId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "\$${_carritoService.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Seguir comprando"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepNavy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _realizarPedido,
                  child: const Text(
                    "Proceder al pago",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            "Tu carrito está vacío",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            "¡Explora nuestros productos y agrega lo que necesites!",
            style: TextStyle(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text("Ver productos"),
          ),
        ],
      ),
    );
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
              _buildNavItemWithBadge(
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart_rounded,
                label: 'Carrito',
                index: 3,
                badgeCount: _items.length,
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

  Widget _buildNavItemWithBadge({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int badgeCount,
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
            Stack(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? AppColors.royalBlue : Colors.grey[500],
                  size: 24,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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