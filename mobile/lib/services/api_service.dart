import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import 'dart:developer' as developer;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

  ApiService._internal() {
    final baseUrl = AppConfig.apiBaseUrl;
    developer.log('Initializing API Service with baseUrl: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    // Use the built-in LogInterceptor for detailed request/response logs
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          developer.log('Dio: $obj');
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Get the current API base URL being used
  String getCurrentBaseUrl() => AppConfig.apiBaseUrl;
}

// Interceptor to automatically add the Authorization header
class _AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    developer.log('API Request: ${options.method} ${options.path}');

    // Add Firebase token to requests if the user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Get the fresh JWT token
        final token = await user.getIdToken();
        options.headers['Authorization'] = 'Bearer $token';
        developer.log('Added Firebase auth token to request');
      } catch (e) {
        developer.log('Error getting Firebase token: $e');
      }
    } else {
      developer.log('No Firebase user logged in');
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log('API Error: ${err.message}');
    developer.log('Error Type: ${err.type}');
    developer.log('Status Code: ${err.response?.statusCode}');
    developer.log('Error Response: ${err.response?.data}');

    // Basic error handling: sign out user if token is expired/unauthorized
    if (err.response?.statusCode == 401) {
      developer.log('Token expired, signing out user');
      FirebaseAuth.instance.signOut();
    }
    handler.next(err);
  }
}
