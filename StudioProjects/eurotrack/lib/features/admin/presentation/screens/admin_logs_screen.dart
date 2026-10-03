import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/widgets/responsive_wrapper.dart';
import 'package:eurotrack/features/admin/data/services/admin_service.dart';

class AdminLogsScreen extends StatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  State<AdminLogsScreen> createState() => AdminLogsScreenState();
}

class AdminLogsScreenState extends State<AdminLogsScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _filteredLogs = [];
  bool _isLoading = true;

  // Filtros
  String _filterAccion = 'TODAS';
  String _filterUsuario = '';
  String _filterMes = 'TODOS';
  String _filterAntiguedad = 'TODOS';
  List<String> _accionesDisponibles = ['TODAS'];
  List<String> _mesesDisponibles = ['TODOS'];
  List<String> _antiguedadOpciones = [
    'TODOS',
    'Última hora',
    'Últimas 24h',
    'Últimos 7 días',
    'Últimos 30 días',
    'Últimos 90 días',
  ];

  @override
  void initState() {
    super.initState();
    _cargarLogs();
  }

  void cargarLogs() {
    _cargarLogs();
  }

  Future<void> _cargarLogs() async {
    setState(() => _isLoading = true);
    final logs = await _adminService.getLogs();
    setState(() {
      _logs = logs;
      _isLoading = false;
      _actualizarFiltros();
      _aplicarFiltros();
    });
  }

  void _actualizarFiltros() {
    // Acciones disponibles
    final acciones = _logs.map((l) => l['accion']?.toString() ?? 'DESCONOCIDO').toSet().toList();
    _accionesDisponibles = ['TODAS', ...acciones];

    // Meses disponibles
    final meses = _logs.map((l) {
      final fecha = l['fecha']?.toString() ?? '';
      if (fecha.isNotEmpty) {
        try {
          final date = DateTime.parse(fecha);
          return '${date.year}-${date.month.toString().padLeft(2, '0')}';
        } catch (e) {
          return '';
        }
      }
      return '';
    }).where((m) => m.isNotEmpty).toSet().toList();
    _mesesDisponibles = ['TODOS', ...meses];
  }

  void _aplicarFiltros() {
    var filtered = _logs;

    // Filtrar por acción
    if (_filterAccion != 'TODAS') {
      filtered = filtered.where((l) => l['accion'] == _filterAccion).toList();
    }

    // Filtrar por usuario
    if (_filterUsuario.isNotEmpty) {
      filtered = filtered.where((l) {
        final usuario = l['usuario']?.toString().toLowerCase() ?? '';
        return usuario.contains(_filterUsuario.toLowerCase());
      }).toList();
    }

    // Filtrar por mes
    if (_filterMes != 'TODOS') {
      filtered = filtered.where((l) {
        final fecha = l['fecha']?.toString() ?? '';
        if (fecha.isEmpty) return false;
        try {
          final date = DateTime.parse(fecha);
          final mesKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
          return mesKey == _filterMes;
        } catch (e) {
          return false;
        }
      }).toList();
    }

    // Filtrar por antigüedad
    if (_filterAntiguedad != 'TODOS') {
      final now = DateTime.now();
      filtered = filtered.where((l) {
        final fecha = l['fecha']?.toString() ?? '';
        if (fecha.isEmpty) return false;
        try {
          final date = DateTime.parse(fecha);
          final diff = now.difference(date);

          switch (_filterAntiguedad) {
            case 'Última hora':
              return diff.inHours < 1;
            case 'Últimas 24h':
              return diff.inDays < 1;
            case 'Últimos 7 días':
              return diff.inDays < 7;
            case 'Últimos 30 días':
              return diff.inDays < 30;
            case 'Últimos 90 días':
              return diff.inDays < 90;
            default:
              return true;
          }
        } catch (e) {
          return false;
        }
      }).toList();
    }

    setState(() {
      _filteredLogs = filtered;
    });
  }

  Color _getSeveridadColor(String? nivel) {
    switch (nivel) {
      case 'ERROR': return Colors.red;
      case 'WARNING': return Colors.orange;
      case 'CRITICAL': return Colors.deepPurple;
      default: return Colors.green;
    }
  }

  Color _getAccionColor(String accion) {
    if (accion.contains('CREATE') || accion.contains('REGISTRO')) return Colors.green;
    if (accion.contains('UPDATE') || accion.contains('EDIT')) return Colors.blue;
    if (accion.contains('DELETE') || accion.contains('ELIMINAR')) return Colors.red;
    if (accion.contains('LOGIN')) return Colors.orange;
    if (accion.contains('ERROR')) return Colors.red;
    return Colors.grey;
  }

  IconData _getAccionIcon(String accion) {
    if (accion.contains('CREATE') || accion.contains('REGISTRO')) return Icons.add_circle;
    if (accion.contains('UPDATE') || accion.contains('EDIT')) return Icons.edit;
    if (accion.contains('DELETE') || accion.contains('ELIMINAR')) return Icons.delete;
    if (accion.contains('LOGIN_EXITOSO')) return Icons.login;
    if (accion.contains('LOGIN_FALLIDO')) return Icons.login;
    if (accion.contains('ERROR')) return Icons.error;
    return Icons.info;
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
            "Auditoría y Logs",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.deepNavy,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _cargarLogs,
              tooltip: 'Recargar logs',
            ),
          ],
        ),
        body: Column(
          children: [
            _buildFilters(isDesktop),
            _buildResultCounter(),
            Expanded(
              child: _isLoading
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.royalBlue),
                    SizedBox(height: 16),
                    Text("Cargando logs...", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
                  : _filteredLogs.isEmpty
                  ? _buildEmptyState()
                  : isDesktop
                  ? _buildDesktopLogsList()
                  : _buildMobileLogsList(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== FILTROS ====================
  Widget _buildFilters(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: isDesktop
          ? _buildDesktopFilters()
          : _buildMobileFilters(),
    );
  }

  Widget _buildDesktopFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildAccionDropdown(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildUsuarioTextField(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildMesDropdown(),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: _buildAntiguedadDropdown(),
        ),
        const SizedBox(width: 12),
        _buildLimpiarButton(),
      ],
    );
  }

  Widget _buildMobileFilters() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildAccionDropdown(),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildUsuarioTextField(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildMesDropdown(),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: _buildAntiguedadDropdown(),
            ),
          ],
        ),
        if (_filterAccion != 'TODAS' || _filterUsuario.isNotEmpty ||
            _filterMes != 'TODOS' || _filterAntiguedad != 'TODOS')
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _limpiarFiltros,
              child: const Text(
                'Limpiar todos',
                style: TextStyle(fontSize: 12, color: AppColors.royalBlue),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLimpiarButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _limpiarFiltros,
        icon: const Icon(Icons.clear, size: 16),
        label: const Text("Limpiar"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.grey[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  void _limpiarFiltros() {
    setState(() {
      _filterAccion = 'TODAS';
      _filterUsuario = '';
      _filterMes = 'TODOS';
      _filterAntiguedad = 'TODOS';
      _aplicarFiltros();
    });
  }

  Widget _buildAccionDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        value: _filterAccion,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Acción',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
        ),
        items: _accionesDisponibles.map((accion) {
          return DropdownMenuItem(
            value: accion,
            child: Text(
              accion,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _filterAccion = value!;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  Widget _buildUsuarioTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Usuario',
          hintText: 'Buscar...',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
          suffixIcon: _filterUsuario.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 16),
            onPressed: () {
              setState(() {
                _filterUsuario = '';
                _aplicarFiltros();
              });
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _filterUsuario = value;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  Widget _buildMesDropdown() {
    final mesLabels = <String, String>{
      'TODOS': 'Todos los meses',
    };

    // Agregar meses disponibles con formato legible
    for (final mes in _mesesDisponibles) {
      if (mes != 'TODOS') {
        try {
          final parts = mes.split('-');
          final year = int.parse(parts[0]);
          final month = int.parse(parts[1]);
          final monthName = _getMonthName(month);
          mesLabels[mes] = '$monthName $year';
        } catch (e) {
          mesLabels[mes] = mes;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        value: _filterMes,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Mes',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
        ),
        items: _mesesDisponibles.map((mes) {
          return DropdownMenuItem(
            value: mes,
            child: Text(
              mesLabels[mes] ?? mes,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _filterMes = value!;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return names[month - 1];
  }

  Widget _buildAntiguedadDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DropdownButtonFormField<String>(
        value: _filterAntiguedad,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Antigüedad',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          isDense: true,
        ),
        items: _antiguedadOpciones.map((opcion) {
          return DropdownMenuItem(
            value: opcion,
            child: Text(opcion),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _filterAntiguedad = value!;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  // ==================== RESULT COUNTER ====================
  Widget _buildResultCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${_filteredLogs.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'registros encontrados',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (_filterAccion != 'TODAS' || _filterUsuario.isNotEmpty ||
              _filterMes != 'TODOS' || _filterAntiguedad != 'TODOS')
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_alt,
                      size: 14,
                      color: AppColors.royalBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Filtros aplicados',
                      style: TextStyle(
                        color: AppColors.royalBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics_outlined,
              size: 60,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No hay logs con estos filtros",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Prueba ajustando los filtros de búsqueda",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _limpiarFiltros,
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Limpiar filtros'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.royalBlue,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== LOG LISTS ====================
  Widget _buildMobileLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogCardMobile(log);
      },
    );
  }

  Widget _buildDesktopLogsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredLogs.length,
      itemBuilder: (context, index) {
        final log = _filteredLogs[index];
        return _buildLogCardDesktop(log);
      },
    );
  }

  // ==================== LOG CARDS ====================
  Widget _buildLogCardMobile(Map<String, dynamic> log) {
    final accion = log['accion']?.toString() ?? 'DESCONOCIDO';
    final usuario = log['usuario']?.toString() ?? 'ANONIMO';
    final descripcion = log['descripcion']?.toString() ?? '';
    final fecha = log['fecha']?.toString() ?? '';
    final nivel = log['nivelSeveridad']?.toString() ?? 'INFO';
    final exitoso = log['exitoso'] ?? true;
    final mensajeError = log['mensajeError']?.toString();
    final detalles = log['detalles']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLogDetails(context, log),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _getAccionColor(accion).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getAccionIcon(accion),
                      color: _getAccionColor(accion),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                accion,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.deepNavy,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getSeveridadColor(nivel).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                nivel ?? 'INFO',
                                style: TextStyle(
                                  color: _getSeveridadColor(nivel),
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (!exitoso)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'FALLIDO',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          usuario,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatearFecha(fecha),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                descripcion,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (mensajeError != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mensajeError,
                          style: const TextStyle(color: Colors.red, fontSize: 11),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogCardDesktop(Map<String, dynamic> log) {
    final accion = log['accion']?.toString() ?? 'DESCONOCIDO';
    final usuario = log['usuario']?.toString() ?? 'ANONIMO';
    final descripcion = log['descripcion']?.toString() ?? '';
    final fecha = log['fecha']?.toString() ?? '';
    final nivel = log['nivelSeveridad']?.toString() ?? 'INFO';
    final exitoso = log['exitoso'] ?? true;
    final mensajeError = log['mensajeError']?.toString();
    final detalles = log['detalles']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showLogDetails(context, log),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _getAccionColor(accion).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAccionIcon(accion),
                      color: _getAccionColor(accion),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    accion,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.deepNavy,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _getSeveridadColor(nivel).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      nivel ?? 'INFO',
                                      style: TextStyle(
                                        color: _getSeveridadColor(nivel),
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!exitoso)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'FALLIDO',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                usuario,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatearFecha(fecha),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                descripcion,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (mensajeError != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mensajeError,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==================== DIALOGO DE DETALLES ====================
  void _showLogDetails(BuildContext context, Map<String, dynamic> log) {
    final accion = log['accion']?.toString() ?? 'DESCONOCIDO';
    final usuario = log['usuario']?.toString() ?? 'ANONIMO';
    final descripcion = log['descripcion']?.toString() ?? '';
    final fecha = log['fecha']?.toString() ?? '';
    final nivel = log['nivelSeveridad']?.toString() ?? 'INFO';
    final exitoso = log['exitoso'] ?? true;
    final mensajeError = log['mensajeError']?.toString();
    final detalles = log['detalles']?.toString() ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getAccionColor(accion).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getAccionIcon(accion),
                      color: _getAccionColor(accion),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          accion,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.deepNavy,
                          ),
                        ),
                        Text(
                          usuario,
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getSeveridadColor(nivel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      nivel ?? 'INFO',
                      style: TextStyle(
                        color: _getSeveridadColor(nivel),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Descripción',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                descripcion,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Fecha y hora',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatearFechaCompleta(fecha),
                style: const TextStyle(fontSize: 14),
              ),
              if (mensajeError != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Text(
                    mensajeError,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
              if (detalles.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Detalles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    detalles,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== UTILIDADES ====================
  String _formatearFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays > 30) {
        return '${diff.inDays ~/ 30}m';
      } else if (diff.inDays > 0) {
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m';
      } else {
        return '${diff.inSeconds}s';
      }
    } catch (e) {
      return fecha;
    }
  }

  String _formatearFechaCompleta(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return fecha;
    }
  }
}