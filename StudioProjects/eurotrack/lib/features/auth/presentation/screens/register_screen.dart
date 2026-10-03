import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ==================== CONTROLADORES ====================
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ==================== CAMPOS EMPRESA ====================
  final _razonSocialController = TextEditingController();
  final _nitController = TextEditingController();
  final _registroMercantilController = TextEditingController();
  final _direccionFiscalController = TextEditingController();
  bool _contribuyenteEspecial = false;

  // ==================== CAMPOS TRANSPORTISTA ====================
  final _licenciaConducirController = TextEditingController();
  final _aniosExperienciaController = TextEditingController();
  String _tipoVehiculo = 'CAMION';

  final AuthService _authService = AuthService();

  String _selectedCedulaPrefix = 'V';
  String _selectedType = 'NATURAL';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // ==================== VALIDACIONES ====================
  bool _tieneMayuscula(String password) => password.contains(RegExp(r'[A-Z]'));
  bool _tieneMinuscula(String password) => password.contains(RegExp(r'[a-z]'));
  bool _tieneNumero(String password) => password.contains(RegExp(r'[0-9]'));
  bool _tieneEspecial(String password) => password.contains(RegExp(r'[!@#\$&*~]'));
  bool _tieneLongitud(String password) => password.length >= 8;

  bool get _passwordValida {
    final pass = _passwordController.text;
    return _tieneLongitud(pass) &&
        _tieneMayuscula(pass) &&
        _tieneMinuscula(pass) &&
        _tieneNumero(pass) &&
        _tieneEspecial(pass);
  }

  bool get _passwordsCoinciden {
    return _passwordController.text == _confirmPasswordController.text &&
        _confirmPasswordController.text.isNotEmpty;
  }

  bool get _formValido {
    final baseValid = _nombreController.text.isNotEmpty &&
        _cedulaController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordValida &&
        _passwordsCoinciden;

    if (_selectedType == 'JURIDICO') {
      return baseValid &&
          _razonSocialController.text.isNotEmpty &&
          _nitController.text.isNotEmpty;
    }

    if (_selectedType == 'TRANSPORTISTA') {
      return baseValid &&
          _licenciaConducirController.text.isNotEmpty &&
          _aniosExperienciaController.text.isNotEmpty;
    }

    return baseValid;
  }

  // ==================== REGISTRO ====================
  void _handleRegister() async {
    if (!_formValido) {
      _showSnackBar("Completa todos los campos correctamente", isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final String cedulaCompleta = "$_selectedCedulaPrefix-${_cedulaController.text.trim()}";

    Map<String, dynamic> registerData = {
      'nombre': _nombreController.text.trim(),
      'cedula': cedulaCompleta,
      'username': _usernameController.text.trim().toLowerCase(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'rol': 'CLIENTE',
      'tipoCliente': _selectedType,
      'telefono': _telefonoController.text.trim(),
    };

    if (_selectedType == 'JURIDICO') {
      registerData.addAll({
        'razonSocial': _razonSocialController.text.trim(),
        'nit': _nitController.text.trim(),
        'registroMercantil': _registroMercantilController.text.trim(),
        'direccionFiscal': _direccionFiscalController.text.trim(),
        'contribuyenteEspecial': _contribuyenteEspecial,
      });
    } else if (_selectedType == 'TRANSPORTISTA') {
      registerData.addAll({
        'licenciaConducir': _licenciaConducirController.text.trim(),
        'aniosExperiencia': int.tryParse(_aniosExperienciaController.text.trim()) ?? 0,
        'tipoVehiculo': _tipoVehiculo,
      });
    }

    final result = await _authService.register(registerData);

    setState(() => _isLoading = false);

    if (result == null) {
      _showSnackBar("Error de conexión. Intenta nuevamente.", isError: true);
      return;
    }

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      final errorMessage = result['error'] ?? "Error en el registro. Intenta nuevamente.";
      _showSnackBar(errorMessage, isError: true);
    }
  }

  void _showSnackBar(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "¡Registro exitoso!",
          style: TextStyle(color: Colors.green),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Tu cuenta ha sido creada correctamente."),
            SizedBox(height: 8),
            Text(
              "Ahora puedes iniciar sesión con tus credenciales.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Ir a iniciar sesión"),
          ),
        ],
      ),
    );
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: const Text("Registro"),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 24),
          _buildFormContent(),
        ],
      ),
    );
  }

  // ==================== LAYOUT ESCRITORIO (DISEÑO PREMIUM) ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // ✅ Panel izquierdo - Branding con diseño elegante
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
                      Container(
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
                          Icons.person_add_alt_1_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Crea tu cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 60,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Regístrate y accede a todos los beneficios de EuroTrack.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Beneficios
                      _buildFeatureItem(Icons.security, 'Cuenta segura'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.speed, 'Acceso rápido'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.support_agent, 'Soporte 24/7'),
                      const SizedBox(height: 12),
                      _buildFeatureItem(Icons.inventory_2, 'Gestión de productos'),
                      const Spacer(),
                      // Link a login
                      Row(
                        children: [
                          Text(
                            "¿Ya tienes una cuenta?",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              foregroundColor: AppColors.royalBlue,
                            ),
                            child: const Text(
                              "Inicia sesión",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // ✅ Panel derecho - Formulario
        Expanded(
          flex: 1,
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildFormContent(),
                    const SizedBox(height: 20),
                  ],
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
        Positioned(
          top: 120,
          right: 30,
          child: Transform.rotate(
            angle: 0.5,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.build,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          right: 40,
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

  // ==================== WIDGETS ====================
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
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.royalBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            size: 28,
            color: AppColors.royalBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Crear Cuenta",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              Text(
                "Completa todos los campos para registrarte",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormContent() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      children: [
        // Header
        if (isDesktop) ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 28,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Crear Cuenta",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepNavy,
                      ),
                    ),
                    Text(
                      "Completa todos los campos para registrarte",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // ========== TIPO DE CUENTA ==========
        _buildAccountTypeDropdown(),
        const SizedBox(height: 16),

        // ========== CAMPOS SEGÚN TIPO ==========
        _buildCamposEspecificos(),

        // ========== INFORMACIÓN PERSONAL ==========
        _buildSectionTitle("Información Personal"),
        const SizedBox(height: 8),
        _buildField(_nombreController, 'Nombre Completo', Icons.person_outline),
        const SizedBox(height: 12),
        _buildCedulaField(),
        const SizedBox(height: 12),
        _buildField(_telefonoController, 'Teléfono', Icons.phone_android, type: TextInputType.phone),

        const SizedBox(height: 20),

        // ========== DATOS DE ACCESO ==========
        _buildSectionTitle("Datos de Acceso"),
        const SizedBox(height: 8),
        _buildField(_usernameController, 'Usuario', Icons.alternate_email),
        const SizedBox(height: 12),
        _buildField(_emailController, 'Correo Electrónico', Icons.email_outlined, type: TextInputType.emailAddress),
        const SizedBox(height: 12),

        // ========== CONTRASEÑA ==========
        _buildPasswordField(),
        const SizedBox(height: 8),
        _buildPasswordValidationList(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        if (_confirmPasswordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordMatchIndicator(),
        ],

        const SizedBox(height: 32),

        // ========== BOTÓN DE REGISTRO ==========
        _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: AppColors.royalBlue),
        )
            : SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _formValido ? _handleRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _formValido ? AppColors.deepNavy : Colors.grey,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: _formValido ? 4 : 0,
              shadowColor: _formValido ? AppColors.deepNavy.withOpacity(0.3) : null,
            ),
            child: const Text(
              "FINALIZAR REGISTRO",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Link a login (solo en móvil)
        if (!isDesktop)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "¿Ya tienes una cuenta? ",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  "Inicia sesión",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ==================== WIDGETS REUTILIZABLES ====================
  Widget _buildSectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _buildField(
      TextEditingController c,
      String h,
      IconData i, {
        bool isPass = false,
        TextInputType type = TextInputType.text,
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
      ),
      child: TextField(
        controller: c,
        obscureText: isPass ? !_isPasswordVisible : false,
        keyboardType: type,
        onChanged: (_) => setState(() {}),
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          color: AppColors.deepNavy,
        ),
        decoration: InputDecoration(
          hintText: h,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: isDesktop ? 14 : 12,
          ),
          prefixIcon: Icon(i, color: AppColors.royalBlue),
          suffixIcon: isPass
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildAccountTypeDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: DropdownButtonFormField<String>(
      value: _selectedType,
      items: const [
        DropdownMenuItem(value: 'NATURAL', child: Text('👤 Persona Natural')),
        DropdownMenuItem(value: 'JURIDICO', child: Text('🏢 Empresa (Jurídico)')),
        DropdownMenuItem(value: 'TRANSPORTISTA', child: Text('🚛 Transportista')),
      ],
      onChanged: (v) => setState(() => _selectedType = v!),
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: "Tipo de Cuenta",
        labelStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  Widget _buildCamposEspecificos() {
    if (_selectedType == 'JURIDICO') {
      return Column(
        children: [
          _buildSectionTitle("Datos de la Empresa"),
          const SizedBox(height: 8),
          _buildField(_razonSocialController, 'Razón Social', Icons.business),
          const SizedBox(height: 12),
          _buildField(_nitController, 'NIT', Icons.numbers),
          const SizedBox(height: 12),
          _buildField(_registroMercantilController, 'Registro Mercantil', Icons.description),
          const SizedBox(height: 12),
          _buildField(_direccionFiscalController, 'Dirección Fiscal', Icons.location_on),
          const SizedBox(height: 12),
          _buildContribuyenteEspecialSwitch(),
          const SizedBox(height: 20),
        ],
      );
    } else if (_selectedType == 'TRANSPORTISTA') {
      return Column(
        children: [
          _buildSectionTitle("Datos del Transportista"),
          const SizedBox(height: 8),
          _buildField(_licenciaConducirController, 'Licencia de Conducir', Icons.credit_card),
          const SizedBox(height: 12),
          _buildField(
            _aniosExperienciaController,
            'Años de Experiencia',
            Icons.timer,
            type: TextInputType.number,
          ),
          const SizedBox(height: 12),
          _buildTipoVehiculoDropdown(),
          const SizedBox(height: 20),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildContribuyenteEspecialSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt, color: AppColors.royalBlue),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Contribuyente Especial',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: _contribuyenteEspecial,
            onChanged: (value) => setState(() => _contribuyenteEspecial = value),
            activeColor: AppColors.royalBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTipoVehiculoDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: DropdownButtonFormField<String>(
      value: _tipoVehiculo,
      items: const [
        DropdownMenuItem(value: 'CAMION', child: Text('🚛 Camión')),
        DropdownMenuItem(value: 'FURGON', child: Text('🚐 Furgón')),
        DropdownMenuItem(value: 'TRAILER', child: Text('🚚 Tráiler')),
        DropdownMenuItem(value: 'MOTO', child: Text('🏍️ Moto')),
      ],
      onChanged: (v) => setState(() => _tipoVehiculo = v!),
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: "Tipo de Vehículo",
        labelStyle: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  Widget _buildCedulaField() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: DropdownButton<String>(
            value: _selectedCedulaPrefix,
            underline: const SizedBox(),
            items: ['V', 'E', 'J', 'G', 'P'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _selectedCedulaPrefix = v!),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: TextField(
            controller: _cedulaController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              color: AppColors.deepNavy,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Cédula/RIF',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPasswordField() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Contraseña',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.royalBlue),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );

  Widget _buildConfirmPasswordField() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: _confirmPasswordController.text.isNotEmpty
            ? (_passwordsCoinciden ? Colors.green : Colors.red)
            : Colors.grey.shade200,
        width: 1.5,
      ),
    ),
    child: TextField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(
        color: AppColors.deepNavy,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Confirmar Contraseña',
        hintStyle: TextStyle(color: Colors.grey.shade400),
        prefixIcon: Icon(
          _confirmPasswordController.text.isNotEmpty
              ? (_passwordsCoinciden ? Icons.check_circle : Icons.error_outline)
              : Icons.lock_outline,
          color: _confirmPasswordController.text.isNotEmpty
              ? (_passwordsCoinciden ? Colors.green : Colors.red)
              : AppColors.royalBlue,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    ),
  );

  Widget _buildPasswordValidationList() {
    final pass = _passwordController.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationCheck("Mínimo 8 caracteres", _tieneLongitud(pass)),
        _buildValidationCheck("Una mayúscula", _tieneMayuscula(pass)),
        _buildValidationCheck("Una minúscula", _tieneMinuscula(pass)),
        _buildValidationCheck("Un número", _tieneNumero(pass)),
        _buildValidationCheck("Un carácter especial (!@#\$&*~)", _tieneEspecial(pass)),
      ],
    );
  }

  Widget _buildValidationCheck(String text, bool met) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            color: met ? Colors.green : Colors.grey.shade400,
            size: 16,
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

  Widget _buildPasswordMatchIndicator() {
    return Row(
      children: [
        Icon(
          _passwordsCoinciden ? Icons.check_circle : Icons.error_outline,
          color: _passwordsCoinciden ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 8),
        Text(
          _passwordsCoinciden ? "Las contraseñas coinciden ✅" : "Las contraseñas no coinciden ❌",
          style: TextStyle(
            color: _passwordsCoinciden ? Colors.green : Colors.red,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}