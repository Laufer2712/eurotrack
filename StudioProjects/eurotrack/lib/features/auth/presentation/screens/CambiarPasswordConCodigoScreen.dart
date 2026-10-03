import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';

class CambiarPasswordConCodigoScreen extends StatefulWidget {
  final String token;
  final String email;

  const CambiarPasswordConCodigoScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<CambiarPasswordConCodigoScreen> createState() => _CambiarPasswordConCodigoScreenState();
}

class _CambiarPasswordConCodigoScreenState extends State<CambiarPasswordConCodigoScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nuevaPasswordController = TextEditingController();
  final TextEditingController _confirmarPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  bool _esContrasenaSegura(String password) {
    final regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    return regex.hasMatch(password);
  }

  bool _lasContrasenasCoinciden() {
    return _confirmarPasswordController.text.isNotEmpty &&
        _nuevaPasswordController.text == _confirmarPasswordController.text;
  }

  Future<void> _cambiarPassword() async {
    String pass = _nuevaPasswordController.text.trim();

    if (!_esContrasenaSegura(pass)) {
      setState(() => _errorMessage = "La contraseña no cumple los requisitos de seguridad");
      return;
    }

    if (pass != _confirmarPasswordController.text.trim()) {
      setState(() => _errorMessage = "Las contraseñas no coinciden");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.cambiarConCodigo(widget.token, pass);

    setState(() => _isLoading = false);

    if (result != null && result['error'] == null) {
      _showSuccessDialog();
    } else if (result != null && result['error'] != null) {
      setState(() => _errorMessage = result['error']);
    } else {
      setState(() => _errorMessage = "Error al cambiar la contraseña");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            const Text(
              "¡Contraseña actualizada!",
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Tu contraseña ha sido cambiada exitosamente."),
            SizedBox(height: 8),
            Text(
              "Ahora puedes iniciar sesión con tu nueva contraseña.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
                  (route) => false,
            ),
            child: const Text(
              "Ir a iniciar sesión",
              style: TextStyle(color: AppColors.royalBlue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: const Text(
            "Crear Nueva Contraseña",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            padding: EdgeInsets.all(isDesktop ? 40 : 24),
            child: SingleChildScrollView(
              child: isDesktop ? _buildDesktopContent() : _buildMobileContent(),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildPasswordFields(),
        const SizedBox(height: 24),
        _buildSubmitButton(),
      ],
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopContent() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildPasswordFields(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Crear Nueva Contraseña",
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Usuario: ${widget.email}",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isDesktop ? 15 : 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== CAMPOS DE CONTRASEÑA ====================
  Widget _buildPasswordFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nueva contraseña
        TextField(
          controller: _nuevaPasswordController,
          obscureText: _obscurePassword,
          onChanged: (_) {
            setState(() {
              if (_errorMessage == "Las contraseñas no coinciden" ||
                  _errorMessage == "La contraseña no cumple los requisitos de seguridad") {
                _errorMessage = null;
              }
            });
          },
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
          decoration: InputDecoration(
            labelText: "Nueva contraseña",
            labelStyle: TextStyle(
              fontSize: isDesktop ? 15 : 13,
            ),
            hintText: "Mínimo 8 caracteres",
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.deepNavy),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
        const SizedBox(height: 12),

        // Validaciones de contraseña
        _buildPasswordValidationList(_nuevaPasswordController.text),

        const SizedBox(height: 16),

        // Confirmar contraseña
        TextField(
          controller: _confirmarPasswordController,
          obscureText: _obscureConfirm,
          onChanged: (_) {
            setState(() {
              if (_errorMessage == "Las contraseñas no coinciden") {
                _errorMessage = null;
              }
            });
          },
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
          ),
          decoration: InputDecoration(
            labelText: "Confirmar contraseña",
            labelStyle: TextStyle(
              fontSize: isDesktop ? 15 : 13,
            ),
            prefixIcon: Icon(
              _confirmarPasswordController.text.isNotEmpty
                  ? (_lasContrasenasCoinciden() ? Icons.check_circle : Icons.error_outline)
                  : Icons.lock_outline,
              color: _confirmarPasswordController.text.isNotEmpty
                  ? (_lasContrasenasCoinciden() ? Colors.green : Colors.red)
                  : AppColors.deepNavy,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),

        // Indicador visual de coincidencia
        if (_confirmarPasswordController.text.isNotEmpty && _errorMessage != "Las contraseñas no coinciden") ...[
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _lasContrasenasCoinciden()
                  ? Colors.green.withOpacity(0.08)
                  : Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _lasContrasenasCoinciden()
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _lasContrasenasCoinciden()
                      ? Icons.check_circle
                      : Icons.error_outline,
                  color: _lasContrasenasCoinciden()
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _lasContrasenasCoinciden()
                      ? "Las contraseñas coinciden ✅"
                      : "Las contraseñas no coinciden ❌",
                  style: TextStyle(
                    color: _lasContrasenasCoinciden()
                        ? Colors.green
                        : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Mensaje de error
        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ==================== BOTÓN DE ENVÍO ====================
  Widget _buildSubmitButton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return SizedBox(
      width: isDesktop ? double.infinity : double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cambiarPassword,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: Colors.green.withOpacity(0.3),
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
          "Cambiar contraseña",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ==================== VALIDACIONES ====================
  Widget _buildPasswordValidationList(String password) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCheck("Mínimo 8 caracteres", password.length >= 8),
        _buildCheck("Una mayúscula", password.contains(RegExp(r'[A-Z]'))),
        _buildCheck("Una minúscula", password.contains(RegExp(r'[a-z]'))),
        _buildCheck("Un número", password.contains(RegExp(r'[0-9]'))),
        _buildCheck("Un carácter especial (!@#\$&*~)", password.contains(RegExp(r'[!@#\$&*~]'))),
      ],
    );
  }

  Widget _buildCheck(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              met ? Icons.check_circle : Icons.circle_outlined,
              color: met ? Colors.green : Colors.grey.shade400,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: met ? Colors.green : Colors.grey.shade500,
              fontSize: 12,
              fontWeight: met ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}