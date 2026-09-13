import 'package:speech_to_text/speech_to_text.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  
  Future<bool> initialize() async {
    return await _stt.initialize();
  }

  void startListening(String locale, Function(String) onResult) {
    _stt.listen(
      onResult: (result) => onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(localeId: locale),
    );
  }

  void stopListening() {
    _stt.stop();
  }
}
