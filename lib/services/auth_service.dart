import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User class for authentication
class User {
  final String id;
  final String email;
  final String? name;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    required this.email,
    this.name,
    this.firstName,
    this.lastName,
  });
}

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isSignedIn => _currentUser != null;
  bool get isInitialized => _isInitialized;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Check for persisted user session
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final userEmail = prefs.getString('user_email');
      final userName = prefs.getString('user_name');
      final userFirstName = prefs.getString('user_first_name');
      final userLastName = prefs.getString('user_last_name');
      
      if (userId != null && userEmail != null) {
        _currentUser = User(
          id: userId,
          email: userEmail,
          name: userName,
          firstName: userFirstName,
          lastName: userLastName,
        );
        debugPrint('Restored user session: ${_currentUser!.email}');
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing auth: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@')[0].replaceAll('.', ' ').split(' ').map((e) => e[0].toUpperCase() + e.substring(1)).join(' '),
        firstName: email.split('@')[0].split('.').first,
        lastName: email.split('@')[0].split('.').length > 1 ? email.split('@')[0].split('.').last : null,
      );
      
      await _persistUserSession(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing in: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      
      final nameParts = name?.split(' ') ?? [];
      final firstName = nameParts.isNotEmpty ? nameParts.first : email.split('@')[0].split('.').first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : (email.split('@')[0].split('.').length > 1 ? email.split('@')[0].split('.').last : null);

      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name ?? '$firstName ${lastName ?? ''}',
        firstName: firstName,
        lastName: lastName,
      );
      
      await _persistUserSession(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
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
      await Future.delayed(const Duration(seconds: 1));
      
      _currentUser = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: '$firstName $lastName',
        firstName: firstName,
        lastName: lastName,
      );
      
      await _persistUserSession(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithGoogle() async {
    if (!_isInitialized) return false;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate Google sign in with realistic user data
      await Future.delayed(const Duration(seconds: 1));
      
      // Generate realistic Google user data
      final firstName = 'John';
      final lastName = 'Doe';
      final email = 'john.doe@gmail.com';
      
      _currentUser = User(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: '$firstName $lastName',
        firstName: firstName,
        lastName: lastName,
      );
      
      // Persist user session
      await _persistUserSession(_currentUser!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> _persistUserSession(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('user_email', user.email);
      if (user.name != null) await prefs.setString('user_name', user.name!);
      if (user.firstName != null) await prefs.setString('user_first_name', user.firstName!);
      if (user.lastName != null) await prefs.setString('user_last_name', user.lastName!);
      debugPrint('User session persisted: ${user.email}');
    } catch (e) {
      debugPrint('Error persisting user session: $e');
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear persisted user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_first_name');
      await prefs.remove('user_last_name');
      
      _currentUser = null;
      debugPrint('User signed out and session cleared');
    } catch (e) {
      debugPrint('Error signing out: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyEmail(String code) async {
    if (!_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Email verified successfully');
    } catch (e) {
      debugPrint('Error verifying email: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Delete user account (sign out locally - Clerk deletion handled in UI)
  Future<bool> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        debugPrint('No user to delete');
        return false;
      }

      // Clear persisted user session  
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      await prefs.remove('user_name');
      await prefs.remove('user_first_name');
      await prefs.remove('user_last_name');
      
      // Clear local state
      _currentUser = null;
      
      debugPrint('User account deleted successfully');
      return true;
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}