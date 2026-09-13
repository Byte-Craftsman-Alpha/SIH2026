import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class ApiClient {
  late final Dio _dio;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await AuthService().getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          options.headers['Authorization'] = 'Bearer demo_token';
        }
        options.headers['Content-Type'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  Dio get dio => _dio;

  String get baseUrl => _dio.options.baseUrl;

  void updateBaseUrl(String newUrl) {
    var trimmed = newUrl.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (!trimmed.endsWith('/api/v1') && !trimmed.contains('/api/')) {
      trimmed = '$trimmed/api/v1';
    }
    _dio.options.baseUrl = trimmed;
  }

  void syncWithStorage(StorageService storage) {
    final activeUrl = storage.getActiveApiUrl();
    updateBaseUrl(activeUrl);
  }

  Future<Map<String, dynamic>> testConnection([String? targetUrl]) async {
    final startTime = DateTime.now();
    final testDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    var healthUrl = targetUrl ?? _dio.options.baseUrl;
    if (healthUrl.endsWith('/api/v1')) {
      healthUrl = healthUrl.replaceAll('/api/v1', '/health');
    } else {
      healthUrl = '$healthUrl/health';
    }

    try {
      final response = await testDio.get(healthUrl);
      final latencyMs = DateTime.now().difference(startTime).inMilliseconds;
      return {
        'success': response.statusCode == 200,
        'latency_ms': latencyMs,
        'data': response.data,
      };
    } catch (e) {
      final latencyMs = DateTime.now().difference(startTime).inMilliseconds;
      return {
        'success': false,
        'latency_ms': latencyMs,
        'error': e.toString(),
      };
    }
  }
}
