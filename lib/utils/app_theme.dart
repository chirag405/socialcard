import 'package:flutter/material.dart';

class AppTheme {
  // Modern iOS-inspired color palette
  static const Color primaryColor = Color(0xFF007AFF); // iOS Blue
  static const Color secondaryColor = Color(0xFF5856D6); // iOS Purple
  static const Color accentColor = Color(0xFF32D74B); // iOS Green
  static const Color errorColor = Color(0xFFFF3B30); // iOS Red
  static const Color warningColor = Color(0xFFFF9500); // iOS Orange
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemPurple = Color(0xFF5856D6);
  static const Color systemGreen = Color(0xFF32D74B);
  static const Color systemIndigo = Color(0xFF5856D6);

  // Light theme colors - iOS inspired
  static const Color lightBackground = Color(
    0xFFF2F2F7,
  ); // iOS system background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSecondaryBackground = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOnBackground = Color(0xFF000000);
  static const Color lightSecondary = Color(0xFF8E8E93); // iOS secondary text
  static const Color lightTertiary = Color(0xFFC7C7CC); // iOS tertiary text

  // Dark theme colors - iOS inspired
  static const Color darkBackground = Color(0xFF000000); // iOS dark background
  static const Color darkSurface = Color(
    0xFF1C1C1E,
  ); // iOS dark secondary background
  static const Color darkSecondaryBackground = Color(0xFF2C2C2E);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOnBackground = Color(0xFFFFFFFF);
  static const Color darkSecondary = Color(0xFF8E8E93);
  static const Color darkTertiary = Color(0xFF48484A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: '.SF Pro Display', // iOS system font
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
        outline: lightTertiary,
        surfaceContainerHighest: lightSecondaryBackground,
      ),

      // App Bar with iOS-style design
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightOnSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
      ),

      // iOS-style cards with subtle shadows
      cardTheme: CardTheme(
        color: lightSurface,
        elevation: 0,
        shadowColor: const Color(0x0D000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // iOS-style buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0x4D007AFF), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // iOS-style input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSecondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: lightSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),

      // iOS-style typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: lightOnSurface,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: lightOnSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: lightSecondary,
        ),
        bodyLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: lightOnBackground,
        ),
        bodyMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: lightOnBackground,
        ),
        bodySmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: lightSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: lightOnSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: lightSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: lightTertiary,
        ),
      ),

      // iOS-style list tiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),

      // iOS-style bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: lightSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: lightSecondary,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: '.SF Pro Display',
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
        outline: darkTertiary,
        surfaceContainerHighest: darkSecondaryBackground,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkOnSurface,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
      ),

      cardTheme: CardTheme(
        color: darkSurface,
        elevation: 0,
        shadowColor: const Color(0x4D000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: Color(0x4D007AFF), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: '.SF Pro Display',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSecondaryBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(
          color: darkSecondary,
          fontWeight: FontWeight.w400,
        ),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
          letterSpacing: -0.3,
        ),
        displaySmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkOnSurface,
          letterSpacing: -0.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: darkOnSurface,
        ),
        titleMedium: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        titleSmall: TextStyle(
          fontFamily: '.SF Pro Display',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: darkSecondary,
        ),
        bodyLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: darkOnBackground,
        ),
        bodyMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: darkOnBackground,
        ),
        bodySmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: darkSecondary,
        ),
        labelLarge: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: darkOnSurface,
        ),
        labelMedium: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: darkSecondary,
        ),
        labelSmall: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: darkTertiary,
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: darkSurface,
        selectedItemColor: primaryColor,
        unselectedItemColor: darkSecondary,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: '.SF Pro Text',
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  // Animation durations - iOS-style timing
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // iOS-style curves
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve spring = Curves.elasticOut;
}
