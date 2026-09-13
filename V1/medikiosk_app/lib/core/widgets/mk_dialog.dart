import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'mk_button.dart';

class MkDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const MkDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onCancel,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? C.surfaceDark : C.white;
    final borderColor = isDark ? C.borderSubtleDark : C.borderSubtle;
    final textHeading = isDark ? C.textHeadingDark : C.textHeading;
    final textBody = isDark ? C.textBodyDark : C.textBody;

    return AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: kiosk ? R.xl3 : R.xl2,
        side: BorderSide(color: borderColor, width: 1),
      ),
      title: Text(
        title,
        style: kiosk ? T.displayM(color: textHeading) : T.headlineM(color: textHeading),
      ),
      content: Text(
        message,
        style: kiosk ? T.titleM(color: textBody) : T.bodyL(color: textBody),
      ),
      actionsPadding: EdgeInsets.all(kiosk ? S.s6 : S.s4),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: isDark ? C.textMutedDark : C.textMuted,
            padding: const EdgeInsets.symmetric(horizontal: S.s4, vertical: S.s3),
          ),
          child: Text(cancelText, style: T.labelL(color: isDark ? C.textMutedDark : C.textMuted)),
        ),
        MkButton(
          text: confirmText,
          variant: isDestructive ? MkButtonVariant.emergency : MkButtonVariant.primary,
          onPressed: onConfirm,
        ),
      ],
    );
  }
}
