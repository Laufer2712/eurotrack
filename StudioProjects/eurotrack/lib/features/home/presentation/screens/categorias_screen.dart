import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/productos/data/services/producto_service.dart';

class CategoriasScreen extends StatefulWidget {
  final int userId;

  const CategoriasScreen({super.key, required this.userId});

  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen> {
  final ProductoService _productoService = ProductoService();
  List<Map<String, dynamic>> _categorias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    try {
      final categorias = await _productoService.getCategorias();
      setState(() {
        _categorias = categorias;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text("Categorías", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.deepNavy,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _categorias.isEmpty
          ? const Center(child: Text("No se encontraron categorías"))
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final cat = _categorias[index];
          return _buildCategoryItem(cat);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/productos-por-categoria', // Esta ruta debe estar definida en tu main.dart
          arguments: {
            'categoriaId': cat['id'],
            'categoriaNombre': cat['nombre'],
            'userId': widget.userId,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 40, color: AppColors.royalBlue),
            const SizedBox(height: 12),
            Text(
              cat['nombre'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.deepNavy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}