import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setSpeechRate(0.45);
  }

  Future<void> speak(String text, [String lang = 'hi-IN']) async {
    try {
      await _tts.setLanguage(lang);
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

final ttsService = TtsService();
