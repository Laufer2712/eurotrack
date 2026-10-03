import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class ProductoFormDialog extends StatefulWidget {
  final List<Map<String, dynamic>> categorias;
  final String titulo;
  final Map<String, dynamic>? producto;

  const ProductoFormDialog({
    super.key,
    required this.categorias,
    required this.titulo,
    this.producto,
  });

  @override
  State<ProductoFormDialog> createState() => _ProductoFormDialogState();
}

class _ProductoFormDialogState extends State<ProductoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _codigoController;
  late TextEditingController _numeroParteController;
  late TextEditingController _marcaController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _imagenController;

  int? _categoriaId;

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
    try {
      final XFile? image = await _picker.pickImage(
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al seleccionar la imagen")),
      );
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

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor selecciona una categoría")),
        );
        return;
      }

      final data = {
        "nombre": _nombreController.text.trim(),
        "descripcion": _descripcionController.text.trim(),
        "codigo": _codigoController.text.trim(),
        "numeroParte": _numeroParteController.text.trim(),
        "marca": _marcaController.text.trim(),
        "precio": double.tryParse(_precioController.text) ?? 0.0,
        "stock": int.tryParse(_stockController.text) ?? 0,
        "categoriaId": _categoriaId,
        "imagenUrl": _imagenController.text.trim(),
        "activo": widget.producto?['activo'] ?? true,
      };
      Navigator.pop(context, data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== TÍTULO ==========
              Text(
                widget.titulo,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const SizedBox(height: 20),

              // ========== SECCIÓN DE IMAGEN ==========
              _buildImageSection(),
              const SizedBox(height: 16),

              // ========== CAMPOS DEL FORMULARIO ==========
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(_nombreController, "Nombre", Icons.label),
                      const SizedBox(height: 12),
                      _buildTextField(
                        _descripcionController,
                        "Descripción",
                        Icons.description,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _codigoController,
                              "Código",
                              Icons.code,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _numeroParteController,
                              "N° Parte",
                              Icons.pin,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(_marcaController, "Marca", Icons.branding_watermark),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              _precioController,
                              "Precio",
                              Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              _stockController,
                              "Stock",
                              Icons.inventory,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildCategoriaDropdown(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ========== BOTONES ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                    ),
                    onPressed: _guardar,
                    child: const Text(
                      "Guardar",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SECCIÓN DE IMAGEN ====================
  Widget _buildImageSection() {
    final hasImage = _hasImage();
    final imageProvider = _getImageProvider();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.royalBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }
        return null;
      },
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<int>(
      value: _categoriaId,
      decoration: InputDecoration(
        labelText: "Categoría",
        prefixIcon: Icon(Icons.category, color: AppColors.royalBlue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: widget.categorias.map((cat) {
        return DropdownMenuItem<int>(
          value: cat['id'] as int,
          child: Text(cat['nombre'] ?? ''),
        );
      }).toList(),
      onChanged: (value) => setState(() => _categoriaId = value),
      validator: (value) => value == null ? "Selecciona categoría" : null,
    );
  }
}