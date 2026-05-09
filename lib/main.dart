import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:muscle_rich/screens/auth/auth_gate.dart';
import 'package:muscle_rich/screens/login/login_screen.dart';
import 'package:muscle_rich/screens/home/home_screen.dart';
import 'firebase_options.dart';

// app ka entry point Firebase pehle initialize kar phir app chala
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// root widget poora app ka theme aur routes yahan se control hote hai
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color accent = Color(0xFF22D3A6); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Rich',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        // saare buttons ek jaise dikhen isliye yaha define kiya
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        // input fields ka style globally set kiya
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
      initialRoute: '/',
      // saari screens ke routes yahan registered hain
      routes: {
        '/': (_) => const AuthGate(),
        '/login': (_) => const LoginScreen(),
        '/app': (_) => const HomeScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}