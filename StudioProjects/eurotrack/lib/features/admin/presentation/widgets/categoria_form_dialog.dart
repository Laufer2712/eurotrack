import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';

class CategoriaFormDialog extends StatefulWidget {
  final String titulo;
  final Map<String, dynamic>? categoria;

  const CategoriaFormDialog({
    super.key,
    required this.titulo,
    this.categoria,
  });

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.categoria?['nombre'] ?? '');
    _descripcionController = TextEditingController(text: widget.categoria?['descripcion'] ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_formKey.currentState!.validate()) {
      final data = {
        "nombre": _nombreController.text,
        "descripcion": _descripcionController.text,
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
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nombreController, "Nombre de la categoría", Icons.label),
              const SizedBox(height: 12),
              _buildTextField(_descripcionController, "Descripción", Icons.description, maxLines: 2),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalBlue),
                    onPressed: _guardar,
                    child: const Text("Guardar", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.royalBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Campo requerido";
        }
        return null;
      },
    );
  }
}