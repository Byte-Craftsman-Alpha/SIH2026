import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConstants.tokenKey, value: accessToken);
    await _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: AppConstants.tokenKey);
  
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
