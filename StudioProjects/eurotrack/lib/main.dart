import 'package:flutter/material.dart';
import 'package:eurotrack/core/theme/app_colors.dart';
import 'package:eurotrack/features/auth/presentation/screens/login_screen.dart';
import 'package:eurotrack/features/auth/presentation/screens/splash_screen.dart';
import 'package:eurotrack/features/auth/presentation/screens/register_screen.dart';
import 'package:eurotrack/features/profile/presentation/screens/profile_screen.dart';
import 'package:eurotrack/features/favoritos/presentation/screens/favoritos_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:eurotrack/features/productos/presentation/screens/detalle_producto_screen.dart';
import 'package:eurotrack/features/home/presentation/screens/customer_home_screen.dart';
import 'package:eurotrack/features/categorias/presentation/screens/categorias_screen.dart';
import 'package:eurotrack/features/home/presentation/screens/productos_por_categoria_screen.dart';
import 'package:eurotrack/features/notificaciones/presentation/screens/notificaciones_screen.dart';
import 'package:eurotrack/features/productos/presentation/screens/productos_screen.dart';
import 'package:eurotrack/features/carrito/presentation/screens/carrito_screen.dart';
import 'package:eurotrack/features/pedidos/presentation/screens/mis_pedidos_screen.dart';
import 'package:eurotrack/features/pedidos/presentation/screens/checkout_screen.dart';
import 'package:eurotrack/features/pedidos/presentation/screens/detalle_pedido_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_pedidos_usuario_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_favoritos_usuario_screen.dart';
import 'package:eurotrack/features/admin/presentation/screens/admin_pedidos_screen.dart';
import 'package:eurotrack/features/auth/presentation/screens/SolicitarCodigoScreen.dart';
import 'package:eurotrack/features/auth/presentation/screens/IngresarCodigoScreen.dart';
import 'package:eurotrack/features/auth/presentation/screens/CambiarPasswordConCodigoScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EurotrackApp());
}

class EurotrackApp extends StatelessWidget {
  const EurotrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eurotrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.deepNavy),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());

          case '/solicitar-codigo':
            return MaterialPageRoute(builder: (_) => const SolicitarCodigoScreen());

          case '/ingresar-codigo':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => IngresarCodigoScreen(
                email: map?['email'] as String?,
                cedula: map?['cedula'] as String?,
              ),
            );

          case '/cambiar-password-codigo':
            final map = args as Map<String, String>?;
            return MaterialPageRoute(
              builder: (_) => CambiarPasswordConCodigoScreen(
                token: map?['token'] ?? '',
                email: map?['email'] ?? '',
              ),
            );

          case '/home':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => CustomerHomeScreen(
                userId: map?['id'] ?? 0,
                nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario', // ✅ Soporta ambas claves
                username: map?['username'] ?? '',
                tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
              ),
            );

          case '/perfil':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ProfileScreen(
                userId: map?['id'] ?? 0,
                nombreInicial: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                usernameInicial: map?['username'] ?? 'usuario_invitado',
              ),
            );

          case '/detalle-producto':
            final id = args as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => DetalleProductoScreen(productoId: id),
            );

          case '/categorias':
            final id = args as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => CategoriasScreen(userId: id),
            );

          case '/productos-por-categoria':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => ProductosPorCategoriaScreen(
                categoriaId: map?['categoriaId'] ?? 0,
                categoriaNombre: map?['categoriaNombre'] ?? 'Categoría',
                userId: map?['userId'] ?? 0,
              ),
            );

          case '/productos':
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => ProductosScreen(
                  userId: args,
                  nombre: 'Usuario',
                  username: '',
                  tipoCliente: 'CLIENTE',
                ),
              );
            } else {
              final map = args as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => ProductosScreen(
                  userId: map?['id'] ?? 0,
                  nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                  username: map?['username'] ?? '',
                  tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                ),
              );
            }

          case '/carrito':
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => CarritoScreen(
                  userId: args,
                  nombre: 'Usuario',
                  username: '',
                  tipoCliente: 'CLIENTE',
                ),
              );
            } else {
              final map = args as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => CarritoScreen(
                  userId: map?['id'] ?? 0,
                  nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                  username: map?['username'] ?? '',
                  tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                ),
              );
            }

          case '/mis-pedidos':
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => MisPedidosScreen(
                  userId: args,
                  nombre: 'Usuario',
                  username: '',
                  tipoCliente: 'CLIENTE',
                ),
              );
            } else {
              final map = args as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => MisPedidosScreen(
                  userId: map?['id'] ?? 0,
                  nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                  username: map?['username'] ?? '',
                  tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                ),
              );
            }

          case '/checkout':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => CheckoutScreen(
                userId: map?['userId'] ?? 0,
                nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                username: map?['username'] ?? '',
                tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                items: map?['items'] ?? [],
                total: map?['total'] ?? 0.0,
              ),
            );

          case '/detalle-pedido':
            final id = args as int? ?? 0;
            return MaterialPageRoute(
              builder: (_) => DetallePedidoScreen(pedidoId: id),
            );

          case '/admin':
            final map = args as Map<String, dynamic>? ?? {};
            return MaterialPageRoute(
              builder: (_) => AdminDashboard(
                userId: map['userId'] ?? 0,
                nombre: map['nombre'] ?? 'Administrador',
              ),
            );

          case '/favoritos':
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => FavoritosScreen(
                  userId: args,
                  nombre: 'Usuario',
                  username: '',
                  tipoCliente: 'CLIENTE',
                ),
              );
            } else {
              final map = args as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => FavoritosScreen(
                  userId: map?['id'] ?? 0,
                  nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                  username: map?['username'] ?? '',
                  tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                ),
              );
            }

          case '/admin/pedidos-usuario':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AdminPedidosUsuarioScreen(
                userId: map?['userId'] ?? 0,
                userNombre: map?['userNombre'] ?? 'Usuario',
              ),
            );

          case '/admin/favoritos-usuario':
            final map = args as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => AdminFavoritosUsuarioScreen(
                userId: map?['userId'] ?? 0,
                userNombre: map?['userNombre'] ?? 'Usuario',
              ),
            );

          case '/notificaciones':
            if (args is int) {
              return MaterialPageRoute(
                builder: (_) => NotificacionesScreen(
                  userId: args,
                  nombre: 'Usuario',
                  username: '',
                  tipoCliente: 'CLIENTE',
                ),
              );
            } else {
              final map = args as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (_) => NotificacionesScreen(
                  userId: map?['id'] ?? 0,
                  nombre: map?['nombre'] ?? map?['usuario'] ?? 'Usuario',
                  username: map?['username'] ?? '',
                  tipoCliente: map?['tipoCliente'] ?? 'CLIENTE',
                ),
              );
            }

          case '/admin/pedidos':
            return MaterialPageRoute(builder: (_) => const AdminPedidosScreen());

          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}