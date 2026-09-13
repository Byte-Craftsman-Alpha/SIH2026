import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class MkTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  const MkTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textHeading = isDark ? C.textHeadingDark : C.textHeading;
    final textBody = isDark ? C.textBodyDark : C.textBody;
    final textMuted = isDark ? C.textMutedDark : C.textMuted;
    final fillColor = isDark ? C.surfaceDark : C.white;
    final borderColor = isDark ? C.borderSubtleDark : C.borderSubtle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: kiosk ? T.titleM(color: textHeading) : T.labelL(color: textHeading),
        ),
        const SizedBox(height: S.s2),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          maxLines: maxLines,
          style: kiosk ? T.headlineM(color: textBody) : T.bodyL(color: textBody),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: kiosk ? T.bodyL(color: textMuted) : T.bodyM(color: textMuted),
            errorText: errorText,
            errorStyle: T.labelM(color: C.danger),
            filled: true,
            fillColor: fillColor,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: C.primary, size: kiosk ? 28 : 22)
                : null,
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(
              horizontal: kiosk ? S.s6 : S.s4,
              vertical: kiosk ? S.s5 : S.s4,
            ),
            border: OutlineInputBorder(
              borderRadius: R.md,
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: R.md,
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: R.md,
              borderSide: const BorderSide(color: C.primary, width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: R.md,
              borderSide: const BorderSide(color: C.danger, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
