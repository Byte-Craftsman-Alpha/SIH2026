import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;

  const MkChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kiosk = isKiosk(context);
    final double chipHeight = kiosk ? 52.0 : 40.0;
    final double iconSize = kiosk ? 22.0 : 18.0;

    final borderColor = isSelected
        ? (isDark ? C.primaryDarkTheme : C.primary)
        : (isDark ? C.borderSubtleDark : C.borderSubtle);

    final bgColor = isSelected
        ? (isDark ? C.primaryContainerDark : C.primaryContainer)
        : (isDark ? C.surfaceDark : C.white);

    final textColor = isSelected
        ? (isDark ? C.white : C.primaryDeep)
        : (isDark ? C.textBodyDark : C.textBody);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: R.pill,
        child: AnimatedContainer(
          duration: D.base,
          curve: M.easeStandard,
          height: chipHeight,
          padding: EdgeInsets.symmetric(horizontal: kiosk ? S.s5 : S.s4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: R.pill,
            border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: textColor),
                SizedBox(width: kiosk ? S.s3 : S.s2),
              ],
              Text(
                label,
                style: kiosk
                    ? T.titleM(color: textColor)
                    : T.labelL(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
