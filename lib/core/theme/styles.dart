import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppStyles {
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundBlack,
    fontFamily: GoogleFonts.inter().fontFamily,
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w200),
      headlineMedium: TextStyle(color: Colors.white70, fontSize: 32, fontWeight: FontWeight.w300),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w400),
    ),
  );
}
