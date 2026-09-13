import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkOfflineBanner extends StatelessWidget {
  const MkOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: C.danger,
      padding: const EdgeInsets.symmetric(horizontal: S.s4, vertical: S.s2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, color: C.white, size: 18),
          const SizedBox(width: S.s2),
          Text(
            'इंटरनेट कनेक्ट नहीं है / No Internet Connection',
            textAlign: TextAlign.center,
            style: T.labelL(color: C.white),
          ),
        ],
      ),
    );
  }
}
