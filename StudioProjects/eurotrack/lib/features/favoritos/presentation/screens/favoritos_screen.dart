import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/favoritos/data/services/favorito_service.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';

class FavoritosScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const FavoritosScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  final FavoritoService _favoritoService = FavoritoService();
  final CarritoService _carritoService = CarritoService();

  List<Map<String, dynamic>> _favoritos = [];
  bool _isLoading = true;
  int _selectedIndex = 2;
  String? _fotoPerfilBase64;
  int _carritoCount = 0;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
    _fetchFotoPerfil();
    _cargarCarritoCount();
  }

  Future<void> _cargarCarritoCount() async {
    try {
      final items = await _carritoService.getCarrito(widget.userId);
      if (mounted) {
        setState(() => _carritoCount = items.length);
      }
    } catch (e) {
      debugPrint("Error cargando carrito: $e");
    }
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

  Widget _buildProductImage(String? imageUrl, {double size = 60}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.royalBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.image_outlined,
          size: size * 0.4,
          color: AppColors.royalBlue.withOpacity(0.4),
        ),
      );
    }

    Widget imageWidget;
    if (imageUrl.startsWith('http')) {
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(size),
      );
    } else {
      try {
        final cleanBase64 = imageUrl.contains(',')
            ? imageUrl.split(',').last
            : imageUrl;
        imageWidget = Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(size),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder(size);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
        ),
        child: imageWidget,
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.royalBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size * 0.4,
        color: Colors.grey.shade400,
      ),
    );
  }

  // ✅ CORREGIDO: Ahora es Future<void> y usa async/await correctamente
  Future<void> _cargarFavoritos() async {
    setState(() => _isLoading = true);
    try {
      final favoritos = await _favoritoService.getFavoritos(widget.userId);
      debugPrint("📦 Favoritos cargados: ${favoritos.length}");
      if (mounted) {
        setState(() {
          _favoritos = favoritos;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando favoritos: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ✅ CORREGIDO: Eliminar favorito
  Future<void> _eliminarFavorito(int productoId, String nombre) async {
    if (productoId == 0) {
      debugPrint("❌ ID de producto inválido: $productoId");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: ID de producto inválido"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      debugPrint("🗑️ Eliminando favorito - Usuario: ${widget.userId}, Producto: $productoId, Nombre: $nombre");

      // ✅ Usar toggle (POST) en lugar de DELETE
      final success = await _favoritoService.eliminarFavorito(widget.userId, productoId);

      debugPrint("✅ Resultado eliminación: $success");

      // ✅ Recargar la lista después de eliminar
      _cargarFavoritos();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❤️ $nombre eliminado de favoritos"),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No se pudo eliminar el favorito. Verifica la conexión."),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Error al eliminar favorito: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al eliminar: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }



  Future<void> _agregarAlCarrito(Map<String, dynamic> producto) async {
    try {
      await _carritoService.agregar(
        productoId: producto['id'],
        nombre: producto['nombre'],
        precio: (producto['precio'] ?? 0).toDouble(),
        imagenUrl: producto['imagenUrl'],
        marca: producto['marca'] ?? '',
        stock: producto['stock'] ?? 0,
      );
      await _cargarCarritoCount();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Agregado al carrito"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 2) {
      _cargarFavoritos();
      return;
    }

    final routes = ['/home', '/productos', '/favoritos', '/carrito', '/mis-pedidos'];
    if (index < routes.length) {
      final arguments = {
        'id': widget.userId,
        'nombre': widget.nombre,
        'username': widget.username,
        'tipoCliente': widget.tipoCliente,
      };

      if (routes[index] == '/home') {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: arguments,
        );
      } else {
        Navigator.pushNamed(
          context,
          routes[index],
          arguments: arguments,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: HomeAppBar(
        nombre: widget.nombre,
        userId: widget.userId,
        tipoCliente: widget.tipoCliente,
        fotoPerfil: fotoPerfil,
        carritoCount: _carritoCount,
        onPerfilTap: () => Navigator.pushNamed(
          context,
          '/perfil',
          arguments: {
            'id': widget.userId,
            'nombre': widget.nombre,
            'username': widget.username,
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _favoritos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _cargarFavoritos,
        color: AppColors.royalBlue,
        child: isDesktop
            ? _buildDesktopGrid()
            : _buildMobileList(),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ============================================================
  // VISTA MÓVIL (LISTA)
  // ============================================================
  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _favoritos.length,
      itemBuilder: (context, index) {
        final producto = _favoritos[index];
        return _buildMobileCard(producto);
      },
    );
  }

  // ============================================================
  // VISTA ESCRITORIO (GRID)
  // ============================================================
  Widget _buildDesktopGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth >= 1200 ? 5 : screenWidth >= 900 ? 4 : 3;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _favoritos.length,
      itemBuilder: (context, index) {
        final producto = _favoritos[index];
        return _buildDesktopCard(producto);
      },
    );
  }

  // ============================================================
  // TARJETA MÓVIL
  // ============================================================
  Widget _buildMobileCard(Map<String, dynamic> producto) {
    final productName = producto['nombre'] ?? 'Sin nombre';
    final marca = producto['marca'] ?? '';
    final precio = (producto['precio'] ?? 0).toDouble();
    final imageUrl = producto['imagenUrl'];
    final stock = producto['stock'] ?? 0;
    final productoId = producto['id'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildProductImage(imageUrl, size: 60),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.deepNavy,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    marca,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "\$${precio.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (stock <= 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Agotado",
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Stock: $stock",
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    color: stock > 0 ? AppColors.royalBlue : Colors.grey.shade400,
                    size: 22,
                  ),
                  onPressed: stock > 0 ? () => _agregarAlCarrito(producto) : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red, size: 22),
                  onPressed: () => _eliminarFavorito(productoId, productName),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA ESCRITORIO
  // ============================================================
  Widget _buildDesktopCard(Map<String, dynamic> producto) {
    final productName = producto['nombre'] ?? 'Sin nombre';
    final marca = producto['marca'] ?? '';
    final precio = (producto['precio'] ?? 0).toDouble();
    final imageUrl = producto['imagenUrl'];
    final stock = producto['stock'] ?? 0;
    final productoId = producto['id'] ?? 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detalle-producto',
            arguments: productoId,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen centrada
              Center(
                child: _buildProductImage(imageUrl, size: 100),
              ),
              const SizedBox(height: 12),
              // Nombre
              Text(
                productName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.deepNavy,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Marca
              Text(
                marca,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Precio
              Row(
                children: [
                  Text(
                    "\$${precio.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  const Spacer(),
                  if (stock <= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Agotado",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Stock: $stock",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Botones
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: stock > 0 ? () => _agregarAlCarrito(producto) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: stock > 0 ? AppColors.royalBlue : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(
                        stock > 0 ? "Agregar al carrito" : "Sin stock",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red, size: 20),
                      onPressed: () => _eliminarFavorito(productoId, productName),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No tienes favoritos",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Guarda tus productos favoritos aquí",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/productos',
                arguments: {
                  'id': widget.userId,
                  'nombre': widget.nombre,
                  'username': widget.username,
                  'tipoCliente': widget.tipoCliente,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18),
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
                badgeCount: _carritoCount,
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