// lib/features/admin/presentation/screens/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_scaffold.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_usuarios_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_productos_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_categorias_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_pedidos_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_logs_screen.dart';
import 'package:eurotrack/features/admin/presentation/widgets/admin_drawer.dart';
import 'package:eurotrack/features/profile/presentation/screens/profile_screen.dart';

class AdminDashboard extends StatefulWidget {
  final int userId;
  final String nombre;

  const AdminDashboard({super.key, required this.userId, required this.nombre});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  int _selectedIndex = 0;
  final GlobalKey<AdminLogsScreenState> _logsKey = GlobalKey<AdminLogsScreenState>();

  @override
  void initState() {
    super.initState();
    _cargarStats();
  }

  Future<void> _cargarStats() async {
    setState(() => _isLoading = true);
    final stats = await _adminService.getStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: isMobile
          ? _buildMobileScaffold()
          : _buildDesktopScaffold(),
    );
  }

  // ==================== DESKTOP SCAFFOLD ====================
  Widget _buildDesktopScaffold() {
    return ResponsiveScaffold(
      title: '',
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      actions: null,
      showAppBar: false,
      body: _buildBody(),
    );
  }

  // ==================== MOBILE SCAFFOLD ====================
  Widget _buildMobileScaffold() {
    return Scaffold(
      drawer: AdminDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ==================== BOTTOM NAVIGATION BAR (MÓVIL) ====================
  Widget _buildBottomNavigationBar() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: isMobile ? 65 : 75,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.dashboard, 'Inicio', 0),
              _buildNavItem(Icons.people, 'Usuarios', 1),
              _buildNavItem(Icons.inventory, 'Productos', 2),
              _buildNavItem(Icons.category, 'Categorías', 3),
              _buildNavItem(Icons.receipt_long, 'Pedidos', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 6 : 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.royalBlue : Colors.grey.shade500,
              size: isMobile ? 24 : 28,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: isSelected ? AppColors.royalBlue : Colors.grey.shade500,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                height: 3,
                width: 20,
                decoration: BoxDecoration(
                  color: AppColors.royalBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return AdminUsuariosScreen(userId: widget.userId);
      case 2:
        return AdminProductosScreen(userId: widget.userId);
      case 3:
        return AdminCategoriasScreen(userId: widget.userId);
      case 4:
        return AdminPedidosScreen();
      case 5:
        return ProfileScreen(
          userId: widget.userId,
          nombreInicial: widget.nombre,
          usernameInicial: "admin",
        );
      case 6:
        return AdminLogsScreen(key: _logsKey);
      default:
        return _buildDashboardContent();
    }
  }

  // ==================== DASHBOARD CONTENT ====================
  Widget _buildDashboardContent() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando estadísticas...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          Text(
            "Acciones Rápidas",
            style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy
            ),
          ),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepNavy, AppColors.royalBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.deepNavy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: isMobile ? 24 : 28,
                ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenido, Administrador",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Sesión activa: ${widget.nombre}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: isMobile ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Online",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Descubre todo lo nuevo hoy.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: isMobile ? 12 : 14,
            ),
          ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Online",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.5;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 2.0;
      spacing = 16;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 2.2;
      spacing = 16;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        _buildStatCard(
          "Usuarios",
          _stats['totalUsuarios'] ?? 0,
          Icons.people,
          AppColors.royalBlue,
        ),
        _buildStatCard(
          "Productos",
          _stats['totalProductos'] ?? 0,
          Icons.inventory,
          AppColors.electricBlue,
        ),
        _buildStatCard(
          "Categorías",
          _stats['totalCategorias'] ?? 0,
          Icons.category,
          Colors.orange,
        ),
        _buildStatCard(
          "Productos activos",
          _stats['productosActivos'] ?? 0,
          Icons.check_circle,
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: isMobile
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
          : Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 900;

    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isMobile) {
      crossAxisCount = 1;
      childAspectRatio = 4.0;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 3.5;
      spacing = 16;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 3.0;
      spacing = 16;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      childAspectRatio: childAspectRatio,
      children: [
        _buildQuickActionCard(
          "Usuarios",
          Icons.people,
          AppColors.royalBlue,
          1,
        ),
        _buildQuickActionCard(
          "Productos",
          Icons.inventory,
          AppColors.electricBlue,
          2,
        ),
        _buildQuickActionCard(
          "Categorías",
          Icons.category,
          Colors.orange,
          3,
        ),
        _buildQuickActionCard(
          "Pedidos",
          Icons.receipt_long,
          Colors.green,
          4,
        ),
        // 👇 AÑADE ESTAS DOS NUEVAS ACCIONES
        _buildQuickActionCard(
          "Mi Perfil",
          Icons.person,
          Colors.purple,
          5,
        ),
        _buildQuickActionCard(
          "Logs",
          Icons.history,
          Colors.teal,
          6,
        ),
      ],
    );
  }
  Widget _buildQuickActionCard(String title, IconData icon, Color color, int index) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSelected = _selectedIndex == index;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 14 : 18,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isSelected ? 0.08 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade100,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 0),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isMobile ? 20 : 28,
                  color: isSelected ? color : Colors.grey.shade600,
                ),
              ),
              SizedBox(width: isMobile ? 10 : 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? color : AppColors.deepNavy,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: isMobile ? 12 : 14,
                color: isSelected ? color : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}