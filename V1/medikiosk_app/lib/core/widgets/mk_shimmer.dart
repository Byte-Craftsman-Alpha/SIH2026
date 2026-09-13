import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../design/tokens.dart';

class MkShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const MkShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? C.surfaceDark : C.surfaceHigh;
    final highlightColor = isDark ? C.surfaceHighDark : C.canvas;
    final radius = borderRadius ?? R.rSm;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
