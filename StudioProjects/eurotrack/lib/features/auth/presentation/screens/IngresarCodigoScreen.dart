import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';
import 'package:eurotrack/features/auth/presentation/screens/CambiarPasswordConCodigoScreen.dart';

class IngresarCodigoScreen extends StatefulWidget {
  final String? email;
  final String? cedula;

  const IngresarCodigoScreen({
    super.key,
    this.email,
    this.cedula,
  });

  @override
  State<IngresarCodigoScreen> createState() => _IngresarCodigoScreenState();
}

class _IngresarCodigoScreenState extends State<IngresarCodigoScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _codigoController = TextEditingController();

  bool _isLoading = false;
  bool _isReenviando = false;
  String? _errorMessage;
  String? _successMessage;

  String _limpiarCodigo(String codigo) {
    return codigo.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  }

  Future<void> _verificarCodigo() async {
    String codigo = _codigoController.text.trim();
    String codigoLimpio = _limpiarCodigo(codigo);

    if (codigoLimpio.isEmpty) {
      setState(() => _errorMessage = "Ingresa el código de verificación");
      return;
    }

    if (codigoLimpio.length != 8) {
      setState(() => _errorMessage = "El código debe tener 8 caracteres (ej: 4A2B8C1D)");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await _authService.verificarCodigo(codigoLimpio);

    setState(() => _isLoading = false);

    if (result != null && result['valido'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CambiarPasswordConCodigoScreen(
            token: codigoLimpio,
            email: result['email'] ?? widget.email ?? '',
          ),
        ),
      );
    } else if (result != null && result['error'] != null) {
      setState(() => _errorMessage = result['error']);
    } else {
      setState(() => _errorMessage = "Error al verificar el código");
    }
  }

  Future<void> _reenviarCodigo() async {
    if (widget.email == null || widget.email!.isEmpty) {
      setState(() => _errorMessage = "No tenemos tu email. Ve a la pantalla anterior.");
      return;
    }

    if (widget.cedula == null || widget.cedula!.isEmpty) {
      setState(() => _errorMessage = "No tenemos tu cédula. Ve a la pantalla anterior.");
      return;
    }

    setState(() {
      _isReenviando = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final result = await _authService.solicitarRecuperacion(
      widget.email!,
      widget.cedula!,
    );

    setState(() => _isReenviando = false);

    if (result != null && result['error'] == null) {
      setState(() {
        _successMessage = "✅ Nuevo código enviado a ${widget.email}";
        _errorMessage = null;
        _codigoController.clear();
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _successMessage = null);
        }
      });
    } else if (result != null && result['error'] != null) {
      setState(() => _errorMessage = result['error']);
    } else {
      setState(() => _errorMessage = "Error al reenviar el código");
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
          title: const Text("Verificar Código"),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        _buildCodeField(),
        const SizedBox(height: 16),
        _buildMessages(),
        const SizedBox(height: 16),
        _buildReenviarButton(),
        const SizedBox(height: 24),
        _buildVerifyButton(),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildCodeField(),
            const SizedBox(height: 16),
            _buildMessages(),
            const SizedBox(height: 16),
            _buildReenviarButton(),
            const SizedBox(height: 24),
            _buildVerifyButton(),
          ],
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.deepNavy.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.verified,
            size: 50,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Ingresa el código de verificación",
          style: TextStyle(
            fontSize: isDesktop ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
        ),
        if (widget.email != null) ...[
          const SizedBox(height: 8),
          Text(
            "Enviamos el código a: ${widget.email}",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: isDesktop ? 15 : 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ==================== CAMPO DE CÓDIGO ====================
  Widget _buildCodeField() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _codigoController,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 28 : 24,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: AppColors.deepNavy,
          ),
          decoration: InputDecoration(
            hintText: "4A2B 8C1D",
            hintStyle: TextStyle(
              fontSize: isDesktop ? 18 : 16,
              fontWeight: FontWeight.normal,
              color: Colors.grey.shade400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.deepNavy, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            suffixText: _codigoController.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').length >= 8 ? '✅' : null,
            suffixStyle: TextStyle(
              fontSize: isDesktop ? 24 : 20,
            ),
          ),
          onChanged: (value) {
            String limpiado = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
            if (limpiado.length > 8) {
              limpiado = limpiado.substring(0, 8);
            }

            String formateado = '';
            for (int i = 0; i < limpiado.length; i++) {
              if (i == 4 && limpiado.length > 4) {
                formateado += ' ';
              }
              formateado += limpiado[i];
            }

            if (value != formateado) {
              _codigoController.value = TextEditingValue(
                text: formateado,
                selection: TextSelection.collapsed(offset: formateado.length),
              );
            }

            if (_errorMessage != null || _successMessage != null) {
              setState(() {
                _errorMessage = null;
                _successMessage = null;
              });
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 6),
            Text(
              "Código de 8 caracteres (ej: 4A2B 8C1D)",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              "${_codigoController.text.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').length}/8",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== MENSAJES ====================
  Widget _buildMessages() {
    if (_successMessage != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _successMessage!,
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
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
      );
    }

    return const SizedBox.shrink();
  }

  // ==================== REENVIAR CÓDIGO ====================
  Widget _buildReenviarButton() {
    return TextButton(
      onPressed: _isReenviando ? null : _reenviarCodigo,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        minimumSize: const Size(0, 0),
      ),
      child: _isReenviando
          ? const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.deepNavy,
            ),
          ),
          SizedBox(width: 12),
          Text("Reenviando..."),
        ],
      )
          : const Text(
        "¿No recibiste el código? Solicita uno nuevo",
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ==================== VERIFICAR CÓDIGO ====================
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _verificarCodigo,
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
          "Verificar código",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}