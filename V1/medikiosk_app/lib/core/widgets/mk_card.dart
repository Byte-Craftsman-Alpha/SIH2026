import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? border;

  const MkCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kiosk = isKiosk(context);
    final borderRadius = kiosk ? R.xl2 : R.xl;
    final defaultPadding = kiosk ? const EdgeInsets.all(S.s6) : const EdgeInsets.all(S.s5);
    final borderColor = isDark ? C.borderSubtleDark : C.borderSubtle;
    final bgColor = backgroundColor ?? (isDark ? C.surfaceDark : C.white);

    final card = Container(
      padding: padding ?? defaultPadding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: Border.fromBorderSide(border ?? BorderSide(color: borderColor, width: 1)),
        boxShadow: isDark ? E.e0 : E.e1,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: card,
        ),
      );
    }
    return card;
  }
}
