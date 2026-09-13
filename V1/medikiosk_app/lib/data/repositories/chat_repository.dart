import 'dart:developer' as dev;
import '../../core/services/api_client.dart';

class ChatRepository {
  final ApiClient _apiClient;

  ChatRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>?> createSession({
    String mode = "ayush",
    String? complaint,
    String language = "hi",
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/chat/sessions',
        data: {
          "mode": mode,
          "complaint": complaint,
          "language": language,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      dev.log("Error creating chat session: $e", stackTrace: stack, name: "ChatRepository");
    }
    return null;
  }

  Future<Map<String, dynamic>?> submitAnswer({
    required String sessionId,
    required String questionId,
    required String inputType,
    required dynamic answer,
    String sessionLang = "hi",
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/chat/sessions/$sessionId/answer',
        data: {
          "question_id": questionId,
          "input_type": inputType,
          "answer": answer,
          "session_lang": sessionLang,
        },
      );
      if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
    } catch (e, stack) {
      dev.log("Error submitting answer: $e", stackTrace: stack, name: "ChatRepository");
    }
    return null;
  }
}
