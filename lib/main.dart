import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:study_go/pages/home_page.dart';
import 'package:study_go/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:study_go/firebase_options.dart';
import 'package:study_go/screens/splash_screen.dart';
import 'package:study_go/services/auth_service.dart'; // ← asegurarse de importar

final AuthService globalAuthService = AuthService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService(); // ← instanciamos AuthService

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'StudyGo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: SplashScreen(authService: globalAuthService), // ← pasamos authService
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español
        Locale('en', 'US'), // Inglés
      ],
    );
  }
}

