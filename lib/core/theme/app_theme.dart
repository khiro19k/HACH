import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sophisticated Light Green Palette
  static const Color primaryColor = Color(0xFF10B981); // Vibrant Emerald (Light Green)
  static const Color accentColor = Color(0xFF34D399);  // Brighter Mint
  static const Color bgGradientStart = Color(0xFFECFDF5); // Airy Green Tint
  static const Color bgGradientEnd = Color(0xFFF9FAFB);
  static const Color glassColor = Color(0xCCFFFFFF);
  static const Color textColor = Color(0xFF064E3B); // Keep text dark for readability
  static const Color secondaryTextColor = Color(0xFF059669); // Medium Emerald

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Handled by gradient
      textTheme: GoogleFonts.outfitTextTheme(), // Upgraded to Outfit
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        color: glassColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: const StadiumBorder(), // Pill-shaped
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          elevation: 2,
        ),
      ),
    );
  }
}
