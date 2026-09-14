import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/stt_service.dart';

class VoiceOverlay extends StatefulWidget {
  final Function(String, String) onTranscriptConfirmed;
  final String sessionId;

  const VoiceOverlay({super.key, required this.onTranscriptConfirmed, required this.sessionId});

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final SttService _sttService = SttService();
  
  String _transcript = "Listening...";
  String _engine = "fallback";
  bool _isListening = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _startRecording();
  }
  
  Future<void> _startRecording() async {
    final init = await _sttService.initialize();
    if (init) {
      setState(() => _isListening = true);
      await _sttService.startListening('hi-IN', (text, engine) {
        setState(() {
          if (text.isNotEmpty) _transcript = text;
          _engine = engine;
        });
      });
    } else {
      setState(() => _transcript = "Microphone permission denied.");
    }
  }

  Future<void> _stopAndProcess() async {
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _transcript = "Processing audio with Bhashini...";
    });
    
    await _sttService.stopListening(widget.sessionId, (text, engine) {
      setState(() {
        _isProcessing = false;
        _transcript = text;
        _engine = engine;
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Listening Pulse Animation
          AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              return Container(
                width: 72 + (_isListening ? (_animController.value * 16) : 0),
                height: 72 + (_isListening ? (_animController.value * 16) : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ayushLight.withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? AppColors.ayushLight : Colors.grey,
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 30),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          Text(
            _isProcessing ? 'प्रोसेस कर रहे हैं... (Processing...)' : (_isListening ? 'सुन रहे हैं... (Listening...)' : 'आवाज़ रिकॉर्ड हुई (Captured)'),
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'अपनी समस्या सामान्य हिंदी या अंग्रेज़ी में बोलें',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariantLight),
          ),
          const SizedBox(height: 20),

          // Live Transcript Bubble
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                Text(
                  _transcript,
                  style: AppTextStyles.bodyLarge.copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
                if (!_isListening && !_isProcessing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _engine == "bhashini" ? "Bhashini (Govt ASR)" : "Device STT (Offline/Fallback)",
                      style: const TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _sttService.stopListening(widget.sessionId, (a, b) {});
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('रद्द करें (Cancel)'),
                ),
              ),
              const SizedBox(width: 12),
              if (_isListening)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopAndProcess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('पूरा हुआ (Done)'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () {
                      Navigator.pop(context);
                      widget.onTranscriptConfirmed(_transcript, _engine);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.ayushLight,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('सही है, भेजें ✓'),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
