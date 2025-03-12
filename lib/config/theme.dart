import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFCE4EC); // Soft Pink (Backgrounds)
  static const Color secondary = Color(
    0xFFD81B60,
  ); // Deep Rose (Buttons, Highlights)
  static const Color accent = Color(
    0xFFF8BBD0,
  ); // Light Pink (Icons, Borders, Dots)
  static const Color textColor = Color(
    0xFF757575,
  ); // Soft Gray (For Descriptions)
}

final ThemeData beautyTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.primary,
  primaryColor: AppColors.secondary,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: Size(double.infinity, 50),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.accent),
    ),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.textColor),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textColor),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
  ),
);
