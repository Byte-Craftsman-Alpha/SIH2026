import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../constants/app_constants.dart';

class SttService {
  final SpeechToText _stt = SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final Dio _dio = Dio();
  
  String? _recordedFilePath;

  Future<bool> initialize() async {
    final sttInit = await _stt.initialize();
    final hasMic = await _audioRecorder.hasPermission();
    return sttInit && hasMic;
  }

  Future<void> startListening(String locale, Function(String, String) onResult) async {
    final connectivity = await Connectivity().checkConnectivity();
    bool isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      // Online flow: Record audio and send to Bhashini via backend
      final dir = await getTemporaryDirectory();
      _recordedFilePath = '${dir.path}/voice_record.wav';
      
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: _recordedFilePath!,
      );
    } else {
      // Offline flow: Use device STT
      _stt.listen(
        onResult: (result) => onResult(result.recognizedWords, "device"),
        listenOptions: SpeechListenOptions(localeId: locale),
      );
    }
  }

  Future<void> stopListening(String sessionId, Function(String, String) onResult) async {
    if (await _audioRecorder.isRecording()) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        try {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(path, filename: 'voice.wav')
          });
          
          final response = await _dio.post(
            '${AppConstants.defaultVercelUrl}/api/v1/chat/sessions/$sessionId/voice',
            data: formData,
          );
          
          if (response.statusCode == 200 && response.data['transcript'] != null) {
            onResult(response.data['transcript'], response.data['engine']);
          } else {
            onResult("Error transcribing audio", "fallback");
          }
        } catch (e) {
          onResult("Error transcribing audio", "fallback");
        }
      }
    } else {
      _stt.stop();
    }
  }
}
