import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class ProductCardCatalog extends StatelessWidget {
  final int productoId;
  final String nombre;
  final double precio;
  final String? imagenUrl;
  final String marca;
  final int stock;
  final bool isFavorito;
  final bool isListView;
  final VoidCallback onTap;
  final VoidCallback onFavoritoTap;
  final VoidCallback onCarritoTap;

  const ProductCardCatalog({
    super.key,
    required this.productoId,
    required this.nombre,
    required this.precio,
    this.imagenUrl,
    required this.marca,
    required this.stock,
    required this.isFavorito,
    this.isListView = false,
    required this.onTap,
    required this.onFavoritoTap,
    required this.onCarritoTap,
  });

  Widget _buildImage({double? height, double? width}) {
    if (imagenUrl == null || imagenUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    Widget imageWidget;
    if (imagenUrl!.startsWith('http')) {
      imageWidget = Image.network(
        imagenUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    } else {
      try {
        final cleanBase64 = imagenUrl!.contains(',')
            ? imagenUrl!.split(',').last
            : imagenUrl!;
        imageWidget = Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder();
      }
    }

    return SizedBox(
      height: height,
      width: width,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 32,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildFavoritoButton({bool isSmall = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          isFavorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorito ? Colors.red : Colors.grey.shade600,
          size: isSmall ? 16 : 18,
        ),
        onPressed: onFavoritoTap,
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        constraints: BoxConstraints(
          minWidth: isSmall ? 28 : 32,
          minHeight: isSmall ? 28 : 32,
        ),
      ),
    );
  }

  Widget _buildAddToCartButton({bool isSmall = false, bool isListView = false}) {
    final isAvailable = stock > 0;

    if (isListView) {
      return SizedBox(
        width: 150,
        height: 36,
        child: ElevatedButton.icon(
          onPressed: isAvailable ? onCarritoTap : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isAvailable ? AppColors.royalBlue : Colors.grey.shade300,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          icon: Icon(
            Icons.add_shopping_cart_rounded,
            size: 16,
            color: isAvailable ? Colors.white : Colors.grey.shade600,
          ),
          label: Text(
            isAvailable ? 'Agregar' : 'Agotado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isAvailable ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.royalBlue : Colors.grey.shade300,
        shape: BoxShape.circle,
        boxShadow: isAvailable
            ? [
          BoxShadow(
            color: AppColors.royalBlue.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: IconButton(
        icon: Icon(
          Icons.add_shopping_cart_rounded,
          size: isSmall ? 16 : 18,
          color: isAvailable ? Colors.white : Colors.grey.shade600,
        ),
        onPressed: isAvailable ? onCarritoTap : null,
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        constraints: BoxConstraints(
          minWidth: isSmall ? 32 : 36,
          minHeight: isSmall ? 32 : 36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isListView) {
      return _buildListViewCard(context, isDesktop);
    }
    return _buildGridViewCard(context, isDesktop);
  }

  Widget _buildGridViewCard(BuildContext context, bool isDesktop) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              child: AspectRatio(
                aspectRatio: 1.2,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      color: Colors.grey.shade50,
                      child: _buildImage(),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _buildFavoritoButton(isSmall: isDesktop),
                    ),
                    if (stock < 5 && stock > 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _buildStockBadge(
                          'Últimos',
                          Colors.orange.shade50,
                          Colors.orange.shade200,
                          Colors.orange.shade700,
                        ),
                      ),
                    if (stock == 0)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _buildStockBadge(
                          'Agotado',
                          Colors.red.shade50,
                          Colors.red.shade200,
                          Colors.red.shade700,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  const SizedBox(height: 2),
                  Text(
                    marca.isNotEmpty ? marca : 'Genérico',
                    style: TextStyle(
                      fontSize: isDesktop ? 11 : 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${precio.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 16 : 14,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      _buildAddToCartButton(isSmall: isDesktop),
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

  Widget _buildListViewCard(BuildContext context, bool isDesktop) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: isDesktop ? 140 : 110,
                height: isDesktop ? 140 : 110,
                child: Container(
                  color: Colors.grey.shade50,
                  child: _buildImage(
                    height: isDesktop ? 140 : 110,
                    width: isDesktop ? 140 : 110,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isDesktop ? 16 : 14,
                              color: AppColors.deepNavy,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _buildFavoritoButton(isSmall: isDesktop),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      marca.isNotEmpty ? marca : 'Genérico',
                      style: TextStyle(
                        fontSize: isDesktop ? 13 : 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isDesktop ? 20 : 16,
                            color: AppColors.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 10),
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
                    const SizedBox(height: 10),
                    _buildAddToCartButton(isListView: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}