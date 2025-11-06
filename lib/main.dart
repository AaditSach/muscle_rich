import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home/home_screen.dart';

void main() => runApp(const MuscleRichApp());

class MuscleRichApp extends StatelessWidget {
  const MuscleRichApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Rich',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const HomeScreen(),
    );
  }
}