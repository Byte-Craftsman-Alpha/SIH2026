import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkBottomSheet extends StatelessWidget {
  final Widget child;

  const MkBottomSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? C.surfaceDark : C.white;
    final handleColor = isDark ? C.borderStrongDark : C.borderSubtle;

    return Container(
      padding: EdgeInsets.all(kiosk ? S.s8 : S.s6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(kiosk ? R.rXl3 : R.rXl2)),
        boxShadow: isDark ? E.e0 : E.e4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: kiosk ? 60 : 48,
            height: 5,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: R.pill,
            ),
          ),
          SizedBox(height: kiosk ? S.s6 : S.s5),
          child,
        ],
      ),
    );
  }
}
