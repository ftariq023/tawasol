import 'package:flutter/material.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';

class ThemeClass {
  static Color primaryColor = AppHelper.myColor('#0c4160');

  Color backgroundColorlight = Colors.white;
  Color backgroundColordark = const Color.fromARGB(225, 0, 0, 0);

  static ThemeData lightTheme = ThemeData(
    primaryColor: ThemeData.light().scaffoldBackgroundColor,
    colorScheme: const ColorScheme.light().copyWith(
      primary: ThemeClass.primaryColor,
      background: _themeClass.backgroundColorlight,
      // secondary: _themeClass.secondaryColor,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: ThemeData.dark().scaffoldBackgroundColor,
    colorScheme: const ColorScheme.dark().copyWith(
      primary: ThemeClass.primaryColor,
      background: _themeClass.backgroundColordark,
    ),
  );
}

ThemeClass _themeClass = ThemeClass();
