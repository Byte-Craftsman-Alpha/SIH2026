import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const MkOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final borderColor = isSelected
        ? (isDark ? C.primaryDarkTheme : C.primary)
        : (isDark ? C.borderSubtleDark : C.borderSubtle);

    final bgColor = isSelected
        ? (isDark ? C.primaryContainerDark.withValues(alpha: 0.3) : C.primarySurface)
        : (isDark ? C.surfaceDark : C.white);

    final iconColor = isSelected
        ? (isDark ? C.primaryDarkTheme : C.primary)
        : (isDark ? C.textMutedDark : C.textMuted);

    final textColor = isDark ? C.textHeadingDark : C.textHeading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: kiosk ? R.xl2 : R.xl,
        child: AnimatedContainer(
          duration: D.base,
          curve: M.easeStandard,
          padding: EdgeInsets.all(kiosk ? S.s6 : S.s5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: kiosk ? R.xl2 : R.xl,
            border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
            boxShadow: isDark ? E.e0 : (isSelected ? E.e2 : E.e1),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: kiosk ? 30 : 24),
              SizedBox(width: kiosk ? S.s5 : S.s4),
              Expanded(
                child: Text(
                  title,
                  style: kiosk
                      ? (isSelected ? T.headlineM(color: textColor) : T.titleL(color: textColor))
                      : (isSelected ? T.titleM(color: textColor) : T.bodyL(color: textColor)),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: isDark ? C.primaryDarkTheme : C.primary,
                  size: kiosk ? 26 : 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
