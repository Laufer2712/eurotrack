import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';

class AdminFavoritosUsuarioScreen extends StatefulWidget {
  final int userId;
  final String userNombre;

  const AdminFavoritosUsuarioScreen({
    super.key,
    required this.userId,
    required this.userNombre,
  });

  @override
  State<AdminFavoritosUsuarioScreen> createState() => _AdminFavoritosUsuarioScreenState();
}

class _AdminFavoritosUsuarioScreenState extends State<AdminFavoritosUsuarioScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _favoritos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    setState(() => _isLoading = true);
    final favoritos = await _adminService.getFavoritosByUsuario(widget.userId);

    if (favoritos.isNotEmpty) {
      print("📦 Primer favorito: ${favoritos.first}");
    }

    setState(() {
      _favoritos = favoritos;
      _isLoading = false;
    });
  }

  // ============================================================
  // DECODIFICAR IMAGEN
  // ============================================================
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

  // ============================================================
  // CONSTRUIR IMAGEN DEL PRODUCTO
  // ============================================================
  Widget _buildProductImage(String? imageUrl, {double size = 80}) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.royalBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        size: size * 0.4,
        color: Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final crossAxisCount = isDesktop ? 4 : isTablet ? 3 : 2;
    final padding = isDesktop ? 20.0 : 12.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: Text(
          "Favoritos de ${widget.userNombre}",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarFavoritos,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text(
              "Cargando favoritos...",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      )
          : _favoritos.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _cargarFavoritos,
        color: AppColors.royalBlue,
        child: GridView.builder(
          padding: EdgeInsets.all(padding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isDesktop ? 0.75 : 0.7,
            crossAxisSpacing: isDesktop ? 16 : 12,
            mainAxisSpacing: isDesktop ? 16 : 12,
          ),
          itemCount: _favoritos.length,
          itemBuilder: (context, index) {
            final producto = _favoritos[index];
            return _buildProductoCard(producto, isDesktop: isDesktop);
          },
        ),
      ),
    );
  }

  // ============================================================
  // TARJETA DE PRODUCTO
  // ============================================================
  Widget _buildProductoCard(Map<String, dynamic> producto, {bool isDesktop = false}) {
    final nombre = producto['productoNombre'] ?? producto['nombre'] ?? 'Sin nombre';
    final marca = producto['productoMarca'] ?? producto['marca'] ?? '';
    final precio = producto['productoPrecio'] ?? producto['precio'] ?? 0;
    final productoId = producto['productoId'] ?? producto['id'] ?? 0;
    final imagenUrl = producto['productoImagenUrl'] ?? producto['imagenUrl'];

    final double precioDouble = precio is int ? precio.toDouble() : precio;
    final imageSize = isDesktop ? 90.0 : 70.0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: isDesktop ? 3 : 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/detalle-producto',
            arguments: productoId,
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.all(isDesktop ? 14 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Imagen del producto
              Center(
                child: _buildProductImage(imagenUrl, size: imageSize),
              ),
              const SizedBox(height: 10),
              // ✅ Nombre
              Text(
                nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isDesktop ? 14 : 12,
                  color: AppColors.deepNavy,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // ✅ Marca
              Text(
                marca,
                style: TextStyle(
                  fontSize: isDesktop ? 12 : 10,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // ✅ Precio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "\$${precioDouble.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isDesktop ? 15 : 13,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 14,
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
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Icon(
              Icons.favorite_border,
              size: 60,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Sin productos favoritos",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${widget.userNombre} no ha agregado productos a favoritos",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _cargarFavoritos,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text("Recargar"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.royalBlue,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}