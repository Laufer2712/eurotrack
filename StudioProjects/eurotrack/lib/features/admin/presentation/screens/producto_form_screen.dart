import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProductoFormScreen extends StatefulWidget {
  final List<Map<String, dynamic>> categorias;
  final Map<String, dynamic>? producto;
  final bool isEditing;

  const ProductoFormScreen({
    super.key,
    required this.categorias,
    this.producto,
    this.isEditing = false,
  });

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _codigoController;
  late TextEditingController _numeroParteController;
  late TextEditingController _marcaController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenController;

  int? _categoriaId;
  bool _activo = true;

  // Variables para manejar la imagen
  File? _imagenFile;
  String? _imagenBase64;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.producto?['nombre'] ?? '');
    _descripcionController = TextEditingController(text: widget.producto?['descripcion'] ?? '');
    _codigoController = TextEditingController(text: widget.producto?['codigo'] ?? '');
    _numeroParteController = TextEditingController(text: widget.producto?['numeroParte'] ?? '');
    _marcaController = TextEditingController(text: widget.producto?['marca'] ?? '');
    _precioController = TextEditingController(text: widget.producto?['precio']?.toString() ?? '');
    _stockController = TextEditingController(text: widget.producto?['stock']?.toString() ?? '');

    // Cargar imagen existente
    final imagenExistente = widget.producto?['imagenUrl'] ?? widget.producto?['imagen_url'] ?? '';
    _imagenController = TextEditingController(text: imagenExistente);

    // Si hay imagen existente, la guardamos en _imagenBase64 para la previsualización
    if (imagenExistente.isNotEmpty) {
      _imagenBase64 = imagenExistente;
    }

    _categoriaId = widget.producto?['categoria']?['id'] ?? widget.producto?['categoriaId'];
    _activo = widget.producto?['activo'] ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    _numeroParteController.dispose();
    _marcaController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _imagenController.dispose();
    super.dispose();
  }

  // ==================== SELECCIONAR IMAGEN ====================
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );

    if (image != null) {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _imagenFile = File(image.path);
        _imagenBase64 = base64String;
        _imagenController.text = base64String;
      });
    }
  }

  // ==================== ELIMINAR IMAGEN ====================
  void _eliminarImagen() {
    setState(() {
      _imagenFile = null;
      _imagenBase64 = null;
      _imagenController.text = '';
    });
  }

  // ==================== VERIFICAR SI HAY IMAGEN ====================
  bool _hasImage() {
    return (_imagenFile != null) ||
        (_imagenBase64 != null && _imagenBase64!.isNotEmpty) ||
        (_imagenController.text.isNotEmpty);
  }

  // ==================== OBTENER IMAGEN PARA DECORATION ====================
  ImageProvider? _getImageProvider() {
    if (_imagenFile != null) {
      return FileImage(_imagenFile!);
    } else if (_imagenBase64 != null && _imagenBase64!.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_imagenBase64!));
      } catch (e) {
        return null;
      }
    } else if (_imagenController.text.isNotEmpty) {
      try {
        return MemoryImage(base64Decode(_imagenController.text));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> _getFormData() {
    return {
      'nombre': _nombreController.text.trim(),
      'descripcion': _descripcionController.text.trim(),
      'codigo': _codigoController.text.trim(),
      'numeroParte': _numeroParteController.text.trim(),
      'marca': _marcaController.text.trim(),
      'precio': double.tryParse(_precioController.text) ?? 0,
      'stock': int.tryParse(_stockController.text) ?? 0,
      'imagenUrl': _imagenController.text.trim(),
      'categoriaId': _categoriaId,
      'activo': _activo,
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Editar Producto' : 'Nuevo Producto',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECCIÓN DE IMAGEN - IGUAL QUE CATEGORÍAS
            _buildImageSection(),
            const SizedBox(height: 24),

            // Nombre
            _buildTextField(
              controller: _nombreController,
              label: 'Nombre',
              hint: 'Nombre del producto',
              icon: Icons.inventory,
              validator: (v) => v?.isEmpty == true ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 16),

            // Código
            _buildTextField(
              controller: _codigoController,
              label: 'Código',
              hint: 'Código del producto',
              icon: Icons.code,
            ),
            const SizedBox(height: 16),

            // Marca
            _buildTextField(
              controller: _marcaController,
              label: 'Marca',
              hint: 'Marca del producto',
              icon: Icons.business,
            ),
            const SizedBox(height: 16),

            // Categoría
            _buildCategoriaDropdown(),
            const SizedBox(height: 16),

            // Precio
            _buildTextField(
              controller: _precioController,
              label: 'Precio',
              hint: '0.00',
              icon: Icons.attach_money,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v?.isEmpty == true) return 'El precio es requerido';
                if (double.tryParse(v!) == null) return 'Ingresa un precio válido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Stock
            _buildTextField(
              controller: _stockController,
              label: 'Stock',
              hint: '0',
              icon: Icons.inventory_2,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty == true) return 'El stock es requerido';
                if (int.tryParse(v!) == null) return 'Ingresa un número válido';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Número de parte
            _buildTextField(
              controller: _numeroParteController,
              label: 'Número de parte',
              hint: 'Número de parte del producto',
              icon: Icons.assignment,
            ),
            const SizedBox(height: 16),

            // Descripción
            _buildTextField(
              controller: _descripcionController,
              label: 'Descripción',
              hint: 'Descripción del producto',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Activo
            SwitchListTile(
              title: const Text('Producto activo'),
              value: _activo,
              onChanged: (value) => setState(() => _activo = value),
              activeColor: AppColors.royalBlue,
              contentPadding: EdgeInsets.zero,
            ),
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
            padding: const EdgeInsets.all(32),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN DE IMAGEN - IGUAL QUE CATEGORÍAS
                    _buildImageSection(),
                    const SizedBox(height: 24),

                    // Nombre
                    _buildTextField(
                      controller: _nombreController,
                      label: 'Nombre',
                      hint: 'Nombre del producto',
                      icon: Icons.inventory,
                      validator: (v) => v?.isEmpty == true ? 'El nombre es requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // Código
                    _buildTextField(
                      controller: _codigoController,
                      label: 'Código',
                      hint: 'Código del producto',
                      icon: Icons.code,
                    ),
                    const SizedBox(height: 16),

                    // Marca
                    _buildTextField(
                      controller: _marcaController,
                      label: 'Marca',
                      hint: 'Marca del producto',
                      icon: Icons.business,
                    ),
                    const SizedBox(height: 16),

                    // Categoría
                    _buildCategoriaDropdown(),
                    const SizedBox(height: 16),

                    // Precio
                    _buildTextField(
                      controller: _precioController,
                      label: 'Precio',
                      hint: '0.00',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'El precio es requerido';
                        if (double.tryParse(v!) == null) return 'Ingresa un precio válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    _buildTextField(
                      controller: _stockController,
                      label: 'Stock',
                      hint: '0',
                      icon: Icons.inventory_2,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'El stock es requerido';
                        if (int.tryParse(v!) == null) return 'Ingresa un número válido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Número de parte
                    _buildTextField(
                      controller: _numeroParteController,
                      label: 'Número de parte',
                      hint: 'Número de parte del producto',
                      icon: Icons.assignment,
                    ),
                    const SizedBox(height: 16),

                    // Descripción
                    _buildTextField(
                      controller: _descripcionController,
                      label: 'Descripción',
                      hint: 'Descripción del producto',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Activo
                    SwitchListTile(
                      title: const Text('Producto activo'),
                      value: _activo,
                      onChanged: (value) => setState(() => _activo = value),
                      activeColor: AppColors.royalBlue,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== SECCIÓN DE IMAGEN (IGUAL QUE CATEGORÍAS) ====================
  // ==================== SECCIÓN DE IMAGEN ====================
  Widget _buildImageSection() {
    final hasImage = _hasImage();
    final imageProvider = _getImageProvider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Imagen del producto',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Vista previa de la imagen
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
                  image: imageProvider != null
                      ? DecorationImage(
                    image: imageProvider,
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
                      fontSize: 14,
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
                      fontSize: 12,
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
  // ==================== CAMPO DE TEXTO ====================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: AppColors.deepNavy,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.royalBlue,
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.royalBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ==================== DROPDOWN DE CATEGORÍA ====================
  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<int>(
      value: _categoriaId,
      decoration: InputDecoration(
        labelText: 'Categoría',
        labelStyle: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
        ),
        prefixIcon: const Icon(Icons.category, color: AppColors.royalBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.royalBlue, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: widget.categorias.map((cat) {
        return DropdownMenuItem<int>(
          value: cat['id'],
          child: Text(
            cat['nombre'] ?? 'Sin nombre',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.deepNavy,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => _categoriaId = value),
      validator: (v) => v == null ? 'Selecciona una categoría' : null,
    );
  }
}