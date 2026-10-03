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
      print("Error cargando categorías: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      appBar: AppBar(
        title: const Text(
          "Categorías",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : _categorias.isEmpty
          ? _buildEmptyState()
          : GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          return _buildCategoriaCard(categoria);
        },
      ),
    );
  }

  Widget _buildCategoriaCard(Map<String, dynamic> categoria) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // 🔥 AQUÍ ESTÁ EL CAMBIO:
          // Cambiamos la ruta a '/productos-por-categoria'
          // y enviamos los argumentos necesarios (ID, Nombre y UserId)
          Navigator.pushNamed(
            context,
            '/productos-por-categoria',
            arguments: {
              'categoriaId': categoria['id'],
              'categoriaNombre': categoria['nombre'],
              'userId': widget.userId,
            },
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.category,
                  size: 35,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                categoria['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              const Text(
                'Ver productos',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.royalBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No hay categorías disponibles",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _cargarCategorias,
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}