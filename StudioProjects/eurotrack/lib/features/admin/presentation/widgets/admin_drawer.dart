// lib/features/admin/presentation/widgets/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/services/platform_service.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';

// ✅ ELIMINAR cualquier clase llamada ResponsiveScaffold de este archivo
// Solo debe tener la clase AdminDrawer

class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformService.isDesktop || PlatformService.isWeb;

    if (isDesktop) {
      return _buildSidebar(context);
    } else {
      return _buildDrawer(context);
    }
  }

  // ==================== DRAWER PARA MÓVIL ====================
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    index: 0,
                    title: "Dashboard",
                    icon: Icons.dashboard,
                    selected: selectedIndex == 0,
                  ),
                  _buildDrawerItem(
                    context,
                    index: 1,
                    title: "Usuarios",
                    icon: Icons.people,
                    selected: selectedIndex == 1,
                  ),
                  _buildDrawerItem(
                    context,
                    index: 2,
                    title: "Productos",
                    icon: Icons.inventory,
                    selected: selectedIndex == 2,
                  ),
                  _buildDrawerItem(
                    context,
                    index: 3,
                    title: "Categorías",
                    icon: Icons.category,
                    selected: selectedIndex == 3,
                  ),
                  _buildDrawerItem(
                    context,
                    index: 4,
                    title: "Pedidos",
                    icon: Icons.receipt_long,
                    selected: selectedIndex == 4,
                  ),
                  const Divider(height: 24, thickness: 1),
                  _buildDrawerItem(
                    context,
                    index: 6,
                    title: "Auditoría y Logs",
                    icon: Icons.analytics,
                    selected: selectedIndex == 6,
                  ),
                  const Divider(height: 24, thickness: 1),
                  _buildDrawerItem(
                    context,
                    index: 5,
                    title: "Mi Perfil",
                    icon: Icons.person_outline,
                    selected: selectedIndex == 5,
                  ),
                  const Divider(height: 24, thickness: 1),
                  _buildLogoutItem(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SIDEBAR PARA ESCRITORIO ====================
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              children: [
                _buildSidebarItem(
                  context,
                  index: 0,
                  title: "Dashboard",
                  icon: Icons.dashboard,
                  selected: selectedIndex == 0,
                ),
                _buildSidebarItem(
                  context,
                  index: 1,
                  title: "Usuarios",
                  icon: Icons.people,
                  selected: selectedIndex == 1,
                ),
                _buildSidebarItem(
                  context,
                  index: 2,
                  title: "Productos",
                  icon: Icons.inventory,
                  selected: selectedIndex == 2,
                ),
                _buildSidebarItem(
                  context,
                  index: 3,
                  title: "Categorías",
                  icon: Icons.category,
                  selected: selectedIndex == 3,
                ),
                _buildSidebarItem(
                  context,
                  index: 4,
                  title: "Pedidos",
                  icon: Icons.receipt_long,
                  selected: selectedIndex == 4,
                ),
                const Divider(height: 24, thickness: 1),
                _buildSidebarItem(
                  context,
                  index: 6,
                  title: "Auditoría y Logs",
                  icon: Icons.analytics,
                  selected: selectedIndex == 6,
                ),
                const Divider(height: 24, thickness: 1),
                _buildSidebarItem(
                  context,
                  index: 5,
                  title: "Mi Perfil",
                  icon: Icons.person_outline,
                  selected: selectedIndex == 5,
                ),
                const Divider(height: 24, thickness: 1),
                _buildLogoutSidebarItem(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.deepNavy, AppColors.royalBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Panel Admin",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Eurotrack System",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ITEM DEL DRAWER (MÓVIL) ====================
  Widget _buildDrawerItem(
      BuildContext context, {
        required int index,
        required String title,
        required IconData icon,
        required bool selected,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.royalBlue : Colors.grey[600],
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? AppColors.royalBlue : Colors.grey[800],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: selected
          ? Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.royalBlue,
          shape: BoxShape.circle,
        ),
      )
          : null,
      tileColor: selected ? AppColors.royalBlue.withOpacity(0.08) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () {
        Navigator.pop(context);
        Future.microtask(() => onItemSelected(index));
      },
    );
  }

  // ==================== ITEM DEL SIDEBAR (ESCRITORIO) ====================
  Widget _buildSidebarItem(
      BuildContext context, {
        required int index,
        required String title,
        required IconData icon,
        required bool selected,
      }) {
    return InkWell(
      onTap: () {
        onItemSelected(index);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? AppColors.royalBlue.withOpacity(0.08) : null,
          borderRadius: BorderRadius.circular(10),
          border: selected
              ? Border.all(color: AppColors.royalBlue.withOpacity(0.2))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.royalBlue : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: selected ? AppColors.royalBlue : Colors.grey[800],
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
            if (selected)
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.royalBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== LOGOUT MÓVIL ====================
  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.logout,
        color: Colors.red,
        size: 22,
      ),
      title: const Text(
        "Cerrar Sesión",
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onTap: () {
        Navigator.pop(context);
        Future.microtask(() => _showLogoutDialog(context));
      },
    );
  }

  // ==================== LOGOUT ESCRITORIO ====================
  Widget _buildLogoutSidebarItem(BuildContext context) {
    return InkWell(
      onTap: () => _showLogoutDialog(context),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.logout,
              color: Colors.red,
              size: 22,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                "Cerrar Sesión",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== DIÁLOGO DE LOGOUT ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Cerrar Sesión",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "¿Estás seguro de que deseas cerrar sesión?",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              final authService = AuthService();
              await authService.logout();

              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text(
              "Cerrar Sesión",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}