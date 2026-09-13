import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../design/tokens.dart';

class MkDonutChart extends StatelessWidget {
  final double vata;
  final double pitta;
  final double kapha;
  final bool showLegend;

  const MkDonutChart({
    super.key,
    required this.vata,
    required this.pitta,
    required this.kapha,
    this.showLegend = true,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double total = (vata + pitta + kapha) == 0 ? 1 : (vata + pitta + kapha);
    final int vataPct = ((vata / total) * 100).round();
    final int pittaPct = ((pitta / total) * 100).round();
    final int kaphaPct = ((kapha / total) * 100).round();

    final chartSize = kiosk ? 260.0 : 200.0;
    final centerRadius = kiosk ? 58.0 : 44.0;
    final sectionRadius = kiosk ? 42.0 : 32.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: chartSize,
          width: chartSize,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: centerRadius,
              centerSpaceColor: isDark ? C.surfaceDark : C.white,
              sections: [
                PieChartSectionData(
                  value: vata <= 0 ? 0.1 : vata,
                  color: C.vata,
                  title: '$vataPct%',
                  radius: sectionRadius,
                  titleStyle: T.numM(color: C.white),
                ),
                PieChartSectionData(
                  value: pitta <= 0 ? 0.1 : pitta,
                  color: C.pitta,
                  title: '$pittaPct%',
                  radius: sectionRadius,
                  titleStyle: T.numM(color: C.white),
                ),
                PieChartSectionData(
                  value: kapha <= 0 ? 0.1 : kapha,
                  color: C.kapha,
                  title: '$kaphaPct%',
                  radius: sectionRadius,
                  titleStyle: T.numM(color: C.white),
                ),
              ],
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: S.s4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: S.s2,
            runSpacing: S.s2,
            children: [
              _buildLegendBadge('Vata', C.vata, '$vataPct%', isDark),
              _buildLegendBadge('Pitta', C.pitta, '$pittaPct%', isDark),
              _buildLegendBadge('Kapha', C.kapha, '$kaphaPct%', isDark),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildLegendBadge(String label, Color color, String pct, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: S.s3, vertical: S.s1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: R.pill,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: S.s1),
          Text(label, style: T.labelM(color: isDark ? C.textHeadingDark : C.textHeading)),
          const SizedBox(width: S.s1),
          Text(pct, style: T.numM(color: color)),
        ],
      ),
    );
  }
}
