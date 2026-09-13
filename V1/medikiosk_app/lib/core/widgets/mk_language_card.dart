import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkLanguageCard extends StatelessWidget {
  final String language;
  final String nativeName;
  final VoidCallback onTap;
  final bool isSelected;

  const MkLanguageCard({
    super.key,
    required this.language,
    required this.nativeName,
    required this.onTap,
    this.isSelected = false,
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

    final textColor = isDark ? C.textHeadingDark : C.textHeading;
    final textMuted = isDark ? C.textMutedDark : C.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: kiosk ? R.xl2 : R.xl,
        child: AnimatedContainer(
          duration: D.base,
          curve: M.easeStandard,
          padding: EdgeInsets.symmetric(
            horizontal: kiosk ? S.s6 : S.s5,
            vertical: kiosk ? S.s6 : S.s5,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: kiosk ? R.xl2 : R.xl,
            border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
            boxShadow: isDark ? E.e0 : (isSelected ? E.e2 : E.e1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nativeName,
                    style: kiosk ? T.displayM(color: textColor) : T.titleL(color: textColor),
                  ),
                  const SizedBox(height: S.s1),
                  Text(
                    language,
                    style: kiosk ? T.titleM(color: textMuted) : T.labelL(color: textMuted),
                  ),
                ],
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded,
                color: isSelected ? (isDark ? C.primaryDarkTheme : C.primary) : textMuted,
                size: kiosk ? 28 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
