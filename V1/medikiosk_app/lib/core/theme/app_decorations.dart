import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class AppDecorations {
  static BoxDecoration softCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? C.surfaceDark : C.white,
      borderRadius: R.xl,
      border: Border.all(
        color: isDark ? C.borderSubtleDark : C.borderSubtle,
        width: 1,
      ),
      boxShadow: isDark ? E.e0 : E.e1,
    );
  }

  static BoxDecoration emergencyCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? C.dangerContainerDark.withValues(alpha: 0.3) : C.dangerContainer,
      borderRadius: R.xl,
      border: Border.all(color: C.danger, width: 1.5),
      boxShadow: isDark ? E.e0 : E.e1,
    );
  }

  static BoxDecoration accentCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? C.accentContainerDark.withValues(alpha: 0.3) : C.accentContainer,
      borderRadius: R.xl,
      border: Border.all(color: C.accentStrong, width: 1.5),
      boxShadow: isDark ? E.e0 : E.e1,
    );
  }
}
