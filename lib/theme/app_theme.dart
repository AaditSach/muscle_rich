import 'package:flutter/material.dart';
import 'colors.dart';

// global theme  main.dart mein use hota hai poore app ke liye
class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: MRColors.mint,
      brightness: Brightness.dark,
      background: MRColors.bg,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MRColors.bg,
      // app bar globally transparent aur centered
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: MRColors.text,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: MRColors.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: MRColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      listTileTheme: const ListTileThemeData(iconColor: MRColors.mint),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: MRColors.text),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: MRColors.text),
        bodyMedium: TextStyle(color: MRColors.textDim),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}