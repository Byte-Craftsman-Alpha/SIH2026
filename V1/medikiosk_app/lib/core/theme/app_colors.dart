import 'package:flutter/material.dart';
import '../../design/tokens.dart';

/// Legacy bridge pointing to MDS v1.0 [C] tokens.
abstract class AppColors {
  // Light Theme
  static const Color surfaceLight = C.canvas;
  static const Color surfaceVariantLight = C.surface;
  static const Color onSurfaceLight = C.textHeading;
  static const Color onSurfaceVariantLight = C.textMuted;
  static const Color primaryLight = C.primary;
  static const Color primaryVariantLight = C.primaryDark;
  static const Color accentLight = C.accent;
  static const Color successLight = C.success;
  static const Color errorLight = C.danger;
  static const Color emergencyLight = C.danger;
  static const Color ayushLight = C.primary;
  static const Color borderLight = C.borderSubtle;
  static const Color cardShadowLight = Color(0x0A2B2722);

  // Dark Theme
  static const Color surfaceDark = C.canvasDark;
  static const Color surfaceVariantDark = C.surfaceDark;
  static const Color onSurfaceDark = C.textHeadingDark;
  static const Color onSurfaceVariantDark = C.textMutedDark;
  static const Color primaryDark = C.primaryDarkTheme;
  static const Color accentDark = C.accentDarkTheme;
  static const Color successDark = C.success;
  static const Color errorDark = C.dangerDarkTheme;
  static const Color emergencyDark = C.dangerDarkTheme;
  static const Color ayushDark = C.primaryDarkTheme;
  static const Color borderDark = C.borderSubtleDark;

  // Prakriti
  static const Color vata = C.vata;
  static const Color pitta = C.pitta;
  static const Color kapha = C.kapha;
  static const Color chartTrack = C.chartTrack;
}
