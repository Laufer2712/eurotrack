// lib/features/notificaciones/presentation/screens/notificaciones_screen.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/notificaciones/data/services/notificaciones_service.dart';

class NotificacionesScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;

  const NotificacionesScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
  });

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> with SingleTickerProviderStateMixin {
  final NotificacionesService _service = NotificacionesService();
  List<Map<String, dynamic>> _notificaciones = [];
  bool _isLoading = true;
  String? _fotoPerfilBase64;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _cargarDatos();
    _fetchFotoPerfil();
  }

  Future<void> _fetchFotoPerfil() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.authEndpoint}/profile/${widget.userId}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() => _fotoPerfilBase64 = data['fotoPerfil']);
        }
      }
    } catch (e) {
      debugPrint("Error cargando foto: $e");
    }
  }

  Uint8List? _decodificarBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      final cleanString = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(cleanString);
    } catch (e) {
      return null;
    }
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    final data = await _service.getNotificaciones(widget.userId);
    if (mounted) {
      setState(() {
        _notificaciones = data;
        _isLoading = false;
      });
      _animationController.forward(from: 0);
    }
  }

  Future<void> _marcarComoLeido(int notificacionId) async {
    try {
      await _service.marcarComoLeido(notificacionId);
      setState(() {
        final index = _notificaciones.indexWhere((n) => n['id'] == notificacionId);
        if (index != -1) {
          _notificaciones[index]['leido'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Marcado como leído'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marcando como leído: $e');
    }
  }

  Future<void> _marcarTodasComoLeidas() async {
    final noLeidas = _notificaciones.where((n) => n['leido'] == false).toList();
    if (noLeidas.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay notificaciones pendientes'),
            backgroundColor: Colors.grey,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
      return;
    }

    try {
      for (var n in noLeidas) {
        await _service.marcarComoLeido(n['id']);
      }
      setState(() {
        for (var n in _notificaciones) {
          n['leido'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todas las notificaciones marcadas como leídas'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marcando todas como leídas: $e');
    }
  }

  Future<void> _eliminarNotificacion(int notificacionId) async {
    try {
      await _service.eliminarNotificacion(notificacionId);
      setState(() {
        _notificaciones.removeWhere((n) => n['id'] == notificacionId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Notificación eliminada'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error eliminando notificación: $e');
    }
  }

  List<Map<String, dynamic>> get _notificacionesFiltradas {
    if (_selectedFilter == 0) return _notificaciones;
    return _notificaciones.where((n) => n['leido'] == false).toList();
  }

  String _getTimeAgo(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m';
      } else {
        return 'Ahora';
      }
    } catch (e) {
      return fecha;
    }
  }

  Color _getNotificationColor(String tipo) {
    switch (tipo) {
      case 'PEDIDO':
        return AppColors.royalBlue;
      case 'PAGO':
        return Colors.green;
      case 'ALERTA':
        return Colors.orange;
      case 'ERROR':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(String tipo) {
    switch (tipo) {
      case 'PEDIDO':
        return Icons.local_shipping;
      case 'PAGO':
        return Icons.payment;
      case 'ALERTA':
        return Icons.warning_amber_rounded;
      case 'ERROR':
        return Icons.error_outline;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);
    final notificacionesFiltradas = _notificacionesFiltradas;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: HomeAppBar(
        nombre: widget.nombre,
        userId: widget.userId,
        tipoCliente: widget.tipoCliente,
        fotoPerfil: fotoPerfil,
        carritoCount: 0,
        onPerfilTap: () => Navigator.pushNamed(
          context,
          '/perfil',
          arguments: {
            'id': widget.userId,
            'nombre': widget.nombre,
            'username': widget.username,
          },
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _notificaciones.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: _cargarDatos,
                color: AppColors.royalBlue,
                child: notificacionesFiltradas.isEmpty
                    ? _buildEmptyFilterState()
                    : isDesktop
                    ? _buildDesktopGrid(notificacionesFiltradas)
                    : isTablet
                    ? _buildTabletGrid(notificacionesFiltradas)
                    : _buildMobileList(notificacionesFiltradas),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BARRA DE FILTROS
  // ============================================================
  Widget _buildFilterBar() {
    final noLeidas = _notificaciones.where((n) => n['leido'] == false).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _buildFilterChip('Todas', 0, _notificaciones.length),
          const SizedBox(width: 8),
          _buildFilterChip('No leídas', 1, noLeidas),
          const Spacer(),
          if (noLeidas > 0)
            TextButton.icon(
              onPressed: _marcarTodasComoLeidas,
              icon: const Icon(Icons.done_all, size: 16),
              label: Text(
                'Leer todas',
                style: TextStyle(fontSize: 11, color: AppColors.royalBlue),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.royalBlue,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, int count) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
            if (count > 0 && index == 1) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.royalBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.royalBlue : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO DE CARGA
  // ============================================================
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.royalBlue),
          SizedBox(height: 16),
          Text(
            "Cargando notificaciones...",
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // VISTA MÓVIL (LISTA)
  // ============================================================
  Widget _buildMobileList(List<Map<String, dynamic>> notificaciones) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: notificaciones.length,
      itemBuilder: (context, index) {
        final n = notificaciones[index];
        return _buildCardMobile(n);
      },
    );
  }

  // ============================================================
  // VISTA TABLET (GRID 2 COLUMNAS)
  // ============================================================
  Widget _buildTabletGrid(List<Map<String, dynamic>> notificaciones) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: notificaciones.length,
        itemBuilder: (context, index) {
          final n = notificaciones[index];
          return _buildCardTablet(n);
        },
      ),
    );
  }

  // ============================================================
  // VISTA ESCRITORIO (GRID 3 COLUMNAS)
  // ============================================================
  Widget _buildDesktopGrid(List<Map<String, dynamic>> notificaciones) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: notificaciones.length,
        itemBuilder: (context, index) {
          final n = notificaciones[index];
          return _buildCardDesktop(n);
        },
      ),
    );
  }

  // ============================================================
  // TARJETA MÓVIL (COMPACTA)
  // ============================================================
  Widget _buildCardMobile(Map<String, dynamic> n) {
    final color = _getNotificationColor(n['tipo'] ?? '');
    final icon = _getNotificationIcon(n['tipo'] ?? '');
    final isPedido = n['tipo'] == 'PEDIDO';
    final leido = n['leido'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: leido ? Colors.grey.shade100 : color.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        n['titulo'] ?? 'Notificación',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: leido ? Colors.grey.shade500 : AppColors.deepNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!leido)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  n['mensaje'] ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: leido ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 9, color: Colors.grey.shade400),
                    const SizedBox(width: 2),
                    Text(
                      _getTimeAgo(n['fecha'] ?? ''),
                      style: TextStyle(fontSize: 9, color: Colors.grey.shade400),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      n['tipo'] ?? 'INFO',
                      style: TextStyle(
                        fontSize: 9,
                        color: color.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (isPedido) ...[
                      const SizedBox(width: 6),
                      Text('📦', style: TextStyle(fontSize: 9, color: AppColors.royalBlue)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!leido)
                GestureDetector(
                  onTap: () => _marcarComoLeido(n['id']),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(Icons.check_rounded, size: 14, color: Colors.green.shade600),
                  ),
                ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: () => _eliminarNotificacion(n['id']),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.close_rounded, size: 14, color: Colors.grey.shade400),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA TABLET (MEDIANA)
  // ============================================================
  Widget _buildCardTablet(Map<String, dynamic> n) {
    final color = _getNotificationColor(n['tipo'] ?? '');
    final icon = _getNotificationIcon(n['tipo'] ?? '');
    final isPedido = n['tipo'] == 'PEDIDO';
    final leido = n['leido'] ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: leido ? Colors.grey.shade100 : color.withOpacity(0.15),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        n['titulo'] ?? 'Notificación',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: leido ? Colors.grey.shade500 : AppColors.deepNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!leido)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.royalBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            n['mensaje'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: leido ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(n['fecha'] ?? ''),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 8),
              Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                n['tipo'] ?? 'INFO',
                style: TextStyle(
                  fontSize: 10,
                  color: color.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isPedido) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('📦 Pedido', style: TextStyle(fontSize: 9, color: AppColors.royalBlue)),
                ),
              ],
              const Spacer(),
              if (!leido)
                IconButton(
                  icon: Icon(Icons.check_circle_outline, size: 18, color: Colors.green.shade400),
                  onPressed: () => _marcarComoLeido(n['id']),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                onPressed: () => _eliminarNotificacion(n['id']),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TARJETA ESCRITORIO (COMPLETA)
  // ============================================================
  Widget _buildCardDesktop(Map<String, dynamic> n) {
    final color = _getNotificationColor(n['tipo'] ?? '');
    final icon = _getNotificationIcon(n['tipo'] ?? '');
    final isPedido = n['tipo'] == 'PEDIDO';
    final leido = n['leido'] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: leido ? Colors.grey.shade100 : color.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n['titulo'] ?? 'Notificación',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: leido ? Colors.grey.shade500 : AppColors.deepNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!leido)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Nuevo',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.royalBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      n['mensaje'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: leido ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                _getTimeAgo(n['fecha'] ?? ''),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
              const SizedBox(width: 10),
              Container(
                width: 2,
                height: 2,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                n['tipo'] ?? 'INFO',
                style: TextStyle(
                  fontSize: 11,
                  color: color.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isPedido) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('📦 Pedido', style: TextStyle(fontSize: 10, color: AppColors.royalBlue)),
                ),
              ],
              const Spacer(),
              if (!leido)
                TextButton.icon(
                  onPressed: () => _marcarComoLeido(n['id']),
                  icon: Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade600),
                  label: Text('Leer', style: TextStyle(fontSize: 11, color: Colors.green.shade600)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              TextButton.icon(
                onPressed: () => _eliminarNotificacion(n['id']),
                icon: Icon(Icons.delete_outline, size: 16, color: Colors.grey.shade400),
                label: Text('Eliminar', style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO VACÍO
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200, width: 2),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 50,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "¡Silencio total!",
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "No hay notificaciones recientes",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _cargarDatos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text(
              "Recargar",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 50,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 0 ? "No hay notificaciones" : "¡Todas leídas!",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _selectedFilter == 0
                ? "Tus notificaciones aparecerán aquí"
                : "No tienes notificaciones pendientes",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (_selectedFilter == 1)
            TextButton(
              onPressed: () => setState(() => _selectedFilter = 0),
              child: const Text('Ver todas'),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}