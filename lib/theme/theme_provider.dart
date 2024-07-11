import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:tawasol/theme/theme_data.dart';
import 'package:tawasol/app_models/app_utilities/app_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  final storage = FlutterSecureStorage();

  static Color primaryColor = AppHelper.myColor('#0c4160');

  ThemeData _themeData = ThemeClass.lightTheme;

  ThemeData get themeData => _themeData;

  static bool isDarkMode = false, adaptSystemTheme = false;

  ThemeMode getThemeMode() {
    if (adaptSystemTheme) {
      // if (ThemeMode.system == ThemeMode.light)
      //   isDarkMode = false;
      // else
      //   isDarkMode = true;
      return ThemeMode.system;
    }
    if (isDarkMode) return ThemeMode.dark;
    return ThemeMode.light;
  }

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  //

  static void setAdaptSystemTheme(String value) {
    if (value == "true")
      adaptSystemTheme = true;
    else
      adaptSystemTheme = false;
  }

  static void setIsDarkMode(String value) {
    if (value == "true")
      isDarkMode = true;
    else
      isDarkMode = false;
  }

  static void setPrimaryColor(String clr) {
    primaryColor = AppHelper.myColor(clr);
  }

  // static bool isDarkModeCheck() {
  //   if (adaptSystemTheme) {
  //     if (ThemeMode.system == ThemeMode.light) return false;
  //     return true;
  //   }
  //   else {
  //     if (isDarkMode) true;
  //     return false;
  //   }
  // }

  static bool isDarkModeCheck() {
    if (adaptSystemTheme) {
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkModee = brightness == Brightness.dark;
      if (isDarkModee) return true;
      return false;
    } else {
      if (isDarkMode) return true;
      return false;
    }
  }

  static Color lightenClr(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
      c.alpha,
      c.red + ((255 - c.red) * p).round(),
      c.green + ((255 - c.green) * p).round(),
      c.blue + ((255 - c.blue) * p).round(),
    );
  }

  //

  void toggleAdaptSystemTheme() {
    adaptSystemTheme = !adaptSystemTheme;
    notifyListeners();
    storage.write(key: "adaptSystemTheme", value: adaptSystemTheme ? "true" : "false");
  }

  void toggleTheme() {
    if (_themeData == ThemeClass.lightTheme) {
      themeData = ThemeClass.darkTheme;
      isDarkMode = true;
    } else {
      themeData = ThemeClass.lightTheme;
      isDarkMode = false;
    }

    storage.write(key: "isDarkMode", value: isDarkMode ? "true" : "false");
  }

  void changePrimClr(Color newClr, ctx, String clr) {
    primaryColor = newClr;
    ThemeClass.primaryColor = newClr;
    // Provider.of<ThemeClass>(ctx, listen: false).primaryColor = newClr;
    notifyListeners();
    storage.write(key: "savedClr", value: clr);
  }
}
