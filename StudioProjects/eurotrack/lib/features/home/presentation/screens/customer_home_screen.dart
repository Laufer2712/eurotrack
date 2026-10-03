// lib/features/home/presentation/screens/customer_home_screen.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/category_card.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/home/presentation/widgets/product_card.dart';
import 'package:eurotrack/features/productos/data/services/producto_service.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const CustomerHomeScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> with SingleTickerProviderStateMixin {
  final ProductoService _productoService = ProductoService();
  final CarritoService _carritoService = CarritoService();

  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _productosRecientes = [];
  String? _fotoPerfilBase64;
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _carritoCount = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();

    _cargarDatosIniciales();
    _cargarCarritoCount();
  }

  Uint8List? _decodificarBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanString);
    } catch (e) {
      debugPrint("Error decodificando: $e");
      return null;
    }
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

  Future<void> _cargarDatosIniciales() async {
    await Future.wait([_cargarDatos(), _fetchFotoPerfil()]);
  }

  Future<void> _fetchFotoPerfil() async {
    try {
      final response = await http.get(
          Uri.parse('${ApiConfig.authEndpoint}/profile/${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _fotoPerfilBase64 = data['fotoPerfil']);
      }
    } catch (e) {
      debugPrint("Error cargando foto: $e");
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final categorias = await _productoService.getCategorias();
      final catalogo = await _productoService.getCatalogo();
      if (mounted) {
        setState(() {
          _categorias = categorias;
          _productosRecientes = catalogo.take(6).toList();
          _isLoading = false;
        });
        _animationController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    final routes = ['/home', '/productos', '/favoritos', '/carrito', '/mis-pedidos'];

    if (routes[index] == '/home') {
      _cargarDatosIniciales();
      return;
    }

    final arguments = {
      'id': widget.userId,
      'nombre': widget.nombre,
      'username': widget.username,
      'tipoCliente': widget.tipoCliente,
    };

    Navigator.pushNamed(
      context,
      routes[index],
      arguments: arguments,
    );
  }

  String _getSaludo() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 18) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _getTipoClienteLabel() {
    switch (widget.tipoCliente) {
      case 'JURIDICO':
        return 'Empresa';
      case 'TRANSPORTISTA':
        return 'Transportista';
      default:
        return 'Cliente';
    }
  }

  IconData _getTipoIcon() {
    switch (widget.tipoCliente) {
      case 'JURIDICO':
        return Icons.business_center;
      case 'TRANSPORTISTA':
        return Icons.local_shipping;
      default:
        return Icons.person_outline;
    }
  }

  Color _getTipoColor() {
    switch (widget.tipoCliente) {
      case 'JURIDICO':
        return Colors.purple;
      case 'TRANSPORTISTA':
        return Colors.orange;
      default:
        return AppColors.royalBlue;
    }
  }

  void _navigateToCategorias() {
    // 👇 Pasar solo el userId como int
    Navigator.pushNamed(
      context,
      '/categorias',
      arguments: widget.userId,
    );
  }

  void _navigateToProductosPorCategoria(int categoriaId, String categoriaNombre) {
    Navigator.pushNamed(
      context,
      '/productos-por-categoria',
      arguments: {
        'categoriaId': categoriaId,
        'categoriaNombre': categoriaNombre,
        'userId': widget.userId,
        'nombre': widget.nombre,
        'username': widget.username,
        'tipoCliente': widget.tipoCliente,
      },
    );
  }

  void _navigateToProductos() {
    Navigator.pushNamed(
      context,
      '/productos',
      arguments: {
        'id': widget.userId,
        'nombre': widget.nombre,
        'username': widget.username,
        'tipoCliente': widget.tipoCliente,
      },
    );
  }

  void _navigateToDetalleProducto(int productoId) {
    Navigator.pushNamed(
      context,
      '/detalle-producto',
      arguments: productoId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _cargarDatosIniciales,
        color: AppColors.royalBlue,
        child: Column(
          children: [
            HomeAppBar(
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
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
                  : FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildWelcomeBanner(),
                      const SizedBox(height: 20),
                      isDesktop ? _buildDesktopCategoriasSection() : _buildCategoriasSection(),
                      const SizedBox(height: 24),
                      isDesktop ? _buildDesktopProductosSection() : _buildProductosSection(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  // ==================== CATEGORÍAS SECTION (MÓVIL) ====================
  Widget _buildCategoriasSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categorías",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: _navigateToCategorias,
                child: const Text(
                  "Ver todo",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _categorias.length,
            itemBuilder: (context, i) {
              final categoria = _categorias[i];
              final imagenUrl = categoria['imagenUrl'] ?? categoria['imagen_url'];

              return CategoryCard(
                nombre: categoria['nombre'] ?? 'Categoría',
                icon: Icons.category,
                imageUrl: imagenUrl,
                onTap: () => _navigateToProductosPorCategoria(
                  categoria['id'],
                  categoria['nombre'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== CATEGORÍAS SECTION (ESCRITORIO) ====================
  Widget _buildDesktopCategoriasSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Categorías",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: _navigateToCategorias,
                child: const Text(
                  "Ver todo",
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _categorias.length,
            itemBuilder: (context, i) {
              final categoria = _categorias[i];
              final imagenUrl = categoria['imagenUrl'] ?? categoria['imagen_url'];

              return CategoryCard(
                nombre: categoria['nombre'] ?? 'Categoría',
                icon: Icons.category,
                imageUrl: imagenUrl,
                onTap: () => _navigateToProductosPorCategoria(
                  categoria['id'],
                  categoria['nombre'],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== PRODUCTOS SECTION (MÓVIL) ====================
  Widget _buildProductosSection() {
    if (_productosRecientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Productos Destacados",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: _navigateToProductos,
                child: const Text(
                  "Ver todo",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _productosRecientes.length,
          itemBuilder: (context, i) {
            final p = _productosRecientes[i];
            return ProductCard(
              productoId: p['id'],
              nombre: p['nombre'],
              precio: (p['precio'] ?? 0).toDouble(),
              imagenUrl: p['imagenUrl'],
              marca: p['marca'] ?? '',
              stock: p['stock'] ?? 0,
              onTap: () => _navigateToDetalleProducto(p['id']),
            );
          },
        ),
      ],
    );
  }

  // ==================== PRODUCTOS SECTION (ESCRITORIO) ====================
  Widget _buildDesktopProductosSection() {
    if (_productosRecientes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Productos Destacados",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                onPressed: _navigateToProductos,
                child: const Text(
                  "Ver todo",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _productosRecientes.length,
          itemBuilder: (context, i) {
            final p = _productosRecientes[i];
            return ProductCard(
              productoId: p['id'],
              nombre: p['nombre'],
              precio: (p['precio'] ?? 0).toDouble(),
              imagenUrl: p['imagenUrl'],
              marca: p['marca'] ?? '',
              stock: p['stock'] ?? 0,
              onTap: () => _navigateToDetalleProducto(p['id']),
            );
          },
        ),
      ],
    );
  }

  // ==================== WELCOME BANNER - AZUL PROFUNDO ====================
  // ==================== WELCOME BANNER - AZUL PROFUNDO ====================
  Widget _buildWelcomeBanner() {
    final saludo = _getSaludo();
    final tipoColor = _getTipoColor();
    final tipoIcon = _getTipoIcon();
    final tipoLabel = _getTipoClienteLabel();

    final hour = DateTime.now().hour;
    IconData iconSaludo;
    if (hour >= 6 && hour < 12) {
      iconSaludo = Icons.wb_sunny_rounded; // ☀️
    } else if (hour >= 12 && hour < 18) {
      iconSaludo = Icons.wb_sunny_rounded; // ☀️
    } else if (hour >= 18 && hour < 22) {
      iconSaludo = Icons.wb_twilight_rounded; // 🌅
    } else {
      iconSaludo = Icons.nightlight_round; // 🌙
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Stack(
        children: [
          // ✅ Fondo con azul profundo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A1628),
                  const Color(0xFF0F2847),
                  const Color(0xFF1A4B8C),
                  const Color(0xFF2D6BB5),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1A4B8C).withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Fila superior: Saludo + Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // ✅ Icono de sol en blanco
                        Icon(
                          iconSaludo,
                          color: Colors.white.withOpacity(0.8),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saludo,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              widget.nombre,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    // ✅ Badge tipo cliente
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tipoIcon,
                            color: Colors.white.withOpacity(0.6),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tipoLabel,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ✅ Línea decorativa
                Container(
                  height: 2,
                  width: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF3B82F6),
                        Colors.transparent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ Estadísticas integradas
                Row(
                  children: [
                    _buildFuturistStat(
                      icon: Icons.inventory_2_outlined,
                      label: 'Productos',
                      value: '${_productosRecientes.length}',
                      color: Colors.white,
                      iconBg: Colors.white.withOpacity(0.08),
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _buildFuturistStat(
                      icon: Icons.category_outlined,
                      label: 'Categorías',
                      value: '${_categorias.length}',
                      color: Colors.white,
                      iconBg: Colors.white.withOpacity(0.08),
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    _buildFuturistStat(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Carrito',
                      value: '$_carritoCount',
                      color: Colors.white,
                      iconBg: Colors.white.withOpacity(0.08),
                      textColor: Colors.white,
                    ),
                  ],
                ),
                // ✅ Estado
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Conectado',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.25),
                        fontSize: 10,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ Efectos decorativos
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  // ==================== STAT FUTURISTA ====================
  Widget _buildFuturistStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconBg,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: textColor.withOpacity(0.4),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR ====================
  Widget _buildModernBottomNavBar() {
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
                icon: Icons.inventory_outlined,
                selectedIcon: Icons.inventory,
                label: 'Productos',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_border,
                selectedIcon: Icons.favorite,
                label: 'Favoritos',
                index: 2,
              ),
              _buildHomeNavItem(),
              _buildNavItemWithBadge(
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart,
                label: 'Carrito',
                index: 3,
                badgeCount: _carritoCount,
              ),
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
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
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? AppColors.royalBlue : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                width: 16,
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
                  size: 22,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
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
                fontSize: 9,
                color: isSelected ? AppColors.royalBlue : Colors.grey[500],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                width: 16,
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

  Widget _buildHomeNavItem() {
    final isSelected = _selectedIndex == 0;
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
          colors: [AppColors.deepNavy, AppColors.royalBlue],
        )
            : null,
        shape: BoxShape.circle,
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: AppColors.royalBlue.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: InkWell(
        onTap: () => _onItemTapped(0),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.home,
            color: isSelected ? Colors.white : Colors.grey[500],
            size: 24,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}