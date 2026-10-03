import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';
import 'dart:math' as math;
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _storage = const FlutterSecureStorage();

  bool _isObscured = true;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/logoE.png'), context);
  }

  // --- LÓGICA CORE DE AUTENTICACIÓN ---
  Future<Map<String, dynamic>?> _performAuth(String email, String password) async {
    try {
      return await _authService.login(email.trim(), password.trim());
    } catch (e) {
      return null;
    }
  }

  // --- NAVEGACIÓN CENTRALIZADA ---
  void _handleNavigation(Map<String, dynamic> response) {
    if (!mounted) return;
    final rol = response['rol'] ?? 'CLIENTE';
    if (rol == 'ADMIN') {
      Navigator.pushReplacementNamed(context, '/admin', arguments: {'userId': response['id'], 'nombre': response['usuario']});
    } else {
      Navigator.pushReplacementNamed(context, '/home', arguments: response);
    }
  }

  // --- LÓGICA BIOMÉTRICA ---
  Future<void> _handleBiometricLogin() async {
    try {
      bool canCheck = await _localAuth.canCheckBiometrics || await _localAuth.isDeviceSupported();
      if (!canCheck) return _showSnackBar("Biometría no disponible");

      bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Escanea tu huella para acceder',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (didAuthenticate) {
        String? email = await _storage.read(key: 'email');
        String? pass = await _storage.read(key: 'password');

        if (email != null && pass != null) {
          setState(() => _isLoading = true);
          final response = await _performAuth(email, pass);
          if (response != null) {
            _handleNavigation(response);
          } else {
            _showSnackBar("Error al validar sesión guardada");
            setState(() => _isLoading = false);
          }
        } else {
          _showSnackBar("Inicia sesión manualmente la primera vez");
        }
      }
    } catch (e) {
      _showSnackBar("Error al usar huella");
    }
  }

  // --- LÓGICA DE LOGIN ---
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar("Por favor, rellena todos los campos");
      return;
    }
    setState(() => _isLoading = true);

    final response = await _performAuth(_emailController.text, _passwordController.text);

    if (response != null) {
      await _storage.write(key: 'email', value: _emailController.text.trim());
      await _storage.write(key: 'password', value: _passwordController.text.trim());
      _handleNavigation(response);
    } else {
      _showSnackBar("Credenciales incorrectas");
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;
    final isTablet = size.width >= 600 && size.width < 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(size),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout(Size size) {
    return Stack(
      children: [
        _buildDecorativeGearPositioned(size),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(),
                            const SizedBox(height: 40),
                            _buildMobileForm(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ✅ Panel izquierdo - Branding azul con decoraciones
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0A1628),
                  AppColors.deepNavy,
                  AppColors.royalBlue,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decoraciones
                _buildLeftPanelDecorations(),
                // Contenido
                Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.directions_car,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'EuroTrack',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sistema de Repuestos y Logística\npara el sector automotriz.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _buildFeatureItem(Icons.shield, 'Seguro'),
                          const SizedBox(width: 28),
                          _buildFeatureItem(Icons.speed, 'Rápido'),
                          const SizedBox(width: 28),
                          _buildFeatureItem(Icons.support_agent, 'Soporte 24/7'),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Row(
                        children: [
                          _buildStatItem('500+', 'Clientes'),
                          const SizedBox(width: 32),
                          _buildStatItem('1000+', 'Productos'),
                          const SizedBox(width: 32),
                          _buildStatItem('98%', 'Satisfacción'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ✅ Panel derecho - Formulario blanco
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.all(40),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo pequeño
                      Image.asset(
                        'assets/images/logoE.png',
                        height: 50,
                        errorBuilder: (context, e, s) => const Icon(
                          Icons.directions_car,
                          size: 40,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ingresa tus credenciales para continuar',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildTextField(
                        hint: 'Usuario / Correo',
                        icon: Icons.person_outline,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        hint: 'Contraseña',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.deepNavy.withOpacity(0.4),
                          ),
                          onPressed: () => setState(() => _isObscured = !_isObscured),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/solicitar-codigo'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                          ),
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(color: AppColors.royalBlue),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'o',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Colors.grey.shade300,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBiometricButton(),
                      const SizedBox(height: 16),
                      _buildRegisterLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== DECORACIONES DEL PANEL IZQUIERDO ====================
  Widget _buildLeftPanelDecorations() {
    return Stack(
      children: [
        // Círculo grande
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        // Círculo pequeño
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        // Engranaje decorativo
        Positioned(
          top: 100,
          right: 20,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        // Puntos decorativos
        Positioned(
          bottom: 100,
          right: 30,
          child: Column(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== WIDGETS REUTILIZABLES ====================

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white.withOpacity(0.8),
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.deepNavy, AppColors.royalBlue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Multiservicios\n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
                const TextSpan(text: 'EUROTRACK\n', style: TextStyle(fontSize: 45, fontWeight: FontWeight.w900)),
                const TextSpan(text: 'Iveco', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, height: 0.9),
          ),
        ),
        Image.asset(
          'assets/images/logoE.png',
          width: 180,
          height: 90,
          errorBuilder: (context, e, s) => const Icon(Icons.settings, size: 70, color: AppColors.deepNavy),
        ),
        const Text(
          'SISTEMA DE REPUESTOS Y LOGÍSTICA',
          style: TextStyle(color: AppColors.royalBlue, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMobileForm() {
    return Column(
      children: [
        _buildTextField(
          hint: 'Usuario / Correo',
          icon: Icons.person_outline,
          controller: _emailController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          hint: 'Contraseña',
          icon: Icons.lock_outline,
          isPassword: true,
          controller: _passwordController,
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_off : Icons.visibility,
              color: AppColors.deepNavy.withOpacity(0.4),
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/solicitar-codigo'),
          child: const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(color: AppColors.royalBlue, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 24),
        _buildLoginButton(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'o',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBiometricButton(),
        const SizedBox(height: 16),
        _buildRegisterLink(),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [AppColors.deepNavy, AppColors.royalBlue],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.royalBlue.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : const Text(
            'Ingresar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.royalBlue.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: _handleBiometricLogin,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.fingerprint, color: AppColors.royalBlue, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Usar huella digital',
                style: TextStyle(
                  color: AppColors.deepNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "¿No tienes una cuenta? ",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/register'),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
          ),
          child: const Text(
            "Regístrate",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.royalBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeGearPositioned(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.height * 0.01,
          left: -size.width * 0.15,
          child: _buildDecorativeGear(size: size.width * 0.5, color: AppColors.electricBlue.withOpacity(0.6), angle: math.pi / 4),
        ),
        Positioned(
          top: size.height * 0.2,
          right: -size.width * 0.2,
          child: _buildDecorativeGear(size: size.width * 0.4, color: AppColors.royalBlue.withOpacity(0.8), angle: -math.pi / 6),
        ),
      ],
    );
  }

  Widget _buildDecorativeGear({required double size, required Color color, required double angle}) {
    return Transform.rotate(
      angle: angle,
      child: SizedBox(
        width: size,
        height: size,
        child: FittedBox(
          fit: BoxFit.fill,
          child: Icon(Icons.build, color: color),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    Widget? suffixIcon,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _isObscured : false,
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w600,
          fontSize: isDesktop ? 16 : 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: isDesktop ? 14 : 13,
          ),
          prefixIcon: Icon(icon, color: AppColors.royalBlue),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}