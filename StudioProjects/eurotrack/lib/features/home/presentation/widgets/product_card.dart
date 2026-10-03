import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final int productoId;
  final String nombre;
  final double precio;
  final String? imagenUrl;
  final String marca;
  final int stock;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.productoId,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
    required this.marca,
    required this.stock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ========== IMAGEN ==========
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Container(
                  width: double.infinity,
                  color: Colors.grey.shade50,
                  child: imagenUrl != null && imagenUrl!.isNotEmpty
                      ? Image.memory(
                    base64Decode(imagenUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(isDesktop);
                    },
                  )
                      : _buildPlaceholder(isDesktop),
                ),
              ),
            ),
            // ========== INFORMACIÓN ==========
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre
                  Text(
                    nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: isDesktop ? 13 : 12,
                      color: AppColors.deepNavy,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Marca
                  Text(
                    marca.isNotEmpty ? marca : 'Marca genérica',
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Precio y estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 15 : 14,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      if (stock < 5 && stock > 0)
                        _buildStockBadge(
                          'Últimos',
                          Colors.orange.shade50,
                          Colors.orange.shade200,
                          Colors.orange.shade700,
                        ),
                      if (stock == 0)
                        _buildStockBadge(
                          'Agotado',
                          Colors.red.shade50,
                          Colors.red.shade200,
                          Colors.red.shade700,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: isDesktop ? 40 : 32,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 4),
          Text(
            'Sin imagen',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(String label, Color bgColor, Color borderColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}