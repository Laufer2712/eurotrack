import 'package:flutter_test/flutter_test.dart';
import 'package:eurotrack/main.dart';
import 'package:eurotrack/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Verificar carga inicial de Eurotrack', (WidgetTester tester) async {
    // Carga la aplicación Eurotrack
    await tester.pumpWidget(const EurotrackApp());

    // Verifica que al iniciar se muestre la pantalla de Login
    // Buscamos el texto 'EUROTRACK' que pusimos en el Login
    expect(find.text('EUROTRACK'), findsOneWidget);

    // Verifica que existe un botón o texto de 'INGRESAR'
    expect(find.text('Ingresar'), findsOneWidget);
  });
}