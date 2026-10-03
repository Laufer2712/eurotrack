import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/core/network/api_config.dart';
import 'package:eurotrack/features/home/presentation/widgets/home_app_bar.dart';
import 'package:eurotrack/features/carrito/data/services/carrito_service.dart';
import 'package:eurotrack/features/pedidos/data/services/pedido_service.dart';

class CheckoutScreen extends StatefulWidget {
  final int userId;
  final String nombre;
  final String username;
  final String tipoCliente;
  final List<Map<String, dynamic>> items;
  final double total;

  const CheckoutScreen({
    super.key,
    required this.userId,
    required this.nombre,
    required this.username,
    required this.tipoCliente,
    required this.items,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final PedidoService _pedidoService = PedidoService();
  final CarritoService _carritoService = CarritoService();

  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  String _metodoPago = "Efectivo";
  bool _isLoading = false;
  String? _fotoPerfilBase64;

  final List<String> _metodosPago = ["Efectivo", "Transferencia", "Tarjeta de Crédito", "Pago Móvil"];

  @override
  void initState() {
    super.initState();
    _carritoService.loadCarrito();
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

  @override
  void dispose() {
    _direccionController.dispose();
    super.dispose();
  }

  Future<void> _procesarPedido() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final itemsParaBackend = widget.items.map((item) => {
        "productoId": item["productoId"],
        "cantidad": item["cantidad"],
      }).toList();

      final result = await _pedidoService.crearPedido(
        usuarioId: widget.userId,
        direccionEntrega: _direccionController.text,
        metodoPago: _metodoPago,
        items: itemsParaBackend,
      );

      await _carritoService.vaciar();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("¡Pedido realizado con éxito!"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          '/mis-pedidos',
          arguments: {
            'id': widget.userId,
            'usuario': widget.nombre,
            'username': widget.username,
            'tipoCliente': widget.tipoCliente,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fotoPerfil = _decodificarBase64(_fotoPerfilBase64);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
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
            'usuario': widget.nombre,
            'username': widget.username,
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.royalBlue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResumenProductos(),
            const SizedBox(height: 24),
            _buildFormularioEntrega(),
            const SizedBox(height: 24),
            _buildResumenPago(),
            const SizedBox(height: 24),
            _buildBotonPagar(),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenProductos() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Productos",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const Divider(),
            ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "${item['nombre']} x${item['cantidad']}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    "\$${item['subtotal'].toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioEntrega() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Información de Entrega",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
              const Divider(),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText: "Dirección de entrega",
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Ingresa una dirección";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: const InputDecoration(
                  labelText: "Método de pago",
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                items: _metodosPago.map((metodo) {
                  return DropdownMenuItem(
                    value: metodo,
                    child: Text(metodo),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _metodoPago = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenPago() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen de Pago",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.deepNavy,
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Subtotal"),
                Text("\$${widget.total.toStringAsFixed(2)}"),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Envío"),
                const Text("Calculado en destino"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "\$${widget.total.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonPagar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: _procesarPedido,
        child: const Text(
          "Confirmar Pedido",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}