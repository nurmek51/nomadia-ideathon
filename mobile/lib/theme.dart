import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFF2EDE3);
  static const Color surface = Color(0xFFFFFBF4);
  static const Color surfaceMuted = Color(0xFFE4D8C2);
  static const Color ink = Color(0xFF16120F);
  static const Color primary = Color(0xFFD85C41);
  static const Color secondary = Color(0xFFB88B2F);
  static const Color success = Color(0xFF2E7D4F);
  static const Color warning = Color(0xFFB56B1F);
  static const Color danger = Color(0xFFA63D2F);
  static const Color line = Color(0xFF2B221C);

  static ThemeData light() {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: danger,
      onSurface: ink,
      onPrimary: Colors.white,
    );

    final textTheme = GoogleFonts.ibmPlexSansTextTheme().copyWith(
      headlineLarge: GoogleFonts.oswald(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        height: 1.05,
        color: ink,
      ),
      headlineMedium: GoogleFonts.oswald(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.05,
        color: ink,
      ),
      titleLarge: GoogleFonts.ibmPlexSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: GoogleFonts.ibmPlexSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      bodyMedium: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: ink,
      ),
      labelLarge: GoogleFonts.ibmPlexSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: base,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: line, width: 1.1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: line, width: 1.1),
          textStyle: textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line, width: 1.1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: line, width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.6),
        ),
        labelStyle: textTheme.bodyMedium,
      ),
      dividerColor: line.withValues(alpha: 0.18),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceMuted,
        side: const BorderSide(color: line, width: 1),
        selectedColor: secondary.withValues(alpha: 0.18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: textTheme.bodyMedium!,
      ),
    );
  }
}
