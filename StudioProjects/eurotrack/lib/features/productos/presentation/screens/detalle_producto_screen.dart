import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/productos/data/services/producto_service.dart';

class DetalleProductoScreen extends StatelessWidget {
  final int productoId;
  final ProductoService _productoService = ProductoService();

  DetalleProductoScreen({super.key, required this.productoId});

  // --- LÓGICA DE IMAGEN UNIFICADA ---
  Widget _buildImage(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return const Center(child: Icon(Icons.settings, size: 100, color: AppColors.royalBlue));
    }

    Widget imageWidget;
    if (imagenUrl.startsWith('http')) {
      imageWidget = Image.network(
        imagenUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
      );
    } else {
      try {
        final cleanBase64 = imagenUrl.contains(',') ? imagenUrl.split(',').last : imagenUrl;
        imageWidget = Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 100),
        );
      } catch (e) {
        imageWidget = const Icon(Icons.broken_image, size: 100);
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text("Detalle del Producto", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _productoService.getProductoById(productoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Error al cargar el producto"));
          }
          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen ajustada
                Center(
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: _buildImage(p['imagenUrl']),
                  ),
                ),
                const SizedBox(height: 20),
                Text(p['nombre'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Marca: ${p['marca'] ?? 'N/A'}"),
                Text("Número de parte: ${p['numeroParte'] ?? 'N/A'}"),
                Text("Código: ${p['codigo'] ?? 'N/A'}"),
                const Divider(height: 30),
                Text("Precio: \$${p['precio'] ?? 0}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.royalBlue)),
                const SizedBox(height: 8),
                Text("Stock disponible: ${p['stock'] ?? 0} unidades"),
                const SizedBox(height: 8),
                Text("Categoría: ${p['categoriaNombre'] ?? 'N/A'}"),
                const SizedBox(height: 20),
                const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(p['descripcion'] ?? 'Sin descripción'),
              ],
            ),
          );
        },
      ),
    );
  }
}