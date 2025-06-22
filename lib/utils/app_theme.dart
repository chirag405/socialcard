import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color accentColor = Color(0xFF06B6D4);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnBackground = Color(0xFF374151);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkOnSurface = Color(0xFFF9FAFB);
  static const Color darkOnBackground = Color(0xFFE5E7EB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // // fontFamily: 'Poppins', // Using system fonts for now
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: lightSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: lightOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          // // fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
        ),
        displayMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
        ),
        displaySmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineSmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleSmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: lightOnBackground,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // // fontFamily: 'Poppins', // Using system fonts for now
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
        surface: darkSurface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onError: Colors.white,
        onSurface: darkOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),
      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            // fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
        ),
        displayMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
        ),
        displaySmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineSmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleSmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        bodyLarge: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
        bodyMedium: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
        bodySmall: TextStyle(
          // fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkOnBackground,
        ),
      ),
    );
  }
}
