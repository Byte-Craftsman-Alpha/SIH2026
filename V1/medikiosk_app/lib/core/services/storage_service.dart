import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize StorageService before using this provider');
});

class StorageService {
  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clear() => _prefs.clear();

  // Environment and Server URL Helpers
  AppEnvironment getEnvironment() {
    final saved = getString(AppConstants.serverEnvKey);
    if (saved == 'normal') return AppEnvironment.normal;
    if (saved == 'beta') return AppEnvironment.beta;
    return AppConstants.defaultEnvironment;
  }

  Future<bool> setEnvironment(AppEnvironment env) {
    return setString(AppConstants.serverEnvKey, env == AppEnvironment.normal ? 'normal' : 'beta');
  }

  String getVercelUrl() {
    return getString(AppConstants.customVercelUrlKey) ?? AppConstants.defaultVercelUrl;
  }

  Future<bool> setVercelUrl(String url) {
    return setString(AppConstants.customVercelUrlKey, url.trim());
  }

  String getActiveApiUrl() {
    final env = getEnvironment();
    if (env == AppEnvironment.normal) {
      return getVercelUrl();
    }
    return AppConstants.betaBaseUrl;
  }
}
