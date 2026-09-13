import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/tokens.dart';

enum MkButtonVariant { primary, secondary, outline, accent, emergency }

class MkButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final MkButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  const MkButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = MkButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kiosk = isKiosk(context);
    final double buttonHeight = kiosk ? 72.0 : 56.0;
    final BorderRadius borderRadius = kiosk ? R.xl : R.lg;
    final TextStyle textStyle = kiosk
        ? T.titleL(color: _getFgColor(isDark))
        : T.labelL(color: _getFgColor(isDark));
    final double iconSize = kiosk ? 26.0 : 20.0;

    final bgColor = _getBgColor(isDark);
    final fgColor = _getFgColor(isDark);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: 0,
        minimumSize: Size(64, buttonHeight),
        padding: EdgeInsets.symmetric(horizontal: kiosk ? S.s8 : S.s6),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: variant == MkButtonVariant.outline
              ? BorderSide(color: isDark ? C.borderSubtleDark : C.borderSubtle, width: kiosk ? 2.0 : 1.5)
              : BorderSide.none,
        ),
      ),
      onPressed: (isLoading || onPressed == null)
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: isLoading
          ? SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(color: fgColor, strokeWidth: 2.5),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: iconSize, color: fgColor),
                  SizedBox(width: kiosk ? S.s4 : S.s2),
                ],
                Flexible(
                  child: Text(
                    text,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }

  Color _getBgColor(bool isDark) {
    switch (variant) {
      case MkButtonVariant.primary:
        return isDark ? C.primaryDarkTheme : C.primary;
      case MkButtonVariant.secondary:
        return isDark ? C.primaryContainerDark : C.primaryContainer;
      case MkButtonVariant.outline:
        return Colors.transparent;
      case MkButtonVariant.accent:
        return isDark ? C.accentDarkTheme : C.accentStrong;
      case MkButtonVariant.emergency:
        return isDark ? C.dangerDarkTheme : C.danger;
    }
  }

  Color _getFgColor(bool isDark) {
    switch (variant) {
      case MkButtonVariant.primary:
        return C.white;
      case MkButtonVariant.secondary:
        return isDark ? C.white : C.primaryDeep;
      case MkButtonVariant.outline:
        return isDark ? C.textBodyDark : C.textBody;
      case MkButtonVariant.accent:
        return C.white;
      case MkButtonVariant.emergency:
        return C.white;
    }
  }
}
