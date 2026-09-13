import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final VoidCallback? onAudioTap;

  const MkChatBubble({
    super.key,
    required this.text,
    required this.isUser,
    this.onAudioTap,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final systemBg = isDark ? C.surfaceDark : C.surface;
    final systemBorder = isDark ? C.borderSubtleDark : C.borderSubtle;
    final systemText = isDark ? C.textHeadingDark : C.textHeading;

    final userBg = isDark ? C.primaryDarkTheme : C.primary;
    const userText = C.white;

    final borderRadius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: S.s1),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (kiosk ? 0.7 : 0.82),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: kiosk ? S.s5 : S.s4,
          vertical: kiosk ? S.s4 : S.s3,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBg : systemBg,
          borderRadius: borderRadius,
          border: isUser ? null : Border.all(color: systemBorder, width: 1),
          boxShadow: isDark ? E.e0 : E.e1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                text,
                style: kiosk
                    ? T.headlineM(color: isUser ? userText : systemText)
                    : T.bodyL(color: isUser ? userText : systemText),
              ),
            ),
            if (!isUser && onAudioTap != null) ...[
              const SizedBox(width: S.s2),
              GestureDetector(
                onTap: onAudioTap,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.volume_up_rounded, color: C.primary, size: kiosk ? 24 : 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
