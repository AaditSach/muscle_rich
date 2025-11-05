import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';

void main() => runApp(const MuscleRichApp());

class MuscleRichApp extends StatelessWidget {
  const MuscleRichApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Rich',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5E60CE)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: const HomeScreen(),
    );
  }
}