// lib/core/widgets/responsive_wrapper.dart

import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Breakpoints responsivos
    // Móvil: < 600px
    // Tablet: 600px - 900px
    // Escritorio: > 900px

    // ✅ En escritorio, ocupar TODO el espacio (sin límite)
    if (screenWidth >= 900) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: child,
      );
    }

    // Para tablet y móvil, con padding moderado
    EdgeInsets effectivePadding;
    if (screenWidth < 600) {
      effectivePadding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
    } else {
      effectivePadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }

    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}