import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkStepIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const MkStepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? C.primaryDarkTheme : C.primary;
    final inactiveColor = isDark ? C.surfaceHighDark : C.surfaceHigh;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isSelected = index == currentStep;
        final isDone = index < currentStep;

        final color = (isSelected || isDone) ? activeColor : inactiveColor;
        final double width = isSelected ? (kiosk ? 36.0 : 28.0) : (kiosk ? 12.0 : 8.0);
        final double height = kiosk ? 10.0 : 6.0;

        return AnimatedContainer(
          duration: D.base,
          curve: M.easeStandard,
          margin: const EdgeInsets.symmetric(horizontal: S.s1),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: R.pill,
          ),
        );
      }),
    );
  }
}
