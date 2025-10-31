import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_models;
import 'api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final ApiService _apiService = ApiService();
  bool _googleSignInInitialized = false;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current Firebase user
  User? get currentUser => _auth.currentUser;

  // --- Firebase Operations ---

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (!_googleSignInInitialized) {
        await _googleSignIn.initialize();
        _googleSignInInitialized = true;
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      // Handle cancellation or other errors
      if (e is GoogleSignInException &&
          e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User cancelled
      }
      rethrow;
    }
  }

  // --- Backend Operations ---

  Future<app_models.User> getUserProfile() async {
    try {
      // Calls the /v1/auth/me endpoint
      final response = await _apiService.dio.get('/auth/me');
      return app_models.User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<app_models.User> updateProfile({
    String? displayName,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      // Calls the /v1/auth/me PUT endpoint
      final response = await _apiService.dio.put(
        '/auth/me',
        data: {
          if (displayName != null) 'display_name': displayName,
          if (preferences != null) 'preferences': preferences,
        },
      );
      return app_models.User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // --- Sign Out ---

  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
  }
}
