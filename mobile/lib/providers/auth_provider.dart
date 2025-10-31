import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_models;

// Firebase auth state stream: listens for changes (login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  // Uses the stream defined in AuthService
  return AuthService().authStateChanges;
});

// User profile provider: fetches the full user object from the backend
final userProfileProvider = FutureProvider<app_models.User?>((ref) async {
  // Depends on the authStateProvider
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      try {
        // Fetch detailed profile using the authenticated API service
        return await AuthService().getUserProfile();
      } catch (e) {
        // If profile fetch fails (e.g., first login, network error), return null
        return null;
      }
    },
    loading: () => null, // Return null while Firebase is checking state
    error: (_, __) => null, // Return null on error
  );
});

// Auth service provider (for accessing methods like signIn, signOut)
final authServiceProvider = Provider((ref) => AuthService());
