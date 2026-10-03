import 'package:flutter/material.dart';
import 'package:eurotrack/core/services/platform_service.dart';

/// Widget que muestra diferentes layouts según el tamaño de pantalla
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget? web;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    this.web,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = PlatformService.isWeb;

    // Si es web y se proporciona un widget específico
    if (isWeb && web != null) {
      return web!;
    }

    // Layout responsive por ancho
    if (screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 600) {
      return tablet;
    } else {
      return mobile;
    }
  }
}

/// Widget que usa un builder para layouts responsivos
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveType type) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = PlatformService.isWeb;

    ResponsiveType type;
    if (isWeb) {
      type = ResponsiveType.web;
    } else if (screenWidth >= 1200) {
      type = ResponsiveType.desktop;
    } else if (screenWidth >= 600) {
      type = ResponsiveType.tablet;
    } else {
      type = ResponsiveType.mobile;
    }

    return builder(context, type);
  }
}

enum ResponsiveType {
  mobile,
  tablet,
  desktop,
  web,
}