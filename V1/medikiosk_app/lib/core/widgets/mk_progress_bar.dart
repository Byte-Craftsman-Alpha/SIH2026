import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkProgressBar extends StatelessWidget {
  final double progress;
  final String? label;

  const MkProgressBar({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kiosk = isKiosk(context);
    final double barHeight = kiosk ? 10.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: kiosk
                ? T.titleM(color: isDark ? C.textHeadingDark : C.textHeading)
                : T.labelL(color: isDark ? C.textHeadingDark : C.textHeading),
          ),
          const SizedBox(height: S.s2),
        ],
        ClipRRect(
          borderRadius: R.pill,
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: isDark ? C.surfaceHighDark : C.chartTrack,
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? C.primaryDarkTheme : C.primary,
            ),
            minHeight: barHeight,
          ),
        ),
      ],
    );
  }
}
