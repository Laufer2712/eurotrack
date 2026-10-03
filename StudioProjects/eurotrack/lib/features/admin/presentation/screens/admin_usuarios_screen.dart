import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';

class AdminUsuariosScreen extends StatefulWidget {
  final int userId;

  const AdminUsuariosScreen({super.key, required this.userId});

  @override
  State<AdminUsuariosScreen> createState() => _AdminUsuariosScreenState();
}

class _AdminUsuariosScreenState extends State<AdminUsuariosScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _usuarios = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    final usuarios = await _adminService.getUsuarios();
    setState(() {
      _usuarios = usuarios;
      _isLoading = false;
    });
  }

  Future<void> _toggleActivo(int id, bool activar) async {
    final success = await _adminService.toggleUsuarioActivo(id);
    if (success) {
      _cargarUsuarios();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(activar ? "Usuario activado" : "Usuario desactivado")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al cambiar estado"), backgroundColor: Colors.red),
      );
    }
  }

  void _verPedidos(int userId, String nombre) {
    Navigator.pushNamed(context, '/admin/pedidos-usuario', arguments: {
      'userId': userId,
      'userNombre': nombre,
    });
  }

  void _verFavoritos(int userId, String nombre) {
    Navigator.pushNamed(context, '/admin/favoritos-usuario', arguments: {
      'userId': userId,
      'userNombre': nombre,
    });
  }

  List<Map<String, dynamic>> get _usuariosFiltrados {
    if (_searchQuery.isEmpty) return _usuarios;
    return _usuarios.where((u) {
      final nombre = u['nombre']?.toLowerCase() ?? '';
      final email = u['email']?.toLowerCase() ?? '';
      final username = u['username']?.toLowerCase() ?? '';
      final cedula = u['cedula']?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return nombre.contains(query) ||
          email.contains(query) ||
          username.contains(query) ||
          cedula.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FF),
        appBar: AppBar(
          title: const Text(
            "Gestión de Usuarios",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarUsuarios,
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
                    hintText: 'Buscar usuarios...',
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
            Text("Cargando usuarios...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_usuariosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _usuariosFiltrados.length,
      itemBuilder: (context, index) {
        final usuario = _usuariosFiltrados[index];
        return _buildUsuarioCardMobile(usuario);
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
            Text("Cargando usuarios...", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_usuariosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.start,
        children: _usuariosFiltrados.map((usuario) {
          return SizedBox(
            width: 340,
            child: _buildUsuarioCardDesktop(usuario),
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
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? "No hay usuarios registrados"
                : "No se encontraron usuarios",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? "Los usuarios se mostrarán aquí"
                : "Prueba con otra búsqueda",
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==================== CARD USUARIO MÓVIL ====================
  Widget _buildUsuarioCardMobile(Map<String, dynamic> usuario) {
    final isCurrentUser = usuario['id'] == widget.userId;
    final isActivo = usuario['activo'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 30, color: AppColors.royalBlue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(usuario['nombre'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text("@${usuario['username'] ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActivo ? "ACTIVO" : "INACTIVO",
                    style: TextStyle(color: isActivo ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [Icon(Icons.email, size: 16, color: Colors.grey[400]), const SizedBox(width: 8), Expanded(child: Text(usuario['email'] ?? '', style: const TextStyle(fontSize: 12)))]),
            Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [Icon(Icons.phone, size: 16, color: Colors.grey[400]), const SizedBox(width: 8), Text(usuario['telefono'] ?? 'Sin teléfono', style: const TextStyle(fontSize: 12))])),
            if (usuario['cedula'] != null && usuario['cedula'].isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [Icon(Icons.badge, size: 16, color: Colors.grey[400]), const SizedBox(width: 8), Text(usuario['cedula'], style: const TextStyle(fontSize: 12))])),
            Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Icon(Icons.admin_panel_settings, size: 16, color: Colors.grey[400]), const SizedBox(width: 8), Text("Rol: ${usuario['rol'] ?? 'CLIENTE'}", style: const TextStyle(fontSize: 12))])),
            const SizedBox(height: 12),
            if (!isCurrentUser)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _actionButton(label: "Pedidos", icon: Icons.receipt_long, color: AppColors.royalBlue, onPressed: () => _verPedidos(usuario['id'], usuario['nombre'])),
                  const SizedBox(width: 6),
                  _actionButton(label: "Favoritos", icon: Icons.favorite_border, color: Colors.pink.shade400, onPressed: () => _verFavoritos(usuario['id'], usuario['nombre'])),
                  const SizedBox(width: 6),
                  _statusButton(isActivo: isActivo, id: usuario['id']),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ==================== CARD USUARIO ESCRITORIO ====================
  Widget _buildUsuarioCardDesktop(Map<String, dynamic> usuario) {
    final isCurrentUser = usuario['id'] == widget.userId;
    final isActivo = usuario['activo'] == true;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 32, color: AppColors.royalBlue),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nombre'] ?? 'Sin nombre',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      Text(
                        "@${usuario['username'] ?? ''}",
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActivo ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isActivo ? "ACTIVO" : "INACTIVO",
                    style: TextStyle(
                      color: isActivo ? Colors.green : Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Información en grid (más compacta)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
              childAspectRatio: 5,
              children: [
                _buildInfoItem(Icons.email, usuario['email'] ?? 'Sin email'),
                _buildInfoItem(Icons.phone, usuario['telefono'] ?? 'Sin teléfono'),
                _buildInfoItem(Icons.badge, usuario['cedula'] ?? 'Sin cédula'),
                _buildInfoItem(Icons.admin_panel_settings, "Rol: ${usuario['rol'] ?? 'CLIENTE'}"),
              ],
            ),
            const SizedBox(height: 14),
            // ✅ Botones corregidos (con Wrap para evitar desbordamiento)
            if (!isCurrentUser)
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildDesktopActionButton(
                    label: "Pedidos",
                    icon: Icons.receipt_long,
                    color: AppColors.royalBlue,
                    onPressed: () => _verPedidos(usuario['id'], usuario['nombre']),
                  ),
                  _buildDesktopActionButton(
                    label: "Favoritos",
                    icon: Icons.favorite_border,
                    color: Colors.pink.shade400,
                    onPressed: () => _verFavoritos(usuario['id'], usuario['nombre']),
                  ),
                  _buildDesktopStatusButton(
                    isActivo: isActivo,
                    id: usuario['id'],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTONES MÓVIL ====================
  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      height: 28,
      child: TextButton.icon(
        icon: Icon(icon, size: 13),
        label: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: color.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: color.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _statusButton({required bool isActivo, required int id}) {
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: () => _toggleActivo(id, !isActivo),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isActivo ? Colors.red.shade50 : Colors.green.shade50,
          foregroundColor: isActivo ? Colors.red.shade700 : Colors.green.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          isActivo ? "Desactivar" : "Activar",
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // ==================== BOTONES ESCRITORIO (MÁS COMPACTOS) ====================
  Widget _buildDesktopActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopStatusButton({required bool isActivo, required int id}) {
    final label = isActivo ? "Desactivar" : "Activar";
    final color = isActivo ? Colors.red : Colors.green;

    return Tooltip(
      message: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleActivo(id, !isActivo),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActivo ? Icons.toggle_off : Icons.toggle_on,
                  size: 14,
                  color: color,
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}