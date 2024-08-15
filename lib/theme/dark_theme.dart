import 'package:flutter/material.dart';
// ThemeData dark_theme=ThemeData(
//   colorScheme: ColorScheme.dark(
//     background: Colors.grey.shade900,
//     primary: Colors.grey.shade600,
//     secondary: Colors.grey.shade700,
//     tertiary: Colors.grey.shade800,
//     inversePrimary: Colors.grey.shade700
//
//   )
// );
import 'package:flutter/material.dart';

ThemeData dark_theme = ThemeData(
  colorScheme: ColorScheme.dark(
      background: Colors.black87, // Darker background
      primary: Colors.grey.shade300, // Lighter primary color
      secondary: Colors.grey.shade400, // Adjusted secondary color
      tertiary: Colors.grey.shade500, // Adjusted tertiary color
      inversePrimary: Colors.grey.shade200 // Lighter inverse primary
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // Primary text color
    bodyMedium: TextStyle(color: Colors.grey.shade300), // Secondary text color
  ),
);