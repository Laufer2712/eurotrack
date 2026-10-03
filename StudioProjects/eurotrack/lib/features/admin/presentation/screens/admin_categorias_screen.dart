import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';
import 'package:eurotrack/features/admin/presentation/screens/categoria_form_screen.dart';
import 'package:eurotrack/core/services/log_service.dart';

class AdminCategoriasScreen extends StatefulWidget {
  final int userId;
  const AdminCategoriasScreen({super.key, required this.userId});

  @override
  State<AdminCategoriasScreen> createState() => _AdminCategoriasScreenState();
}

class _AdminCategoriasScreenState extends State<AdminCategoriasScreen> {
  final AdminService _adminService = AdminService();
  final LogService _logService = LogService();
  List<Map<String, dynamic>> _categorias = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  // ==================== CARGA DE DATOS ====================
  Future<void> _cargarCategorias() async {
    setState(() => _isLoading = true);
    final categorias = await _adminService.getCategorias();
    setState(() {
      _categorias = categorias;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _categoriasFiltradas {
    if (_searchQuery.isEmpty) return _categorias;
    return _categorias.where((c) {
      final nombre = c['nombre']?.toLowerCase() ?? '';
      final descripcion = c['descripcion']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nombre.contains(query) || descripcion.contains(query);
    }).toList();
  }

  // ==================== CRUD CATEGORIAS ====================
  Future<void> _crearCategoria() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoriaFormScreen(),
      ),
    );
    if (result != null) {
      final nuevaCategoria = await _adminService.createCategoria(result);
      if (nuevaCategoria != null) {
        await _logService.categoriaCreada(nuevaCategoria, 'admin@eurotrack.com');
        _cargarCategorias();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Categoría creada exitosamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Error al crear categoría"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editarCategoria(Map<String, dynamic> categoria) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriaFormScreen(
          categoria: categoria,
          isEditing: true,
        ),
      ),
    );
    if (result != null) {
      final success = await _adminService.updateCategoria(categoria['id'], result);
      if (success) {
        await _logService.categoriaActualizada(result, 'admin@eurotrack.com');
        _cargarCategorias();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Categoría actualizada"),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Error al actualizar"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarCategoria(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Eliminar categoría",
          style: TextStyle(color: Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("¿Eliminar '$nombre' permanentemente?"),
            const SizedBox(height: 8),
            const Text(
              "⚠️ Esto también eliminará todos los productos asociados a esta categoría.",
              style: TextStyle(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _adminService.deleteCategoria(id);
      if (success) {
        await _logService.categoriaEliminada(id, nombre, 'admin@eurotrack.com');
        _cargarCategorias();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🗑️ Categoría eliminada"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("❌ Error al eliminar. Verifica que no tenga productos asociados."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
          title: const Text(
            "Gestión de Categorías",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _crearCategoria,
              tooltip: 'Nueva categoría',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarCategorias,
              tooltip: 'Recargar',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar categorías...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
            ),
          ),
        ),
        body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
      ),
    );
  }

  // ==================== LAYOUT MÓVIL ====================
  Widget _buildMobileLayout() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando categorías...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_categoriasFiltradas.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _categoriasFiltradas.length,
      itemBuilder: (context, index) {
        final categoria = _categoriasFiltradas[index];
        return _buildCategoriaCardMobile(categoria);
      },
    );
  }

  // ==================== LAYOUT ESCRITORIO ====================
  Widget _buildDesktopLayout() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando categorías...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_categoriasFiltradas.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 0.9,
        ),
        itemCount: _categoriasFiltradas.length,
        itemBuilder: (context, index) {
          final categoria = _categoriasFiltradas[index];
          return _buildCategoriaCardDesktop(categoria);
        },
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No hay categorías registradas"
                : "No se encontraron categorías",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "Presiona el botón + para agregar una"
                : "Prueba con otra búsqueda",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== FUNCIÓN PARA MOSTRAR IMAGEN ====================
  Widget _buildCategoriaImage(String? imagenUrl, double size) {
    if (imagenUrl == null || imagenUrl.isEmpty) {
      return Icon(Icons.category, size: size * 0.5, color: Colors.grey.shade400);
    }

    // Si es Base64
    if (imagenUrl.length > 100) {
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(imagenUrl),
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => Icon(
              Icons.category,
              size: size * 0.5,
              color: Colors.grey.shade400,
            ),
          ),
        );
      } catch (e) {
        return Icon(Icons.category, size: size * 0.5, color: Colors.grey.shade400);
      }
    }

    // Si es URL externa
    if (imagenUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imagenUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => Icon(
            Icons.category,
            size: size * 0.5,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    return Icon(Icons.category, size: size * 0.5, color: Colors.grey.shade400);
  }

  // ==================== CARD MÓVIL ====================
  Widget _buildCategoriaCardMobile(Map<String, dynamic> categoria) {
    final imagenUrl = categoria['imagenUrl'] ?? categoria['imagen_url'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _editarCategoria(categoria),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ✅ Imagen de la categoría
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildCategoriaImage(imagenUrl, 60),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria['nombre'] ?? 'Sin nombre',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (categoria['descripcion'] != null && categoria['descripcion'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          categoria['descripcion'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "ID: ${categoria['id']}",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.royalBlue),
                    onPressed: () => _editarCategoria(categoria),
                    splashRadius: 20,
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _eliminarCategoria(
                      categoria['id'],
                      categoria['nombre'] ?? 'categoría',
                    ),
                    splashRadius: 20,
                    tooltip: 'Eliminar',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== CARD ESCRITORIO ====================
  Widget _buildCategoriaCardDesktop(Map<String, dynamic> categoria) {
    final imagenUrl = categoria['imagenUrl'] ?? categoria['imagen_url'];
    final colors = [
      AppColors.royalBlue,
      Colors.purple,
      Colors.teal,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.deepPurple,
    ];
    final colorIndex = (categoria['id'] ?? 0) % colors.length;
    final color = colors[colorIndex];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _editarCategoria(categoria),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Imagen de la categoría (más grande en escritorio)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildCategoriaImage(imagenUrl, 100),
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ Nombre
                Text(
                  categoria['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.deepNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                // ✅ Descripción
                if (categoria['descripcion'] != null && categoria['descripcion'].isNotEmpty)
                  Text(
                    categoria['descripcion'],
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                const Spacer(),
                // ✅ Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: Icons.edit,
                      color: AppColors.royalBlue,
                      onPressed: () => _editarCategoria(categoria),
                      label: 'Editar',
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete,
                      color: Colors.red,
                      onPressed: () => _eliminarCategoria(
                        categoria['id'],
                        categoria['nombre'] ?? 'categoría',
                      ),
                      label: 'Eliminar',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== BOTÓN DE ACCIÓN ====================
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}