import 'package:flutter/material.dart';
import '../../design/tokens.dart';

/// Legacy bridge pointing to MDS v1.0 [T] tokens.
abstract class AppTextStyles {
  static TextStyle displayLarge = T.displayL();
  static TextStyle displayMedium = T.displayM();
  static TextStyle headlineLarge = T.headlineL();
  static TextStyle headlineMedium = T.headlineM();
  static TextStyle titleLarge = T.titleL();
  static TextStyle titleMedium = T.titleM();
  static TextStyle bodyLarge = T.bodyL();
  static TextStyle bodyMedium = T.bodyM();
  static TextStyle labelLarge = T.labelL();
  static TextStyle labelMedium = T.labelM();
  static TextStyle caption = T.caption();

  static TextStyle numDisplay = T.numDisplay();
  static TextStyle numLarge = T.numL();
  static TextStyle numMedium = T.numM();
}
