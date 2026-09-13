import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/tokens.dart';

class MkEmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const MkEmergencyButton({
    super.key,
    required this.onPressed,
    this.label = 'EMERGENCY / आपातकाल',
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final double buttonHeight = kiosk ? 96.0 : 72.0;
    final BorderRadius borderRadius = kiosk ? R.xl2 : R.xl;
    final double iconSize = kiosk ? 36.0 : 28.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: E.e3,
      ),
      child: Material(
        color: C.danger,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: () {
            HapticFeedback.heavyImpact();
            onPressed();
          },
          borderRadius: borderRadius,
          child: Container(
            height: buttonHeight,
            padding: EdgeInsets.symmetric(horizontal: kiosk ? S.s8 : S.s6),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_amber_rounded, color: C.white, size: iconSize),
                SizedBox(width: kiosk ? S.s4 : S.s3),
                Flexible(
                  child: Text(
                    label,
                    style: kiosk
                        ? T.headlineL(color: C.white)
                        : T.titleL(color: C.white).copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
