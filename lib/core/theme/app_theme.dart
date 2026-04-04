import 'package:flutter/material.dart';

// 색상 상수
const kBgPrimary = Color(0xFF0D0F1C);
const kBgSurface = Color(0xFF161929);
const kBgElevated = Color(0xFF1E2235);
const kBgCard = Color(0xFF1A1D2E);

const kAccentPurple = Color(0xFF7B5EA7);
const kAccentViolet = Color(0xFF9B7FD4);
const kAccentLight = Color(0xFFB59FE8);

const kTextPrimary = Colors.white;
const kTextSecondary = Color(0xFFB0B8C8);
const kTextMuted = Color(0xFF6B7280);

const kSuccess = Color(0xFF4CAF8B);
const kPending = Color(0xFF4A9EE0);
const kError = Color(0xFFE05555);
const kWarning = Color(0xFFE0A055);

const kBorderColor = Color(0xFF2A2D3E);

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBgPrimary,
    colorScheme: const ColorScheme.dark(
      primary: kAccentViolet,
      secondary: kAccentPurple,
      surface: kBgSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: kTextPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBgPrimary,
      foregroundColor: kTextPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kBgSurface,
      selectedItemColor: kAccentViolet,
      unselectedItemColor: kTextMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: kBgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBorderColor, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccentViolet,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return kTextMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return kAccentViolet;
        return kBgElevated;
      }),
    ),
    dividerTheme: const DividerThemeData(
      color: kBorderColor,
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: kTextPrimary),
      bodyMedium: TextStyle(color: kTextSecondary),
      bodySmall: TextStyle(color: kTextMuted),
      labelLarge: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w600),
    ),
    useMaterial3: true,
  );
}
