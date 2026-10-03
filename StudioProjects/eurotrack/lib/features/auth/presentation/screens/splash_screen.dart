import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:eurotrack/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSession();
    });
  }

  Future<void> _checkSession() async {
    if (_isChecking) return;
    _isChecking = true;

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // ✅ Verificar si hay sesión activa
      final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final String? userDataString = prefs.getString('user_data');

      if (isLoggedIn && userDataString != null && userDataString.isNotEmpty) {
        try {
          final Map<String, dynamic> userData = jsonDecode(userDataString);

          if (userData.isNotEmpty && userData.containsKey('id')) {
            final String rol = userData['rol'] ?? 'CLIENTE';

            if (rol == 'ADMIN') {
              Navigator.pushReplacementNamed(context, '/admin', arguments: {
                'userId': userData['id'] ?? 0,
                'nombre': userData['usuario'] ?? 'Administrador',
              });
            } else {
              Navigator.pushReplacementNamed(context, '/home', arguments: userData);
            }
            return;
          }
        } catch (e) {
          debugPrint("❌ Error al decodificar user_data: $e");
          await prefs.clear();
        }
      }

      // ✅ Si no hay sesión válida, ir al login
      Navigator.pushReplacementNamed(context, '/login');

    } catch (e) {
      debugPrint("❌ Error en SplashScreen: $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: const Icon(
                Icons.settings,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "EUROTRACK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Repuestos para camiones",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}