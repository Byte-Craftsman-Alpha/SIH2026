import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showAudioGuide;
  final VoidCallback? onAudioPressed;

  const MkAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showAudioGuide = true,
    this.onAudioPressed,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? C.textHeadingDark : C.textHeading;

    return AppBar(
      title: Text(
        title,
        style: kiosk ? T.headlineM(color: textColor) : T.titleL(color: textColor),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: isDark ? C.canvasDark : C.canvas,
      foregroundColor: textColor,
      actions: [
        if (showAudioGuide)
          Padding(
            padding: const EdgeInsets.only(right: S.s2),
            child: IconButton(
              icon: Icon(Icons.volume_up_rounded, color: C.primary, size: kiosk ? 30 : 24),
              tooltip: 'Listen / सुनें',
              onPressed: onAudioPressed ?? () {},
            ),
          ),
        ...?actions,
        const SizedBox(width: S.s2),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
