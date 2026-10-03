import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/productos/data/services/producto_service.dart';
import 'package:eurotrack/features/productos/presentation/widgets/product_card_catalog.dart';
import 'package:eurotrack/features/productos/presentation/widgets/filter_chips.dart';
import 'package:eurotrack/features/productos/presentation/widgets/sort_bottom_sheet.dart';
import 'package:eurotrack/features/favoritos/data/services/favorito_service.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';

class ProductosScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const ProductosScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  final ProductoService _productoService = ProductoService();
  final FavoritoService _favoritoService = FavoritoService();
  final CarritoService _carritoService = CarritoService();

  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _categorias = [];
  List<Map<String, dynamic>> _productosFiltrados = [];

  bool _isLoading = true;
  String _searchQuery = "";
  int? _selectedCategoriaId;
  String _sortBy = "default";
  String _viewMode = "grid";
  Set<int> _favoritosIds = {};
  int _carritoCount = 0;
  int _selectedIndex = 1;
  String? _fotoPerfilBase64;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _cargarFavoritos();
    _cargarCarritoCount();
    _fetchFotoPerfil();

    // ✅ DEBUG: Verificar que el nombre llega correctamente
    print('🔵 ProductosScreen - nombre: ${widget.nombre}');
    print('🔵 ProductosScreen - userId: ${widget.userId}');
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

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _productoService.getCatalogo();
      final categorias = await _productoService.getCategorias();

      setState(() {
        _productos = productos;
        _categorias = categorias;
        _aplicarFiltros();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cargarFavoritos() async {
    try {
      final favoritos = await _favoritoService.getFavoritos(widget.userId);
      setState(() {
        _favoritosIds = favoritos.map((p) => p['id'] as int).toSet();
      });
    } catch (e) {
      debugPrint("Error cargando favoritos: $e");
    }
  }

  void _aplicarFiltros() {
    List<Map<String, dynamic>> resultado = List.from(_productos);

    if (_searchQuery.isNotEmpty) {
      resultado = resultado.where((p) =>
      p['nombre'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['marca'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p['codigo'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedCategoriaId != null) {
      resultado = resultado.where((p) =>
      p['categoriaId'] == _selectedCategoriaId
      ).toList();
    }

    switch (_sortBy) {
      case "price_asc":
        resultado.sort((a, b) => (a['precio'] ?? 0).compareTo(b['precio'] ?? 0));
        break;
      case "price_desc":
        resultado.sort((a, b) => (b['precio'] ?? 0).compareTo(a['precio'] ?? 0));
        break;
      case "name_asc":
        resultado.sort((a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));
        break;
      default:
        break;
    }

    setState(() {
      _productosFiltrados = resultado;
    });
  }

  void _onSearchChanged(String value) {
    _searchQuery = value;
    _aplicarFiltros();
  }

  void _onCategoriaSelected(int? categoriaId) {
    setState(() {
      _selectedCategoriaId = categoriaId;
    });
    _aplicarFiltros();
  }

  void _onSortSelected(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    _aplicarFiltros();
  }

  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == "grid" ? "list" : "grid";
    });
  }

  void _toggleFavorito(int productoId) async {
    final isFav = _favoritosIds.contains(productoId);
    if (isFav) {
      await _favoritoService.eliminarFavorito(widget.userId, productoId);
      setState(() => _favoritosIds.remove(productoId));
    } else {
      await _favoritoService.agregarFavorito(widget.userId, productoId);
      setState(() => _favoritosIds.add(productoId));
    }
  }

  // ✅ CORREGIDO: _onItemTapped con el mapa completo
  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    final routes = ['/home', '/productos', '/favoritos', '/carrito', '/mis-pedidos'];

    if (index == 1) {
      // Ya estamos en productos, recargar
      _cargarDatos();
      return;
    }

    if (index < routes.length) {
      // ✅ Siempre enviamos el mapa completo con 'nombre'
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

  // ============================================================
  // AGREGAR AL CARRITO
  // ============================================================
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
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Producto agregado al carrito'),
              ],
            ),
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
            content: Text('Error al agregar: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterBar(),
          _buildResultsHeader(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _productosFiltrados.isEmpty
                ? _buildEmptyState()
                : _viewMode == "grid"
                ? _buildGridView()
                : _buildListView(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ============================================================
  // BARRA DE BÚSQUEDA
  // ============================================================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.deepNavy,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: "Buscar productos...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.search_rounded, color: AppColors.royalBlue),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
              onPressed: () {
                _searchQuery = "";
                _onSearchChanged("");
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTROS
  // ============================================================
  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: FilterChips(
              categorias: _categorias,
              selectedCategoriaId: _selectedCategoriaId,
              onCategoriaSelected: _onCategoriaSelected,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.royalBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.sort_rounded,
                color: AppColors.royalBlue,
                size: 22,
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SortBottomSheet(
                    currentSort: _sortBy,
                    onSortSelected: _onSortSelected,
                  ),
                );
              },
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER DE RESULTADOS
  // ============================================================
  Widget _buildResultsHeader() {
    final bool hasFilters = _selectedCategoriaId != null || _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                "${_productosFiltrados.length} productos",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (hasFilters)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategoriaId = null;
                  _searchQuery = "";
                });
                _aplicarFiltros();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.royalBlue,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Row(
                children: [
                  const Icon(Icons.clear_rounded, size: 14),
                  const SizedBox(width: 4),
                  const Text(
                    "Limpiar filtros",
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO DE CARGA
  // ============================================================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.royalBlue),
          SizedBox(height: 16),
          Text(
            'Cargando productos...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 50,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No se encontraron productos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Prueba con otros filtros",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GRID VIEW
  // ============================================================
  Widget _buildGridView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final crossAxisCount = isDesktop ? 4 : 2;

    return GridView.builder(
      padding: EdgeInsets.all(isDesktop ? 20 : 12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        crossAxisSpacing: isDesktop ? 20 : 12,
        mainAxisSpacing: isDesktop ? 20 : 12,
      ),
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = _productosFiltrados[index];
        final isFavorito = _favoritosIds.contains(producto['id']);

        return ProductCardCatalog(
          productoId: producto['id'] ?? 0,
          nombre: producto['nombre'] ?? 'Sin nombre',
          precio: (producto['precio'] ?? 0).toDouble(),
          imagenUrl: producto['imagenUrl'],
          marca: producto['marca'] ?? '',
          stock: producto['stock'] ?? 0,
          isFavorito: isFavorito,
          isListView: false,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detalle-producto',
              arguments: producto['id'],
            );
          },
          onFavoritoTap: () => _toggleFavorito(producto['id']),
          onCarritoTap: () => _agregarAlCarrito(producto),
        );
      },
    );
  }

  // ============================================================
  // LIST VIEW
  // ============================================================
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) {
        final producto = _productosFiltrados[index];
        final isFavorito = _favoritosIds.contains(producto['id']);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ProductCardCatalog(
            productoId: producto['id'] ?? 0,
            nombre: producto['nombre'] ?? 'Sin nombre',
            precio: (producto['precio'] ?? 0).toDouble(),
            imagenUrl: producto['imagenUrl'],
            marca: producto['marca'] ?? '',
            stock: producto['stock'] ?? 0,
            isFavorito: isFavorito,
            isListView: true,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/detalle-producto',
                arguments: producto['id'],
              );
            },
            onFavoritoTap: () => _toggleFavorito(producto['id']),
            onCarritoTap: () => _agregarAlCarrito(producto),
          ),
        );
      },
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