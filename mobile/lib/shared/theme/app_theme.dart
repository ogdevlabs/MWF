import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _sageGreen = Color(0xFF8FAE8B);
  static const Color _sageGreenDark = Color(0xFF6B8F67);
  static const Color _sageGreenLight = Color(0xFFB5D4B1);
  static const Color _background = Color(0xFFFAFAFA);
  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF1C1C1C);
  static const Color _onSurfaceVariant = Color(0xFF6B6B6B);
  static const Color _error = Color(0xFFD32F2F);

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: _sageGreen,
      primaryContainer: _sageGreenLight,
      secondary: _sageGreenDark,
      surface: _surface,
      error: _error,
      onPrimary: Colors.white,
      onSurface: _onSurface,
      onSurfaceVariant: _onSurfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      appBarTheme: const AppBarTheme(
        backgroundColor: _surface,
        foregroundColor: _onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _sageGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _sageGreenLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _sageGreen, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _onSurface,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: _onSurface),
        bodyMedium: TextStyle(fontSize: 14, color: _onSurfaceVariant),
      ),
    );
  }
}
