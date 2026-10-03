import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';
import 'package:eurotrack/features/admin/presentation/screens/producto_form_screen.dart';
import 'package:eurotrack/core/services/log_service.dart';

class AdminProductosScreen extends StatefulWidget {
  final int userId;
  const AdminProductosScreen({super.key, required this.userId});

  @override
  State<AdminProductosScreen> createState() => _AdminProductosScreenState();
}

class _AdminProductosScreenState extends State<AdminProductosScreen> {
  final AdminService _adminService = AdminService();
  final LogService _logService = LogService();
  List<Map<String, dynamic>> _productos = [];
  List<Map<String, dynamic>> _categorias = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ==================== IMÁGENES ====================
  Widget _buildImage(String? source, double size, double boxSize) {
    if (source == null || source.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.inventory_2, size: size, color: Colors.grey[400]),
      );
    }

    if (source.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          source,
          fit: BoxFit.cover,
          width: boxSize,
          height: boxSize,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
        ),
      );
    }

    try {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(source),
          fit: BoxFit.cover,
          width: boxSize,
          height: boxSize,
          errorBuilder: (_, __, ___) => _buildImagePlaceholder(size),
        ),
      );
    } catch (e) {
      return _buildImagePlaceholder(size);
    }
  }

  Widget _buildImagePlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.broken_image, size: size * 0.6, color: Colors.grey[400]),
    );
  }

  // ==================== CARGA DE DATOS ====================
  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final productos = await _adminService.getProductos();
    final categorias = await _adminService.getCategorias();
    setState(() {
      _productos = productos;
      _categorias = categorias;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _productosFiltrados {
    if (_searchQuery.isEmpty) return _productos;
    return _productos.where((p) {
      final nombre = p['nombre']?.toLowerCase() ?? '';
      final marca = p['marca']?.toLowerCase() ?? '';
      final codigo = p['codigo']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nombre.contains(query) ||
          marca.contains(query) ||
          codigo.contains(query);
    }).toList();
  }

  // ==================== CRUD PRODUCTOS ====================
  Future<void> _crearProducto() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(categorias: _categorias),
      ),
    );
    if (result != null) {
      final nuevo = await _adminService.createProducto(result);
      if (nuevo != null) {
        await _logService.productoCreado(nuevo, 'admin@eurotrack.com');
        _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Producto creado exitosamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  Future<void> _editarProducto(Map<String, dynamic> producto) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductoFormScreen(
          categorias: _categorias,
          producto: producto,
          isEditing: true,
        ),
      ),
    );
    if (result != null) {
      final success = await _adminService.updateProducto(producto['id'], result);
      if (success) {
        await _logService.productoActualizado(result, 'admin@eurotrack.com');
        _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("✅ Producto actualizado"),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }
    }
  }

  Future<void> _eliminarProducto(int id, String nombre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Eliminar producto",
          style: TextStyle(color: Colors.red),
        ),
        content: Text("¿Desea eliminar '$nombre' permanentemente?\n\nEsta acción no se puede deshacer."),
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
      final success = await _adminService.deleteProducto(id);
      if (success) {
        await _logService.productoEliminado(id, nombre, 'admin@eurotrack.com');
        _cargarDatos();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("🗑️ Producto eliminado"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleActivo(int id, bool activo) async {
    final success = await _adminService.toggleProductoActivo(id);
    if (success) {
      _cargarDatos();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(activo ? "🔒 Producto desactivado" : "🔓 Producto activado"),
            backgroundColor: activo ? Colors.orange : Colors.green,
          ),
        );
      }
    }
  }

  // ==================== VER DETALLE ====================
  void _verDetalle(Map<String, dynamic> p) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            child: _buildDetalleContent(p),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _buildDetalleContent(p),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildDetalleContent(Map<String, dynamic> p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                p['nombre'] ?? 'Detalle del producto',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: _buildImage(
              p['imagen_url'] ?? p['imagenUrl'],
              100,
              200,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _buildDetailGrid(p),
        const SizedBox(height: 16),
        const Text(
          "Descripción:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.deepNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          p['descripcion'] ?? 'Sin descripción.',
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailGrid(Map<String, dynamic> p) {
    final items = [
      {'label': 'Código', 'value': p['codigo'] ?? 'N/A'},
      {'label': 'Marca', 'value': p['marca'] ?? 'N/A'},
      {'label': 'Número de parte', 'value': p['numeroParte'] ?? 'N/A'},
      {'label': 'Precio', 'value': "\$${(p['precio'] ?? 0).toStringAsFixed(2)}"},
      {'label': 'Stock', 'value': "${p['stock'] ?? 0} unidades"},
      {'label': 'Estado', 'value': p['activo'] == true ? "Activo" : "Inactivo", 'color': p['activo'] == true ? Colors.green : Colors.red},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 8,
        childAspectRatio: 3.5,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  item['label']!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item['value']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: item['color'] ?? Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
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
            "Gestión de Inventario",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _crearProducto,
              tooltip: 'Nuevo producto',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarDatos,
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
                    hintText: 'Buscar productos...',
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
            Text("Cargando productos...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_productosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) => _buildProductoCardMobile(_productosFiltrados[index]),
    );
  }

  // ==================== LAYOUT ESCRITORIO (CON SCROLL) ====================
  Widget _buildDesktopLayout() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.royalBlue),
            SizedBox(height: 16),
            Text("Cargando productos...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_productosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    // ✅ ScrollView para poder bajar y ver todos los productos
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: _productosFiltrados.map((producto) {
          return SizedBox(
            width: 220,
            child: _buildProductoCardDesktop(producto),
          );
        }).toList(),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No hay productos registrados"
                : "No se encontraron productos",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "Presiona el botón + para agregar uno"
                : "Prueba con otra búsqueda",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== CARD MÓVIL ====================
  Widget _buildProductoCardMobile(Map<String, dynamic> p) {
    final isActivo = p['activo'] == true;
    final String? imageUrl = p['imagen_url'] ?? p['imagenUrl'];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildImage(imageUrl, 40, 80),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        p['marca'] ?? 'Sin marca',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            "\$${(p['precio'] ?? 0).toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.deepNavy,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isActivo ? "Activo" : "Inactivo",
                              style: TextStyle(
                                color: isActivo ? Colors.green : Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (p['stock'] != null && p['stock'] < 5)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                "Stock: ${p['stock']}",
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _actionButton(
                  "Detalle",
                  Icons.visibility,
                  Colors.blueGrey,
                      () => _verDetalle(p),
                ),
                _actionButton(
                  isActivo ? "Bloquear" : "Activar",
                  isActivo ? Icons.toggle_off : Icons.toggle_on,
                  isActivo ? Colors.orange : Colors.green,
                      () => _toggleActivo(p['id'], isActivo),
                ),
                _actionButton(
                  "Editar",
                  Icons.edit,
                  AppColors.royalBlue,
                      () => _editarProducto(p),
                ),
                _actionButton(
                  "Eliminar",
                  Icons.delete,
                  Colors.red,
                      () => _eliminarProducto(p['id'], p['nombre'] ?? 'producto'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CARD ESCRITORIO ====================
  Widget _buildProductoCardDesktop(Map<String, dynamic> p) {
    final isActivo = p['activo'] == true;
    final String? imageUrl = p['imagen_url'] ?? p['imagenUrl'];
    final isLowStock = p['stock'] != null && p['stock'] < 5;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => _verDetalle(p),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: _buildImage(imageUrl, 50, 120),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                p['nombre'] ?? 'Sin nombre',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.deepNavy,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                p['marca'] ?? 'Sin marca',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "\$${(p['precio'] ?? 0).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActivo ? "Activo" : "Inactivo",
                      style: TextStyle(
                        color: isActivo ? Colors.green : Colors.red,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 12,
                    color: isLowStock ? Colors.orange : Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Stock: ${p['stock'] ?? 0}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isLowStock ? Colors.orange : Colors.grey[600],
                      fontWeight: isLowStock ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (isLowStock) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        "¡Bajo!",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDesktopActionButton(
                    icon: Icons.visibility,
                    color: Colors.blueGrey,
                    onPressed: () => _verDetalle(p),
                    tooltip: 'Detalle',
                  ),
                  _buildDesktopActionButton(
                    icon: isActivo ? Icons.toggle_off : Icons.toggle_on,
                    color: isActivo ? Colors.orange : Colors.green,
                    onPressed: () => _toggleActivo(p['id'], isActivo),
                    tooltip: isActivo ? 'Desactivar' : 'Activar',
                  ),
                  _buildDesktopActionButton(
                    icon: Icons.edit,
                    color: AppColors.royalBlue,
                    onPressed: () => _editarProducto(p),
                    tooltip: 'Editar',
                  ),
                  _buildDesktopActionButton(
                    icon: Icons.delete,
                    color: Colors.red,
                    onPressed: () => _eliminarProducto(p['id'], p['nombre'] ?? 'producto'),
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

  // ==================== BOTONES MÓVIL ====================
  Widget _actionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== BOTONES ESCRITORIO ====================
  Widget _buildDesktopActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}