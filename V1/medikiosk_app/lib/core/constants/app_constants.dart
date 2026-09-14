enum AppEnvironment {
  beta,
  normal,
}

abstract class AppConstants {
  // Compile-time environment configuration (--dart-define=APP_ENV=beta|normal)
  static const String _envString = String.fromEnvironment('APP_ENV', defaultValue: 'beta');

  static AppEnvironment get defaultEnvironment =>
      _envString.toLowerCase() == 'normal' ? AppEnvironment.normal : AppEnvironment.beta;

  // Local Beta Backend (uses local SQLite database)
  static const String betaBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const String betaEmulatorUrl = 'http://10.0.2.2:8000/api/v1';

  // Deployed Normal Backend (Vercel Serverless + Supabase cloud storage & database)
  static const String defaultVercelUrl = 'http://10.139.158.195:8000/api/v1';

  // Active default URL
  static String get apiBaseUrl =>
      defaultEnvironment == AppEnvironment.normal ? defaultVercelUrl : betaBaseUrl;

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration kioskIdleTimeout = Duration(seconds: 60);

  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String langKey = 'app_language';
  static const String themeKey = 'app_theme_mode';
  static const String kioskModeKey = 'kiosk_mode_enabled';
  static const String serverEnvKey = 'app_server_environment';
  static const String customVercelUrlKey = 'app_custom_vercel_url';
}
