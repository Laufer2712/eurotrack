import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/productos/data/services/producto_service.dart';
import 'package:eurotrack/features/productos/presentation/widgets/product_card_catalog.dart';
import 'package:eurotrack/features/favoritos/data/services/favorito_service.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';

class ProductosPorCategoriaScreen extends StatefulWidget {
  final int categoriaId;
  final String categoriaNombre;
  final int userId;

  const ProductosPorCategoriaScreen({
    super.key,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.userId,
  });

  @override
  State<ProductosPorCategoriaScreen> createState() => _ProductosPorCategoriaScreenState();
}

class _ProductosPorCategoriaScreenState extends State<ProductosPorCategoriaScreen> {
  final ProductoService _productoService = ProductoService();
  final FavoritoService _favoritoService = FavoritoService();
  final CarritoService _carritoService = CarritoService();

  List<Map<String, dynamic>> _productosFiltrados = [];
  Set<int> _favoritosIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      final todosLosProductos = await _productoService.getCatalogo();
      final favoritos = await _favoritoService.getFavoritos(widget.userId);

      setState(() {
        // Filtramos directamente por el ID de categoría que viene en el objeto producto
        _productosFiltrados = todosLosProductos.where((p) => p['categoriaId'] == widget.categoriaId).toList();
        _favoritosIds = favoritos.map((p) => p['id'] as int).toSet();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: Text(widget.categoriaNombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _productosFiltrados.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.70,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _productosFiltrados.length,
        itemBuilder: (context, index) {
          final p = _productosFiltrados[index];
          return ProductCardCatalog(
            productoId: p['id'],
            nombre: p['nombre'],
            precio: (p['precio'] ?? 0).toDouble(),
            imagenUrl: p['imagenUrl'],
            marca: p['marca'] ?? '',
            stock: p['stock'] ?? 0,
            isFavorito: _favoritosIds.contains(p['id']),
            onTap: () => Navigator.pushNamed(context, '/detalle-producto', arguments: p['id']),
            onFavoritoTap: () => _toggleFavorito(p['id']),
            onCarritoTap: () async {
              await _carritoService.agregar(
                productoId: p['id'],
                nombre: p['nombre'],
                precio: (p['precio'] ?? 0).toDouble(),
                imagenUrl: p['imagenUrl'],
                marca: p['marca'] ?? '',
                stock: p['stock'] ?? 0,
              );
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Agregado al carrito")));
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() => const Center(
    child: Text("No hay productos en esta categoría", style: TextStyle(color: Colors.grey)),
  );
}