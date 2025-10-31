import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Connection timeout. Please check your internet connection.';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'Authentication failed. Please login again.';
          } else if (statusCode == 404) {
            return 'Resource not found.';
          } else if (statusCode == 500) {
            return 'Server error. Please try again later.';
          } else {
            // Attempt to read the specific error message from the backend JSON body
            final errorData = error.response?.data;
            if (errorData is Map && errorData.containsKey('error')) {
              return errorData['error']['message'] ?? 'An API error occurred.';
            }
            return 'An unknown API error occurred.';
          }
        case DioExceptionType.cancel:
          return 'Request was cancelled.';
        default:
          return 'Network error. Please check your connection.';
      }
    }
    return error.toString();
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
