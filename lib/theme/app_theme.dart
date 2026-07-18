import 'package:flutter/material.dart';

/// Central design token file for the entire app.
/// All screens and widgets should reference these values.
class AppTheme {
  AppTheme._();

  // ── Color Palette ────────────────────────────────────────────
  static const Color bg = Color(0xFF12121F);
  static const Color surface = Color(0xFF1E1E30);
  static const Color surfaceHigh = Color(0xFF252540);
  static const Color accent = Color(0xFFFFC107);
  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF9090AA);
  static const Color error = Color(0xFFCF6679);
  static const Color success = Colors.greenAccent;
  static const Color warning = Colors.orangeAccent;

  // ── ThemeData ────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: surface,
        error: error,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: textSecondary,
        indicatorColor: accent,
        dividerColor: surfaceHigh,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        hintStyle: TextStyle(color: textSecondary),
        labelStyle: TextStyle(color: textSecondary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 17),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 15),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        bodySmall: TextStyle(color: textSecondary, fontSize: 11),
        labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w800),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerTheme: const DividerThemeData(color: surfaceHigh, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        titleTextStyle: const TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: const TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
