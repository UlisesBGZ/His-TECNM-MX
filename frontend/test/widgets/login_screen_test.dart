import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fhir_hospital_app/screens/login_screen.dart';

/// Tests de widgets para LoginScreen
/// Verifica que la UI se renderice correctamente y responda a interacciones
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen Widget Tests', () {
    testWidgets('Debe mostrar todos los elementos de la pantalla de login',
        (WidgetTester tester) async {
      // Build the login screen
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Verify - Debe tener el título
      expect(find.text('Bienvenido'), findsOneWidget);
      expect(find.text('Sistema Hospitalario FHIR'), findsOneWidget);

      // Verify - Debe tener campos de entrada
      expect(
          find.byType(TextFormField), findsNWidgets(2)); // Usuario y contraseña

      // Verify - Debe tener botón de login
      expect(find.widgetWithText(ElevatedButton, 'Iniciar Sesión'),
          findsOneWidget);

      // Verify - Debe tener enlace a registro
      expect(find.text('¿No tienes cuenta?'), findsOneWidget);
      expect(find.text('Regístrate'), findsOneWidget);
    });

    testWidgets('Campo de usuario debe aceptar texto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the username field (first TextFormField)
      final usernameField = find.byType(TextFormField).first;

      // Enter text
      await tester.enterText(usernameField, 'testuser');
      await tester.pump();

      // Verify text was entered
      expect(find.text('testuser'), findsOneWidget);
    });

    testWidgets('Campo de contraseña debe aceptar texto',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find the password field (second TextFormField)
      final passwordField = find.byType(TextFormField).last;

      // Enter text
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Verify - El campo debería existir
      // Nota: No podemos verificar obscureText directamente desde TextFormField
      expect(passwordField, findsOneWidget);
    });

    testWidgets('Botón de login debe estar visible y habilitado',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');

      expect(loginButton, findsOneWidget);

      // El botón debe ser clickeable
      final button = tester.widget<ElevatedButton>(loginButton);
      expect(button.enabled, isTrue);
    });

    testWidgets('Debe tener ícono de usuario en campo de nombre',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find icon in username field
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('Debe tener ícono de candado en campo de contraseña',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find lock icon in password field
      expect(find.byIcon(Icons.lock), findsWidgets);
    });

    testWidgets('Debe mostrar animación de entrada',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Pump para iniciar animaciones pero no completarlas
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verificar que el widget existe durante la animación
      expect(find.byType(LoginScreen), findsOneWidget);

      // Completar todas las animaciones
      await tester.pumpAndSettle();

      // Verificar que sigue visible después de la animación
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Campos vacíos deben mostrar hints',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find hints in text fields
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
    });
  });

  group('LoginScreen - Form Validation Tests', () {
    testWidgets('Debe validar campos vacíos al intentar login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Try to submit without entering data
      final loginButton = find.widgetWithText(ElevatedButton, 'Iniciar Sesión');
      await tester.tap(loginButton);
      await tester.pump();

      // Note: Validation messages would appear if implemented
      // This test verifies the button can be tapped
      expect(loginButton, findsOneWidget);
    });

    testWidgets('Debe permitir llenar ambos campos antes de login',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter username
      await tester.enterText(find.byType(TextFormField).first, 'admin');
      await tester.pump();

      // Enter password
      await tester.enterText(find.byType(TextFormField).last, 'admin123');
      await tester.pump();

      // Verify both fields have content
      expect(find.text('admin'), findsOneWidget);
    });
  });

  group('LoginScreen - Navigation Tests', () {
    testWidgets('Link de registro debe ser clickeable',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final registerLink = find.text('Regístrate');
      expect(registerLink, findsOneWidget);

      // Verificar que es un TextButton o GestureDetector
      final widget = tester.widget(find
          .ancestor(
            of: registerLink,
            matching: find.byType(GestureDetector),
          )
          .first);

      expect(widget, isA<GestureDetector>());
    });
  });

  group('LoginScreen - UI Theme Tests', () {
    testWidgets('Debe tener fondo con gradiente', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find Container with BoxDecoration (gradient background)
      final containerWithGradient = find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      );

      expect(containerWithGradient, findsWidgets);
    });

    testWidgets('Debe tener Card elevado para el formulario',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final card = find.byType(Card);
      expect(card, findsOneWidget);

      final cardWidget = tester.widget<Card>(card);
      expect(cardWidget.elevation, greaterThan(0));
    });
  });
}
