// lib/core/widgets/responsive_scaffold.dart

import 'package:flutter/material.dart';

class ResponsiveScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? drawer;
  final Widget? bottomNavigationBar;
  final bool showAppBar;
  final Color? backgroundColor;

  const ResponsiveScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.drawer,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ Breakpoints
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      return _buildDesktopLayout(context);
    } else if (isTablet) {
      return _buildTabletLayout(context);
    } else {
      return _buildMobileLayout(context);
    }
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF4F7FF),
      appBar: showAppBar
          ? AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      )
          : null,
      drawer: drawer,
      bottomNavigationBar: bottomNavigationBar,
      body: body,
    );
  }

  // ==================== LAYOUT TABLET ====================
  Widget _buildTabletLayout(BuildContext context) {
    // Tablet: Drawer más compacto
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF4F7FF),
      appBar: showAppBar
          ? AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1628),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      )
          : null,
      drawer: drawer != null
          ? Container(
        width: 220,
        child: drawer,
      )
          : null,
      body: body,
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFF0F4FF),
      body: Row(
        children: [
          // Sidebar fijo con diseño mejorado
          if (drawer != null)
            Container(
              width: 260,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(4, 0),
                  ),
                ],
              ),
              child: drawer,
            ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // AppBar simplificado
                if (showAppBar)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1628),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (actions != null) ...actions!,
                      ],
                    ),
                  ),
                // Contenido
                Expanded(
                  child: body,
                ),
                if (bottomNavigationBar != null)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
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
      ),
    );
  }
}