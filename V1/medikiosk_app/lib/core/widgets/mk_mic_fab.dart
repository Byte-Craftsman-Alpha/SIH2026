import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkMicFab extends StatelessWidget {
  final bool isListening;
  final VoidCallback onPressed;

  const MkMicFab({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fabSize = kiosk ? 76.0 : 60.0;
    final double iconSize = kiosk ? 36.0 : 28.0;

    final bgColor = isListening
        ? (isDark ? C.dangerDarkTheme : C.danger)
        : (isDark ? C.primaryDarkTheme : C.primary);

    return Container(
      width: fabSize,
      height: fabSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isListening ? E.e4 : E.e2,
      ),
      child: Material(
        color: bgColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: C.white,
              size: iconSize,
            ),
          ),
        ),
      ),
    );
  }
}
