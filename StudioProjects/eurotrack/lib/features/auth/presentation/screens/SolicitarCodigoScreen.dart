import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';

class SolicitarCodigoScreen extends StatefulWidget {
  const SolicitarCodigoScreen({super.key});

  @override
  State<SolicitarCodigoScreen> createState() => _SolicitarCodigoScreenState();
}

class _SolicitarCodigoScreenState extends State<SolicitarCodigoScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _codigoEnviado = false;
  String? _emailEnviado;
  String? _cedulaEnviada;

  Future<void> _solicitarCodigo() async {
    String email = _emailController.text.trim();
    String cedula = _cedulaController.text.trim();

    if (email.isEmpty || cedula.isEmpty) {
      setState(() => _errorMessage = "Todos los campos son obligatorios");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.solicitarRecuperacion(email, cedula);

    setState(() => _isLoading = false);

    if (result != null && result['error'] == null) {
      setState(() {
        _codigoEnviado = true;
        _emailEnviado = email;
        _cedulaEnviada = cedula;
        _errorMessage = null;
      });
    } else if (result != null && result['error'] != null) {
      setState(() => _errorMessage = result['error']);
    } else {
      setState(() => _errorMessage = "Error al procesar la solicitud");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: const Text("Recuperar Contraseña"),
          backgroundColor: AppColors.deepNavy,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 500 : double.infinity,
            ),
            padding: EdgeInsets.all(isDesktop ? 40 : 24),
            child: SingleChildScrollView(
              child: _codigoEnviado ? _buildCodigoEnviado() : _buildFormulario(),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FORMULARIO ====================
  Widget _buildFormulario() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.deepNavy.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 50,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Recupera tu contraseña",
          style: TextStyle(
            fontSize: isDesktop ? 26 : 22,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Ingresa tu email y cédula para recibir un código de verificación",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isDesktop ? 15 : 14,
          ),
        ),
        const SizedBox(height: 32),

        // Email
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(
              fontSize: isDesktop ? 15 : 13,
            ),
            hintText: "ejemplo@correo.com",
            prefixIcon: const Icon(Icons.email, color: AppColors.deepNavy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 16),

        // Cédula
        TextField(
          controller: _cedulaController,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
          decoration: InputDecoration(
            labelText: "Cédula",
            labelStyle: TextStyle(
              fontSize: isDesktop ? 15 : 13,
            ),
            hintText: "12345678",
            prefixIcon: const Icon(Icons.badge, color: AppColors.deepNavy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),

        // Mensaje de error
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Botón enviar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _solicitarCodigo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deepNavy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: AppColors.deepNavy.withOpacity(0.3),
            ),
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
              "Enviar código de verificación",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text(
            "Volver al inicio de sesión",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  // ==================== CÓDIGO ENVIADO ====================
  Widget _buildCodigoEnviado() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icono de éxito
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 60,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "¡Código enviado!",
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Hemos enviado un código de verificación a:\n$_emailEnviado",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 15,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Revisa tu bandeja de entrada. El código expirará en 15 minutos.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: isDesktop ? 14 : 13,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text("Volver"),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final cedulaLimpia = _cedulaEnviada?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                  Navigator.pushReplacementNamed(
                    context,
                    '/ingresar-codigo',
                    arguments: {
                      'email': _emailEnviado,
                      'cedula': cedulaLimpia,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: AppColors.deepNavy.withOpacity(0.3),
                ),
                child: const Text(
                  "Ingresar código",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}