import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

/// Helper function to check if app is running in Kiosk / Tablet mode.
bool isKiosk(BuildContext context) {
  final size = MediaQuery.of(context).size;
  return size.shortestSide >= 600;
}

/// MDS v1.0 Color Tokens (§1)
abstract class C {
  // Primary (Ayurvedic Green)
  static const Color primary = Color(0xFF117351); // green-600
  static const Color primaryDark = Color(0xFF0C5C42); // green-700
  static const Color primaryContainer = Color(0xFFCFEADD); // green-100
  static const Color primarySurface = Color(0xFFE9F5EF); // green-50
  static const Color primaryDeep = Color(0xFF07392A); // green-900

  // Accent (Saffron)
  static const Color accent = Color(0xFFE87A16); // saffron-500
  static const Color accentStrong = Color(0xFFA1500C); // saffron-700
  static const Color accentContainer = Color(0xFFFDE8CE); // saffron-100
  static const Color accentLight = Color(0xFFFFF7ED); // saffron-50

  // Danger (Red Flag Only)
  static const Color danger = Color(0xFFC62828); // red-600
  static const Color dangerDark = Color(0xFF8E1B1B); // red-800
  static const Color dangerContainer = Color(0xFFFFEBEE); // red-50
  static const Color dangerBorder = Color(0xFFEF9A9A); // red-200

  // Semantic Feedback
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color warningContainer = Color(0xFFFEF3C7); // amber-100
  static const Color info = Color(0xFF2563EB); // blue-600
  static const Color infoContainer = Color(0xFFDBEAFE); // blue-100
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color successContainer = Color(0xFFDCFCE7); // green-100

  // Warm Neutrals (Light)
  static const Color canvas = Color(0xFFFAF9F7); // neutral-50
  static const Color surface = Color(0xFFF3F1EC); // neutral-100
  static const Color surfaceHigh = Color(0xFFEAE7E0); // neutral-200
  static const Color borderSubtle = Color(0xFFDCD8CF); // neutral-300
  static const Color borderStrong = Color(0xFFBCB6A8); // neutral-400
  static const Color textMuted = Color(0xFF7A7468); // neutral-600
  static const Color textBody = Color(0xFF4A453C); // neutral-800
  static const Color textHeading = Color(0xFF2B2722); // neutral-900
  static const Color white = Color(0xFFFFFFFF);

  // Dark Theme Warm Neutrals
  static const Color canvasDark = Color(0xFF151413);
  static const Color surfaceDark = Color(0xFF1F1D1B);
  static const Color surfaceHighDark = Color(0xFF2A2825);
  static const Color borderSubtleDark = Color(0xFF3A3733);
  static const Color borderStrongDark = Color(0xFF5A5650);
  static const Color textMutedDark = Color(0xFFA09B91);
  static const Color textBodyDark = Color(0xFFE0DDD7);
  static const Color textHeadingDark = Color(0xFFFAF9F7);

  static const Color primaryDarkTheme = Color(0xFF42A682);
  static const Color primaryContainerDark = Color(0xFF0C5C42);
  static const Color accentDarkTheme = Color(0xFFF59E3F);
  static const Color accentContainerDark = Color(0xFFA1500C);
  static const Color dangerDarkTheme = Color(0xFFE55353);
  static const Color dangerContainerDark = Color(0xFF8E1B1B);

  // AYUSH / Prakriti
  static const Color vata = Color(0xFF4E9BD4);
  static const Color vataContainer = Color(0xFFE5F1F9);
  static const Color pitta = Color(0xFFE0704E);
  static const Color pittaContainer = Color(0xFFFBECE6);
  static const Color kapha = Color(0xFF56A876);
  static const Color kaphaContainer = Color(0xFFE8F5EE);
  static const Color chartTrack = Color(0xFFEFEDE7);
}

/// MDS v1.0 Spacing Tokens (§2)
abstract class S {
  static const double s0 = 0;
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s7 = 28;
  static const double s8 = 32;
  static const double s9 = 40;
  static const double s10 = 48;
  static const double s11 = 56;
  static const double s12 = 64;

  static double margin(BuildContext context) => isKiosk(context) ? s8 : s4;
  static double gutter(BuildContext context) => isKiosk(context) ? s6 : s4;
}

/// MDS v1.0 Radius Tokens (§3)
abstract class R {
  static const double rXs = 4;
  static const double rSm = 8;
  static const double rMd = 12;
  static const double rLg = 16;
  static const double rXl = 20;
  static const double rXl2 = 24;
  static const double rXl3 = 28;
  static const double rPill = 999;

  static final BorderRadius xs = BorderRadius.circular(rXs);
  static final BorderRadius sm = BorderRadius.circular(rSm);
  static final BorderRadius md = BorderRadius.circular(rMd);
  static final BorderRadius lg = BorderRadius.circular(rLg);
  static final BorderRadius xl = BorderRadius.circular(rXl);
  static final BorderRadius xl2 = BorderRadius.circular(rXl2);
  static final BorderRadius xl3 = BorderRadius.circular(rXl3);
  static final BorderRadius pill = BorderRadius.circular(rPill);
}

/// MDS v1.0 Elevation Tokens (§5) - Warm Double Shadows
abstract class E {
  static const List<BoxShadow> e0 = [];

  static const List<BoxShadow> e1 = [
    BoxShadow(color: Color(0x0F2B2722), blurRadius: 4, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x0A2B2722), blurRadius: 1, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> e2 = [
    BoxShadow(color: Color(0x142B2722), blurRadius: 8, offset: Offset(0, 3)),
    BoxShadow(color: Color(0x0A2B2722), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> e3 = [
    BoxShadow(color: Color(0x192B2722), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0F2B2722), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> e4 = [
    BoxShadow(color: Color(0x1F2B2722), blurRadius: 24, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0F2B2722), blurRadius: 8, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> e5 = [
    BoxShadow(color: Color(0x262B2722), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x142B2722), blurRadius: 12, offset: Offset(0, 6)),
  ];
}

/// MDS v1.0 Typography Tokens (§4) - Mukta Vaani + JetBrains Mono
abstract class T {
  static TextStyle get _font => GoogleFonts.muktaVaani();
  static TextStyle get _mono => GoogleFonts.jetBrainsMono();

  static TextStyle displayL({Color? color}) => _font.copyWith(fontSize: 34, fontWeight: FontWeight.w700, color: color, height: 1.2);
  static TextStyle displayM({Color? color}) => _font.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: color, height: 1.25);
  static TextStyle headlineL({Color? color}) => _font.copyWith(fontSize: 24, fontWeight: FontWeight.w700, color: color, height: 1.3);
  static TextStyle headlineM({Color? color}) => _font.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: color, height: 1.35);
  static TextStyle titleL({Color? color}) => _font.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: color, height: 1.4);
  static TextStyle titleM({Color? color}) => _font.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: color, height: 1.4);
  static TextStyle bodyL({Color? color}) => _font.copyWith(fontSize: 16, fontWeight: FontWeight.w400, color: color, height: 1.5);
  static TextStyle bodyM({Color? color}) => _font.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: color, height: 1.45);
  static TextStyle labelL({Color? color}) => _font.copyWith(fontSize: 14, fontWeight: FontWeight.w600, color: color, height: 1.2);
  static TextStyle labelM({Color? color}) => _font.copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: color, height: 1.2);
  static TextStyle caption({Color? color}) => _font.copyWith(fontSize: 11, fontWeight: FontWeight.w400, color: color, height: 1.2);

  // Tabular / Number styles
  static TextStyle numDisplay({Color? color}) => _mono.copyWith(fontSize: 32, fontWeight: FontWeight.w700, color: color);
  static TextStyle numL({Color? color}) => _mono.copyWith(fontSize: 20, fontWeight: FontWeight.w600, color: color);
  static TextStyle numM({Color? color}) => _mono.copyWith(fontSize: 16, fontWeight: FontWeight.w500, color: color);
}

/// MDS v1.0 Motion Duration Tokens (§6) - Hard cap 300ms
abstract class D {
  static const Duration instant = Duration.zero;
  static const Duration quick = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 250);
  static const Duration relaxed = Duration(milliseconds: 300);
}

/// MDS v1.0 Motion Curves (§6)
abstract class M {
  static const Curve easeStandard = Cubic(0.2, 0.0, 0, 1.0);
  static const Curve easeEnter = Curves.decelerate;
  static const Curve easeExit = Curves.easeIn;
}

/// MDS v1.0 Theme Builder (§15)
ThemeData buildMediKioskTheme({bool isDark = false}) {
  final textPrimary = isDark ? C.textHeadingDark : C.textHeading;
  final textBody = isDark ? C.textBodyDark : C.textBody;
  final textMuted = isDark ? C.textMutedDark : C.textMuted;
  final canvasBg = isDark ? C.canvasDark : C.canvas;
  final surfaceBg = isDark ? C.surfaceDark : C.white;
  final borderCol = isDark ? C.borderSubtleDark : C.borderSubtle;

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: isDark
        ? const ColorScheme.dark(
            primary: C.primaryDarkTheme,
            onPrimary: C.canvasDark,
            primaryContainer: C.primaryContainerDark,
            onPrimaryContainer: C.white,
            secondary: C.accentDarkTheme,
            onSecondary: C.canvasDark,
            secondaryContainer: C.accentContainerDark,
            surface: C.canvasDark,
            onSurface: C.textHeadingDark,
            error: C.dangerDarkTheme,
            onError: C.white,
            outline: C.borderSubtleDark,
          )
        : const ColorScheme.light(
            primary: C.primary,
            onPrimary: C.white,
            primaryContainer: C.primaryContainer,
            onPrimaryContainer: C.primaryDeep,
            secondary: C.accentStrong,
            onSecondary: C.white,
            secondaryContainer: C.accentContainer,
            surface: C.canvas,
            onSurface: C.textHeading,
            error: C.danger,
            onError: C.white,
            outline: C.borderSubtle,
          ),
    scaffoldBackgroundColor: canvasBg,
    textTheme: TextTheme(
      displayLarge: T.displayL(color: textPrimary),
      displayMedium: T.displayM(color: textPrimary),
      headlineLarge: T.headlineL(color: textPrimary),
      headlineMedium: T.headlineM(color: textPrimary),
      titleLarge: T.titleL(color: textPrimary),
      titleMedium: T.titleM(color: textPrimary),
      bodyLarge: T.bodyL(color: textBody),
      bodyMedium: T.bodyM(color: textBody),
      labelLarge: T.labelL(color: textPrimary),
      labelMedium: T.labelM(color: textMuted),
    ),
    cardTheme: CardThemeData(
      color: surfaceBg,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: R.xl,
        side: BorderSide(color: borderCol, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: C.primary,
        foregroundColor: C.white,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: S.s6),
        shape: RoundedRectangleBorder(borderRadius: R.lg),
        textStyle: T.labelL(color: C.white),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        elevation: 0,
        foregroundColor: textBody,
        minimumSize: const Size(64, 56),
        padding: const EdgeInsets.symmetric(horizontal: S.s6),
        side: BorderSide(color: borderCol, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: R.lg),
        textStyle: T.labelL(color: textBody),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceBg,
      border: OutlineInputBorder(
        borderRadius: R.md,
        borderSide: BorderSide(color: borderCol, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: R.md,
        borderSide: BorderSide(color: borderCol, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: R.md,
        borderSide: const BorderSide(color: C.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: R.md,
        borderSide: const BorderSide(color: C.danger, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: S.s4, vertical: S.s4),
      hintStyle: T.bodyM(color: textMuted),
      labelStyle: T.bodyM(color: textBody),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceBg,
      selectedColor: C.primaryContainer,
      disabledColor: isDark ? C.surfaceHighDark : C.surfaceHigh,
      shape: RoundedRectangleBorder(borderRadius: R.pill),
      side: BorderSide(color: borderCol, width: 1),
      labelStyle: T.labelL(color: textBody),
      padding: const EdgeInsets.symmetric(horizontal: S.s3, vertical: S.s2),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: R.xl2,
        side: BorderSide(color: borderCol, width: 1),
      ),
      titleTextStyle: T.headlineM(color: textPrimary),
      contentTextStyle: T.bodyL(color: textBody),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceBg,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? C.surfaceHighDark : C.textHeading,
      contentTextStyle: T.bodyM(color: C.white),
      shape: RoundedRectangleBorder(borderRadius: R.md),
      behavior: SnackBarBehavior.floating,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: canvasBg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: T.titleL(color: textPrimary),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
