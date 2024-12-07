import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Match',
      theme: ThemeData(
        fontFamily: 'Geist',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          displaySmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 1.3,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF673AB7),
          onPrimary: Colors.white,
          primaryContainer: Color(0xFF7E57C2),
          onPrimaryContainer: Colors.white,
          secondary: Color(0xFFE040FB),
          onSecondary: Colors.white,
          secondaryContainer: Color(0xFFEA80FC),
          onSecondaryContainer: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black87,
          error: Colors.red,
          onError: Colors.white,
          errorContainer: Color(0xFFFFCDD2),
          onErrorContainer: Colors.red,
          outline: Colors.grey,
          outlineVariant: Color(0xFFE0E0E0),
          surfaceContainerHighest: Color(0xFFF5F5F5),
          onSurfaceVariant: Colors.black87,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
      },
    );
  }
}
