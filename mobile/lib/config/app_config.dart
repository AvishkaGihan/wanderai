import 'dart:io' show Platform;

class AppConfig {
  static const String appName = 'WanderAI';
  static const String appVersion = '1.0.0';

  // API Configuration
  // Returns platform-specific API base URL
  // - Android emulator: http://10.0.2.2:8000/v1 (maps to host machine)
  // - iOS simulator: http://localhost:8000/v1
  // - Physical devices: Use environment variable or fallback to localhost
  static String get apiBaseUrl {
    final envUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // Default URLs based on platform
    if (Platform.isAndroid) {
      // Android emulator uses 10.0.2.2 to reach the host machine
      return 'http://10.0.2.2:8000/v1';
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost
      return 'http://localhost:8000/v1';
    } else {
      // Web, macOS, Windows, Linux default
      return 'http://localhost:8000/v1';
    }
  }

  // Firebase Configuration
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: '',
  );

  // Cache Configuration (for Hive)
  static const int cacheExpiryDays = 7;
  static const int maxCachedTrips = 5;

  // UI Configuration
  static const int chatHistoryLimit = 50;
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration apiTimeout = Duration(seconds: 30);

  // URLs
  static const String privacyPolicyUrl = 'https://wanderai.com/privacy-policy';
  static const String termsOfServiceUrl =
      'https://wanderai.com/terms-of-service';
}
