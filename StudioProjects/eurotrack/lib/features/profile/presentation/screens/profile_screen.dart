import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/auth/data/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/network/api_config.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eurotrack/features/profile/presentation/widgets/CollapsibleSection.dart';
import 'package:eurotrack/features/profile/presentation/widgets/HiddenInfoField.dart';
import 'package:eurotrack/features/profile/presentation/widgets/ValidatedHiddenInfoField.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String nombreInicial;
  final String usernameInicial;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.nombreInicial,
    required this.usernameInicial,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userProfileFuture;
  final ImagePicker _picker = ImagePicker();

  Uint8List? _selectedImageBytes; // ✅ Para web y móvil
  String? _base64Image;
  bool _isSavingImage = false;

  // ✅ Guardar la foto actual para no perderla
  String? _currentFotoPerfil;

  // Controladores comunes
  TextEditingController? _nameController;
  TextEditingController? _userController;
  TextEditingController? _emailController;
  TextEditingController? _telefonoController;

  // Controladores para JURIDICO
  TextEditingController? _razonSocialController;
  TextEditingController? _nitController;
  TextEditingController? _registroMercantilController;
  TextEditingController? _direccionFiscalController;
  bool _contribuyenteEspecial = false;

  // Controladores para TRANSPORTISTA
  TextEditingController? _licenciaConducirController;
  TextEditingController? _aniosExperienciaController;
  String _tipoVehiculo = 'CAMION';

  final String _baseUrl = ApiConfig.authEndpoint;
  String _tipoCliente = 'NATURAL';
  Map<String, dynamic> _userData = {};

  // Estados de guardado por sección
  bool _isSavingPersonal = false;
  bool _isSavingJuridico = false;
  bool _isSavingTransportista = false;

  // Estados de validación
  bool _isUsernameValid = true;
  bool _isEmailValid = true;
  bool _isUsernameChecking = false;
  bool _isEmailChecking = false;
  String _usernameError = '';
  String _emailError = '';

  @override
  void initState() {
    super.initState();
    _userProfileFuture = _fetchUserData();
  }

  // ✅ Método para recargar el perfil
  void _refreshProfile() {
    setState(() {
      _userProfileFuture = _fetchUserData();
    });
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    final String url = "$_baseUrl/profile/${widget.userId}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _tipoCliente = data['tipoCliente'] ?? 'NATURAL';
        _userData = data;
        _currentFotoPerfil = data['fotoPerfil'];
        return data;
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  // ✅ UNIVERSAL: Funciona en web y móvil
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 500,
        maxHeight: 500,
      );

      if (image != null) {
        // ✅ Leer la imagen como bytes (funciona en web y móvil)
        final bytes = await image.readAsBytes();

        setState(() {
          _selectedImageBytes = bytes;
          _base64Image = base64Encode(bytes);
        });

        await _guardarFotoPerfil();
      }
    } catch (e) {
      print('❌ Error al seleccionar imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _guardarFotoPerfil() async {
    if (_base64Image == null || _base64Image!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ No hay imagen seleccionada'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSavingImage = true);

    final String url = "$_baseUrl/update-profile/${widget.userId}";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "fotoPerfil": _base64Image,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto de perfil actualizada'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
          // ✅ Recargar el perfil
          _currentFotoPerfil = _base64Image;
          _refreshProfile();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Error al guardar la foto de perfil'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error al guardar foto: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error de conexión: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    setState(() => _isSavingImage = false);
  }

  // ========== MÉTODOS DE VALIDACIÓN ==========

  void _onUsernameChanged(String value) {
    final originalUsername = _userData['username'] ?? '';
    if (value == originalUsername) {
      setState(() {
        _isUsernameValid = true;
        _usernameError = '';
        _isUsernameChecking = false;
      });
      return;
    }

    if (value.trim().length < 3) {
      setState(() {
        _isUsernameValid = false;
        _usernameError = 'El usuario debe tener al menos 3 caracteres';
        _isUsernameChecking = false;
      });
      return;
    }

    if (value.contains(' ')) {
      setState(() {
        _isUsernameValid = false;
        _usernameError = 'El usuario no puede contener espacios';
        _isUsernameChecking = false;
      });
      return;
    }

    setState(() => _isUsernameChecking = true);
    _checkUsernameUniqueness(value);
  }

  Future<void> _checkUsernameUniqueness(String username) async {
    try {
      final url = Uri.parse('$_baseUrl/verificar-username');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username": username.trim(),
          "userId": widget.userId,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final bool isAvailable = data['available'] == true;
          setState(() {
            _isUsernameValid = isAvailable;
            _isUsernameChecking = false;
            _usernameError = isAvailable ? '' : '❌ El usuario ya está en uso';
          });
        } else {
          setState(() {
            _isUsernameValid = true;
            _isUsernameChecking = false;
            _usernameError = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUsernameValid = true;
          _isUsernameChecking = false;
          _usernameError = '';
        });
      }
    }
  }

  void _onEmailChanged(String value) {
    final originalEmail = _userData['email'] ?? '';
    if (value == originalEmail) {
      setState(() {
        _isEmailValid = true;
        _emailError = '';
        _isEmailChecking = false;
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      setState(() {
        _isEmailValid = false;
        _emailError = 'Ingresa un email válido';
        _isEmailChecking = false;
      });
      return;
    }

    setState(() => _isEmailChecking = true);
    _checkEmailUniqueness(value);
  }

  Future<void> _checkEmailUniqueness(String email) async {
    try {
      final url = Uri.parse('$_baseUrl/verificar-email');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": email.trim(),
          "userId": widget.userId,
        }),
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final bool isAvailable = data['available'] == true;
          setState(() {
            _isEmailValid = isAvailable;
            _isEmailChecking = false;
            _emailError = isAvailable ? '' : '❌ El email ya está registrado';
          });
        } else {
          setState(() {
            _isEmailValid = true;
            _isEmailChecking = false;
            _emailError = '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEmailValid = true;
          _isEmailChecking = false;
          _emailError = '';
        });
      }
    }
  }

  bool get _canSavePersonal {
    return _nameController?.text.trim().isNotEmpty == true &&
        _userController?.text.trim().isNotEmpty == true &&
        _emailController?.text.trim().isNotEmpty == true &&
        _isUsernameValid &&
        _isEmailValid &&
        !_isUsernameChecking &&
        !_isEmailChecking;
  }

  // ========== MÉTODOS DE GUARDADO ==========

  Future<void> _guardarPersonal() async {
    if (!_canSavePersonal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Corrige los errores antes de guardar'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSavingPersonal = true);
    await _guardarSeccion({
      "nombre": _nameController?.text ?? '',
      "username": _userController?.text ?? '',
      "telefono": _telefonoController?.text ?? '',
      "fotoPerfil": _base64Image ?? _currentFotoPerfil ?? '',
    }, 'Información personal');
    setState(() => _isSavingPersonal = false);
  }

  Future<void> _guardarJuridico() async {
    if (!_canSavePersonal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Corrige los errores antes de guardar'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSavingJuridico = true);
    await _guardarSeccion({
      "nombre": _nameController?.text ?? '',
      "username": _userController?.text ?? '',
      "telefono": _telefonoController?.text ?? '',
      "fotoPerfil": _base64Image ?? _currentFotoPerfil ?? '',
      "razonSocial": _razonSocialController?.text ?? '',
      "nit": _nitController?.text ?? '',
      "registroMercantil": _registroMercantilController?.text ?? '',
      "direccionFiscal": _direccionFiscalController?.text ?? '',
      "contribuyenteEspecial": _contribuyenteEspecial,
    }, 'Datos de la empresa');
    setState(() => _isSavingJuridico = false);
  }

  Future<void> _guardarTransportista() async {
    if (!_canSavePersonal) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Corrige los errores antes de guardar'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isSavingTransportista = true);
    await _guardarSeccion({
      "nombre": _nameController?.text ?? '',
      "username": _userController?.text ?? '',
      "telefono": _telefonoController?.text ?? '',
      "fotoPerfil": _base64Image ?? _currentFotoPerfil ?? '',
      "licenciaConducir": _licenciaConducirController?.text ?? '',
      "aniosExperiencia": int.tryParse(_aniosExperienciaController?.text ?? '0') ?? 0,
      "tipoVehiculo": _tipoVehiculo,
    }, 'Datos del transportista');
    setState(() => _isSavingTransportista = false);
  }

  Future<void> _guardarSeccion(Map<String, dynamic> body, String seccion) async {
    final String url = "$_baseUrl/update-profile/${widget.userId}";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ $seccion actualizada exitosamente"),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
          _refreshProfile();
        }
      } else {
        if (mounted) {
          String errorMessage = 'Error al guardar $seccion';
          try {
            final errorData = json.decode(response.body);
            if (errorData['error'] != null) {
              errorMessage = errorData['error'];
            }
          } catch (_) {}
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ $errorMessage"),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error de conexión al guardar $seccion"),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: _buildAppBar(),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _userProfileFuture,
          key: ValueKey(_userProfileFuture),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.royalBlue));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildErrorState();
            }

            final data = snapshot.data!;
            _tipoCliente = data['tipoCliente'] ?? 'NATURAL';
            _currentFotoPerfil = data['fotoPerfil'];

            _nameController ??= TextEditingController(text: data['nombre'] ?? '');
            _userController ??= TextEditingController(text: data['username'] ?? '');
            _emailController ??= TextEditingController(text: data['email'] ?? '');
            _telefonoController ??= TextEditingController(text: data['telefono'] ?? '');

            if (!_userController!.hasListeners) {
              _userController!.addListener(() {
                _onUsernameChanged(_userController!.text);
              });
            }
            if (!_emailController!.hasListeners) {
              _emailController!.addListener(() {
                _onEmailChanged(_emailController!.text);
              });
            }

            if (_tipoCliente == 'JURIDICO') {
              _razonSocialController ??= TextEditingController(text: data['razonSocial'] ?? '');
              _nitController ??= TextEditingController(text: data['nit'] ?? '');
              _registroMercantilController ??= TextEditingController(text: data['registroMercantil'] ?? '');
              _direccionFiscalController ??= TextEditingController(text: data['direccionFiscal'] ?? '');
              _contribuyenteEspecial = data['contribuyenteEspecial'] ?? false;
            }

            if (_tipoCliente == 'TRANSPORTISTA') {
              _licenciaConducirController ??= TextEditingController(text: data['licenciaConducir'] ?? '');
              _aniosExperienciaController ??= TextEditingController(text: data['aniosExperiencia']?.toString() ?? '');
              _tipoVehiculo = data['tipoVehiculo'] ?? 'CAMION';
            }

            return isDesktop ? _buildDesktopLayout(data) : _buildMobileLayout(data);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No se pudo cargar el perfil",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _refreshProfile();
            },
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout(Map<String, dynamic> data) {
    return SingleChildScrollView(
      child: _buildContent(data),
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout(Map<String, dynamic> data) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: _buildContent(data),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CONTENIDO COMPARTIDO ====================
  Widget _buildContent(Map<String, dynamic> data) {
    String rolRaw = (data['rol'] ?? 'CLIENTE').toString().toUpperCase();
    String displayRol = rolRaw == "ADMIN" ? "Administrador" : rolRaw;

    String tipoClienteLabel = _getTipoClienteLabel(_tipoCliente);
    IconData tipoIcon = _getTipoClienteIcon(_tipoCliente);
    Color tipoColor = _getTipoClienteColor(_tipoCliente);

    return Column(
      children: [
        // Header
        _buildProfileHeader(
          data['nombre'] ?? 'Usuario',
          displayRol,
          _currentFotoPerfil,
          tipoClienteLabel,
          tipoIcon,
          tipoColor,
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Información rápida
              _buildQuickInfoCard(data['cedula'] ?? 'N/A', tipoClienteLabel, displayRol),
              const SizedBox(height: 20),

              // ========== SECCIÓN PERSONAL ==========
              CollapsibleSection(
                title: 'Información Personal',
                icon: Icons.person_outline,
                iconColor: Colors.blue,
                initiallyExpanded: false,
                children: [
                  _buildPersonalSection(data),
                  const SizedBox(height: 12),
                  _buildSectionSaveButton(
                    onPressed: _guardarPersonal,
                    isLoading: _isSavingPersonal,
                    label: 'Guardar Personal',
                    isValid: _canSavePersonal,
                  ),
                ],
              ),

              // ========== SECCIÓN JURÍDICO ==========
              if (_tipoCliente == 'JURIDICO')
                CollapsibleSection(
                  title: 'Datos de la Empresa',
                  icon: Icons.business,
                  iconColor: Colors.purple,
                  initiallyExpanded: false,
                  children: [
                    _buildJuridicoSection(),
                    const SizedBox(height: 12),
                    _buildSectionSaveButton(
                      onPressed: _guardarJuridico,
                      isLoading: _isSavingJuridico,
                      label: 'Guardar Empresa',
                      isValid: _canSavePersonal,
                    ),
                  ],
                ),

              // ========== SECCIÓN TRANSPORTISTA ==========
              if (_tipoCliente == 'TRANSPORTISTA')
                CollapsibleSection(
                  title: 'Datos del Transportista',
                  icon: Icons.delivery_dining,
                  iconColor: Colors.orange,
                  initiallyExpanded: false,
                  children: [
                    _buildTransportistaSection(),
                    const SizedBox(height: 12),
                    _buildSectionSaveButton(
                      onPressed: _guardarTransportista,
                      isLoading: _isSavingTransportista,
                      label: 'Guardar Transportista',
                      isValid: _canSavePersonal,
                    ),
                  ],
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ========== APP BAR ==========
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.deepNavy,
      title: const Text(
        "Mi Perfil",
        style: TextStyle(
          color: AppColors.deepNavy,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            await AuthService().logout();
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }
          },
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Cerrar sesión',
        ),
      ],
    );
  }

  // ========== BOTÓN DE GUARDADO ==========
  Widget _buildSectionSaveButton({
    required VoidCallback onPressed,
    required bool isLoading,
    required String label,
    required bool isValid,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? AppColors.deepNavy : Colors.grey.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: (isLoading || !isValid) ? null : onPressed,
        icon: isLoading
            ? SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Icon(
          isValid ? Icons.save_outlined : Icons.warning_amber_rounded,
          size: 20,
        ),
        label: Text(
          isLoading ? 'Guardando...' : label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ========== SECCIONES ==========
  Widget _buildPersonalSection(Map<String, dynamic> data) {
    return Column(
      children: [
        HiddenInfoField(
          label: 'Nombre Completo',
          value: data['nombre'] ?? '',
          icon: Icons.person_outline,
          isEditable: true,
          controller: _nameController,
        ),
        ValidatedHiddenInfoField(
          label: 'Nombre de Usuario',
          value: data['username'] ?? '',
          icon: Icons.alternate_email,
          isEditable: true,
          controller: _userController,
          userId: widget.userId,
          validationType: 'username',
          isRequired: true,
        ),
        ValidatedHiddenInfoField(
          label: 'Correo Electrónico',
          value: data['email'] ?? '',
          icon: Icons.email_outlined,
          isEditable: true,
          controller: _emailController,
          userId: widget.userId,
          validationType: 'email',
          isRequired: true,
        ),
        HiddenInfoField(
          label: 'Teléfono',
          value: data['telefono'] ?? '',
          icon: Icons.phone_outlined,
          isEditable: true,
          controller: _telefonoController,
        ),
      ],
    );
  }

  Widget _buildJuridicoSection() {
    return Column(
      children: [
        HiddenInfoField(
          label: 'Razón Social',
          value: _userData['razonSocial'] ?? '',
          icon: Icons.business,
          isEditable: true,
          controller: _razonSocialController,
        ),
        HiddenInfoField(
          label: 'NIT',
          value: _userData['nit'] ?? '',
          icon: Icons.numbers,
          isEditable: true,
          controller: _nitController,
        ),
        HiddenInfoField(
          label: 'Registro Mercantil',
          value: _userData['registroMercantil'] ?? '',
          icon: Icons.description,
          isEditable: true,
          controller: _registroMercantilController,
        ),
        HiddenInfoField(
          label: 'Dirección Fiscal',
          value: _userData['direccionFiscal'] ?? '',
          icon: Icons.location_on,
          isEditable: true,
          controller: _direccionFiscalController,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: _contribuyenteEspecial ? Colors.amber.shade700 : Colors.grey.shade400,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contribuyente Especial',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _contribuyenteEspecial
                          ? '✅ Activo (8% IVA)'
                          : '❌ Inactivo (16% IVA)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _contribuyenteEspecial ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _contribuyenteEspecial,
                onChanged: (value) {
                  setState(() => _contribuyenteEspecial = value);
                },
                activeColor: AppColors.royalBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportistaSection() {
    return Column(
      children: [
        HiddenInfoField(
          label: 'Licencia de Conducir',
          value: _userData['licenciaConducir'] ?? '',
          icon: Icons.credit_card,
          isEditable: true,
          controller: _licenciaConducirController,
        ),
        HiddenInfoField(
          label: 'Años de Experiencia',
          value: _userData['aniosExperiencia']?.toString() ?? '',
          icon: Icons.timer,
          isEditable: true,
          controller: _aniosExperienciaController,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonFormField<String>(
            value: _tipoVehiculo,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Tipo de Vehículo',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              prefixIcon: Icon(Icons.directions_car, color: AppColors.royalBlue),
            ),
            items: const [
              DropdownMenuItem(value: 'CAMION', child: Text('🚛 Camión')),
              DropdownMenuItem(value: 'FURGON', child: Text('🚐 Furgón')),
              DropdownMenuItem(value: 'TRAILER', child: Text('🚚 Tráiler')),
              DropdownMenuItem(value: 'MOTO', child: Text('🏍️ Moto')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _tipoVehiculo = value);
              }
            },
          ),
        ),
      ],
    );
  }

  // ========== WIDGETS DE APOYO ==========
  Widget _buildProfileHeader(
      String nombre,
      String tipo,
      String? fotoBase64,
      String tipoClienteLabel,
      IconData tipoIcon,
      Color tipoColor,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          // Foto de perfil
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.royalBlue.withOpacity(0.3),
                        AppColors.deepNavy.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.royalBlue.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selectedImageBytes != null
                        ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                        : (fotoBase64 != null && fotoBase64.isNotEmpty
                        ? Image.memory(
                      base64Decode(fotoBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(tipoIcon, tipoColor);
                      },
                    )
                        : _buildDefaultAvatar(tipoIcon, tipoColor)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.deepNavy, AppColors.royalBlue],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nombre,
            style: const TextStyle(
              color: AppColors.deepNavy,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tipoColor.withOpacity(0.1), tipoColor.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tipoColor.withOpacity(0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tipoIcon, color: tipoColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  tipoClienteLabel.toUpperCase(),
                  style: TextStyle(
                    color: tipoColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tipo.toUpperCase(),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(IconData icon, Color color) {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(icon, size: 60, color: color.withOpacity(0.6)),
    );
  }

  Widget _buildQuickInfoCard(String cedula, String tipoCliente, String rol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem(
            'Cédula / RIF',
            cedula,
            Icons.badge_outlined,
            Colors.orange.shade600,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildQuickInfoItem(
            'Tipo',
            tipoCliente,
            Icons.account_box_outlined,
            _getTipoClienteColor(_tipoCliente),
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade200),
          _buildQuickInfoItem(
            'Rol',
            rol,
            Icons.admin_panel_settings,
            Colors.purple.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.deepNavy,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  String _getTipoClienteLabel(String tipo) {
    switch (tipo) {
      case 'JURIDICO':
        return '🏢 Jurídico';
      case 'TRANSPORTISTA':
        return '🚛 Transportista';
      default:
        return '👤 Persona Natural';
    }
  }

  IconData _getTipoClienteIcon(String tipo) {
    switch (tipo) {
      case 'JURIDICO':
        return Icons.business;
      case 'TRANSPORTISTA':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }

  Color _getTipoClienteColor(String tipo) {
    switch (tipo) {
      case 'JURIDICO':
        return Colors.purple;
      case 'TRANSPORTISTA':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  void dispose() {
    _nameController?.dispose();
    _userController?.dispose();
    _emailController?.dispose();
    _telefonoController?.dispose();
    _razonSocialController?.dispose();
    _nitController?.dispose();
    _registroMercantilController?.dispose();
    _direccionFiscalController?.dispose();
    _licenciaConducirController?.dispose();
    _aniosExperienciaController?.dispose();
    super.dispose();
  }
}