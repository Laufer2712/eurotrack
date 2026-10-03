// lib/features/home/presentation/widgets/category_card.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class CategoryCard extends StatelessWidget {
  final String nombre;
  final IconData icon;
  final String? imageUrl;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.nombre,
    required this.icon,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isDesktop ? 100 : 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // Imagen/Icono
            Container(
              width: isDesktop ? 80 : 65,
              height: isDesktop ? 80 : 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isDesktop ? 16 : 14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade100,
                  width: 1,
                ),
                image: imageUrl != null && imageUrl!.isNotEmpty
                    ? DecorationImage(
                  image: MemoryImage(base64Decode(imageUrl!)),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: imageUrl == null || imageUrl!.isEmpty
                  ? Icon(
                icon,
                size: isDesktop ? 32 : 28,
                color: AppColors.royalBlue.withOpacity(0.6),
              )
                  : null,
            ),
            const SizedBox(height: 6),
            // Nombre
            Text(
              nombre,
              style: TextStyle(
                fontSize: isDesktop ? 12 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}