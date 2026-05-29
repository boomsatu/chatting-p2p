import 'package:flutter/material.dart';

/// P2P Chat app Material 3 theme with dark and light modes.
/// Uses a deep blue/cyan/purple palette for a premium, encrypted-chat aesthetic.
class AppTheme {
  AppTheme._();

  // ─── Color Palette ─────────────────────────────────────────
  static const Color _primaryLight = Color(0xFF1565C0);       // Blue 800
  static const Color _primaryDark = Color(0xFF6366F1);        // Modern Indigo
  static const Color _secondaryLight = Color(0xFF00897B);     // Teal 600
  static const Color _secondaryDark = Color(0xFF06B6D4);      // Neon Cyan
  static const Color _surfaceDark = Color(0xFF090A0F);        // Deep Obsidian Dark
  static const Color _surfaceContainerDark = Color(0xFF121420); // Deep Space Blue Navy
  static const Color _onSurfaceDark = Color(0xFFF1F5F9);      // Slate 100
  static const Color _errorColor = Color(0xFFEF4444);         // Soft Red

  // Chat bubble colors
  static const Color sentBubbleLight = Color(0xFFDCF8C6);
  static const Color sentBubbleDark = Color(0xFF312E81);      // Premium Deep Indigo 900
  static const Color receivedBubbleLight = Color(0xFFFFFFFF);
  static const Color receivedBubbleDark = Color(0xFF1E293B);   // Slate 800

  // Status colors
  static const Color onlineColor = Color(0xFF4CAF50);
  static const Color offlineColor = Color(0xFF9E9E9E);

  // ─── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryLight,
        brightness: Brightness.light,
        secondary: _secondaryLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }

  // ─── Dark Theme ────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryDark,
        brightness: Brightness.dark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        error: _errorColor,
      ),
      scaffoldBackgroundColor: _surfaceDark,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: _surfaceContainerDark,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 6,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: _surfaceContainerDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceContainerDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceContainerDark,
      ),
    );
  }
}
