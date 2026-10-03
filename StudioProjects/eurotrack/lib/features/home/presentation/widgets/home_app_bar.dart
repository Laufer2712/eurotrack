// lib/features/home/presentation/widgets/home_app_bar.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String nombre;
  final int userId;
  final VoidCallback onPerfilTap;
  final String tipoCliente;
  final Uint8List? fotoPerfil;
  final int carritoCount;

  const HomeAppBar({
    super.key,
    required this.nombre,
    required this.userId,
    required this.onPerfilTap,
    this.tipoCliente = 'NATURAL',
    this.fotoPerfil,
    this.carritoCount = 0,
  });

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade400),
            const SizedBox(width: 8),
            const Text("Cerrar sesión"),
          ],
        ),
        content: const Text(
          "¿Estás seguro de que quieres cerrar sesión?",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                      (route) => false,
                );
              }
            },
            child: const Text("Salir"),
          ),
        ],
      ),
    );
  }

  String _getTipoBadgeText() {
    switch (tipoCliente) {
      case 'JURIDICO':
        return 'EMPRESA';
      case 'TRANSPORTISTA':
        return 'TRANSPORTISTA';
      default:
        return 'CLIENTE';
    }
  }

  Color _getTipoColor() {
    switch (tipoCliente) {
      case 'JURIDICO':
        return Colors.purple;
      case 'TRANSPORTISTA':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getTipoIcon() {
    switch (tipoCliente) {
      case 'JURIDICO':
        return Icons.business_outlined;
      case 'TRANSPORTISTA':
        return Icons.local_shipping_outlined;
      default:
        return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tipoColor = _getTipoColor();
    final tipoIcon = _getTipoIcon();
    final tipoText = _getTipoBadgeText();

    return AppBar(
      backgroundColor: AppColors.deepNavy,
      elevation: 0,
      title: Row(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          // Título con badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "EUROTRACK",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
              Row(
                children: [
                  Icon(
                    tipoIcon,
                    color: tipoColor,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tipoText,
                    style: TextStyle(
                      color: tipoColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // 🔔 Notificaciones
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/notificaciones',
              arguments: {
                'id': userId,
                'nombre': nombre,
              },
            );
          },
        ),
        // 🛒 Carrito
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/carrito',
                  arguments: {
                    'id': userId,
                    'nombre': nombre,
                  },
                );
              },
            ),
            if (carritoCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    carritoCount > 9 ? '9+' : '$carritoCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        // 👤 Perfil + Cerrar Sesión JUNTOS
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Perfil (Avatar)
            GestureDetector(
              onTap: onPerfilTap,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    backgroundImage: fotoPerfil != null ? MemoryImage(fotoPerfil!) : null,
                    child: fotoPerfil == null
                        ? Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white,
                      size: 28,
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        tipoIcon,
                        color: tipoColor,
                        size: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ✅ BOTÓN DE CERRAR SESIÓN (al lado del avatar)
            IconButton(
              icon: Icon(
                Icons.logout_rounded,
                color: Colors.white.withOpacity(0.7),
                size: 22,
              ),
              onPressed: () => _showLogoutDialog(context),
              tooltip: "Cerrar sesión",
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}