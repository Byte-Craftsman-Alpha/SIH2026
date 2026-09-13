import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class AppTheme {
  static ThemeData get lightTheme => buildMediKioskTheme(isDark: false);
  static ThemeData get darkTheme => buildMediKioskTheme(isDark: true);
}
