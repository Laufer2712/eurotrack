import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';

class CategoriaFormScreen extends StatefulWidget {
  final Map<String, dynamic>? categoria;
  final bool isEditing;

  const CategoriaFormScreen({
    super.key,
    this.categoria,
    this.isEditing = false,
  });

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  // ✅ Para manejar la imagen
  File? _imagenFile;
  String? _imagenBase64;
  String? _imagenUrlExistente;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.categoria?['nombre'] ?? '');
    _descripcionController = TextEditingController(text: widget.categoria?['descripcion'] ?? '');

    // ✅ Guardar la imagen existente (si la hay)
    _imagenUrlExistente = widget.categoria?['imagenUrl'] ?? widget.categoria?['imagen_url'];
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  // ==================== SELECCIONAR IMAGEN ====================
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imagenFile = File(image.path);
        _imagenBase64 = base64Encode(bytes);
      });
    }
  }

  // ==================== ELIMINAR IMAGEN ====================
  void _eliminarImagen() {
    setState(() {
      _imagenFile = null;
      _imagenBase64 = null;
      _imagenUrlExistente = null;
    });
  }

  Map<String, dynamic> _getFormData() {
    return {
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      // ✅ Priorizar la nueva imagen, si no, mantener la existente
      'imagenUrl': _imagenBase64 ?? _imagenUrlExistente ?? '',
    };
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar Categoría' : 'Nueva Categoría',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.pop(context, _getFormData());
                }
              },
              child: const Text(
                'Guardar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildFormFields(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(40),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildImageSection(),
                  const SizedBox(height: 16),
                  _buildFormFields(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
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
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.royalBlue.withOpacity(0.1),
                AppColors.royalBlue.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.royalBlue.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            Icons.category,
            size: isDesktop ? 48 : 40,
            color: AppColors.royalBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEditing ? 'Editar Categoría' : 'Nueva Categoría',
                style: TextStyle(
                  fontSize: isDesktop ? 24 : 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isEditing
                    ? 'Actualiza la información de la categoría'
                    : 'Crea una nueva categoría para organizar tus productos',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: isDesktop ? 14 : 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== SECCIÓN DE IMAGEN ====================
  Widget _buildImageSection() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final hasImage = _imagenBase64 != null || _imagenUrlExistente != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen de la categoría',
          style: TextStyle(
            fontSize: isDesktop ? 15 : 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // ✅ Vista previa de la imagen
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasImage ? Colors.green : Colors.grey.shade300,
                    width: 2,
                  ),
                  image: _imagenBase64 != null
                      ? DecorationImage(
                    image: MemoryImage(base64Decode(_imagenBase64!)),
                    fit: BoxFit.cover,
                  )
                      : _imagenUrlExistente != null && _imagenUrlExistente!.isNotEmpty
                      ? DecorationImage(
                    image: MemoryImage(base64Decode(_imagenUrlExistente!)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: !hasImage
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 30,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Agregar',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasImage ? '✅ Imagen seleccionada' : 'Sin imagen',
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 12,
                      fontWeight: FontWeight.w500,
                      color: hasImage ? Colors.green : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasImage
                        ? 'Toca la imagen para cambiarla'
                        : 'Toca el recuadro para seleccionar una imagen',
                    style: TextStyle(
                      fontSize: isDesktop ? 12 : 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (hasImage) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _eliminarImagen,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text(
                        'Eliminar imagen',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== CAMPOS DEL FORMULARIO ====================
  Widget _buildFormFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return Column(
      children: [
        _buildTextField(
          controller: _nombreController,
          label: 'Nombre',
          hint: 'Ej: Motores, Frenos, Suspensión',
          icon: Icons.category,
          validator: (v) => v?.isEmpty == true ? 'El nombre es requerido' : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descripcionController,
          label: 'Descripción',
          hint: 'Describe el propósito de esta categoría',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  // ==================== CAMPO DE TEXTO ====================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: isDesktop ? 16 : 14,
        color: AppColors.deepNavy,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: isDesktop ? 15 : 13,
          color: Colors.grey.shade700,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: isDesktop ? 14 : 12,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.royalBlue,
          size: isDesktop ? 24 : 20,
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
          borderSide: const BorderSide(color: AppColors.royalBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
    );
  }

  // ==================== BOTÓN DE ENVÍO ====================
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pop(context, _getFormData());
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: AppColors.royalBlue.withOpacity(0.3),
        ),
        child: const Text(
          'Guardar Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}