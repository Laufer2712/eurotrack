import 'package:flutter/material.dart';
import 'package:eurotrack/core/services/platform_service.dart';

/// Widget principal que envuelve toda la app y maneja el layout responsive
class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showAppBar;
  final String? appBarTitle;
  final List<Widget>? appBarActions;
  final Widget? drawer;
  final Widget? bottomNavigationBar;

  const AppLayout({
    super.key,
    required this.child,
    this.showAppBar = true,
    this.appBarTitle,
    this.appBarActions,
    this.drawer,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = PlatformService.isMobile;
    final isDesktop = PlatformService.isDesktop || PlatformService.isWeb;

    if (isDesktop && !isMobile) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  /// Layout para móvil (con AppBar y Drawer)
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: showAppBar
          ? AppBar(
        title: Text(
          appBarTitle ?? '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: appBarActions,
      )
          : null,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: child,
    );
  }

  /// Layout para escritorio (sin AppBar, con sidebar si es necesario)
  Widget _buildDesktopLayout() {
    // Si hay drawer, lo mostramos como sidebar
    if (drawer != null) {
      return Row(
        children: [
          // Sidebar fijo
          Container(
            width: 280,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: drawer,
          ),
          // Contenido
          Expanded(
            child: Column(
              children: [
                // AppBar simplificado
                if (showAppBar)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1628),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          appBarTitle ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (appBarActions != null) ...appBarActions!,
                      ],
                    ),
                  ),
                // Contenido
                Expanded(
                  child: child,
                ),
                // BottomNavigationBar en escritorio (opcional)
                if (bottomNavigationBar != null)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                    child: bottomNavigationBar,
                  ),
              ],
            ),
          ),
        ],
      );
    }

    // Sin drawer, layout simple
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: showAppBar
          ? AppBar(
        title: Text(
          appBarTitle ?? '',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: appBarActions,
      )
          : null,
      body: child,
    );
  }
}