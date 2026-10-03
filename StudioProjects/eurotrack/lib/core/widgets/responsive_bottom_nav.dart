import 'package:flutter/material.dart';
import 'package:eurotrack/core/services/platform_service.dart';

class ResponsiveBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const ResponsiveBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformService.isDesktop || PlatformService.isWeb;

    if (isDesktop) {
      return _buildDesktopNav();
    } else {
      return _buildMobileNav();
    }
  }

  /// BottomNavigationBar para móvil
  Widget _buildMobileNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1A3A6B),
      unselectedItemColor: Colors.grey,
      currentIndex: currentIndex,
      onTap: onTap,
      items: items,
    );
  }

  /// NavigationRail para escritorio
  Widget _buildDesktopNav() {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      destinations: items.map((item) {
        return NavigationRailDestination(
          icon: item.icon,
          selectedIcon: item.icon,
          label: Text(item.label ?? ''),
        );
      }).toList(),
    );
  }
}