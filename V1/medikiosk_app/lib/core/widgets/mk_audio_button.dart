import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import '../services/tts_service.dart';

class MkAudioButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? textToRead;
  final bool isPlaying;

  const MkAudioButton({
    super.key,
    this.onPressed,
    this.textToRead,
    this.isPlaying = false,
  });

  @override
  State<MkAudioButton> createState() => _MkAudioButtonState();
}

class _MkAudioButtonState extends State<MkAudioButton> {
  bool _speaking = false;

  void _handleTap() async {
    if (widget.onPressed != null) {
      widget.onPressed!();
      return;
    }
    if (widget.textToRead != null && widget.textToRead!.isNotEmpty) {
      if (_speaking) {
        await ttsService.stop();
        if (mounted) setState(() => _speaking = false);
      } else {
        setState(() => _speaking = true);
        await ttsService.speak(widget.textToRead!);
        if (mounted) setState(() => _speaking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kiosk = isKiosk(context);
    final active = widget.isPlaying || _speaking;
    final iconSize = kiosk ? 36.0 : 28.0;

    return IconButton(
      icon: Icon(
        active ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
        color: active ? C.danger : C.accentStrong,
      ),
      iconSize: iconSize,
      tooltip: active ? 'Stop audio / रोकें' : 'Listen audio / सुनें',
      onPressed: _handleTap,
    );
  }
}
