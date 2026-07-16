import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme {
    return GoogleFonts.cairoTextTheme().copyWith(
      displayLarge: GoogleFonts.cairo(fontSize: 57, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.cairo(fontSize: 45, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold),
      headlineLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.normal),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}
