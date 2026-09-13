import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkTimelineItem extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final VoidCallback? onTap;

  const MkTimelineItem({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textHeading = isDark ? C.textHeadingDark : C.textHeading;
    final textMuted = isDark ? C.textMutedDark : C.textMuted;
    final avatarBg = isDark ? C.primaryContainerDark : C.primaryContainer;
    final iconColor = isDark ? C.white : C.primaryDeep;

    return InkWell(
      onTap: onTap,
      borderRadius: R.lg,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: kiosk ? S.s5 : S.s4,
          vertical: kiosk ? S.s4 : S.s3,
        ),
        child: Row(
          children: [
            Container(
              width: kiosk ? 52 : 42,
              height: kiosk ? 52 : 42,
              decoration: BoxDecoration(
                color: avatarBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: kiosk ? 26 : 20),
            ),
            SizedBox(width: kiosk ? S.s5 : S.s4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: kiosk ? T.titleL(color: textHeading) : T.titleM(color: textHeading),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: kiosk ? T.bodyM(color: textMuted) : T.labelM(color: textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textMuted, size: kiosk ? 28 : 22),
          ],
        ),
      ),
    );
  }
}
