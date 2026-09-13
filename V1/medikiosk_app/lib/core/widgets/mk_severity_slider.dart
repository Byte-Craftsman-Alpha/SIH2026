import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkSeveritySlider extends StatefulWidget {
  final double? value;
  final double initialValue;
  final ValueChanged<double>? onChanged;

  const MkSeveritySlider({
    super.key,
    this.value,
    this.initialValue = 5.0,
    this.onChanged,
  });

  @override
  State<MkSeveritySlider> createState() => _MkSeveritySliderState();
}

class _MkSeveritySliderState extends State<MkSeveritySlider> {
  late double _currentVal;

  @override
  void initState() {
    super.initState();
    _currentVal = widget.value ?? widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant MkSeveritySlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != null) {
      _currentVal = widget.value!;
    }
  }

  Color _getSliderColor(double val) {
    if (val <= 3) return C.success;
    if (val <= 6) return C.accent;
    return C.danger;
  }

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = _getSliderColor(_currentVal);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'तीव्रता / Severity: ',
              style: kiosk ? T.titleM() : T.labelL(),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: S.s3, vertical: S.s1),
              decoration: BoxDecoration(
                color: activeColor.withValues(alpha: 0.15),
                borderRadius: R.pill,
                border: Border.all(color: activeColor, width: 1.5),
              ),
              child: Text(
                _currentVal.round().toString(),
                style: T.numL(color: activeColor),
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: isDark ? C.surfaceHighDark : C.chartTrack,
            thumbColor: activeColor,
            trackHeight: kiosk ? 10.0 : 6.0,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: kiosk ? 16.0 : 12.0,
            ),
          ),
          child: Slider(
            value: _currentVal,
            min: 0,
            max: 10,
            divisions: 10,
            label: _currentVal.round().toString(),
            onChanged: (val) {
              setState(() => _currentVal = val);
              widget.onChanged?.call(val);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: S.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('😊 0 (हल्का / Mild)', style: T.labelM(color: C.success)),
              Text('😐 5 (मध्यम / Moderate)', style: T.labelM(color: C.accent)),
              Text('😫 10 (असहनीय / Severe)', style: T.labelM(color: C.danger)),
            ],
          ),
        ),
      ],
    );
  }
}
