import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService extends ChangeNotifier {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  
  factory FirebaseAuthService() {
    return _instance;
  }
  
  FirebaseAuthService._internal() {
    _initializeAuth();
  }
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get currentUser {
    if (_currentUser != null) {
      debugPrint("FirebaseAuthService: Returning _currentUser (verified=${_currentUser?.emailVerified})");
      return _currentUser;
    } else {
      debugPrint("FirebaseAuthService: Returning _auth.currentUser (verified=${_auth.currentUser?.emailVerified})");
      return _auth.currentUser;
    }
  }
  bool get isLoading => _isLoading;
  bool get isAuthenticated => currentUser != null;
  bool get isSignedIn => currentUser != null;
  bool get isInitialized => _isInitialized;

  Future<void> _initializeAuth() async {
    try {
      // Listen for auth state changes
      _auth.authStateChanges().listen((User? user) {
        _currentUser = user;
        debugPrint('Auth state changed: ${user?.email ?? 'null'}');
        notifyListeners();
      });
      
      _currentUser = _auth.currentUser;
      _isInitialized = true;
      notifyListeners();
      
      if (_currentUser != null) {
        debugPrint('Restored user session: ${_currentUser!.email}');
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Auth: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _currentUser = credential.user;
      debugPrint('Sign in successful: ${_currentUser?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    return signUpWithEmailAndPassword(
      email: email,
      password: password,
      firstName: name?.split(' ').first ?? '',
      lastName: name?.split(' ').skip(1).join(' ') ?? '',
    );
  }

  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      final displayName = '$firstName $lastName'.trim();
      if (displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      
      // Note: Email verification will be sent from the signup screen
      
      _currentUser = credential.user;
      debugPrint('Sign up successful: ${_currentUser?.email}');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      rethrow; // Let the signup screen handle the specific error
    } catch (e) {
      debugPrint('Error signing up: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _auth.signOut();
      _currentUser = null;
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('Password reset email sent to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyEmail(String code) async {
    // Firebase handles email verification automatically
    // This method is kept for compatibility
    debugPrint('Email verification handled automatically by Firebase');
  }

  Future<void> refreshUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        _currentUser = _auth.currentUser;
        debugPrint('User refreshed: ${_currentUser?.email}, verified: ${_currentUser?.emailVerified}');
        debugPrint('FirebaseAuthService: Notifying listeners after user refresh');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing user: $e');
    }
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        debugPrint('No user to delete');
        return false;
      }

      await _currentUser!.delete();
      _currentUser = null;
      
      debugPrint('User account deleted successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}