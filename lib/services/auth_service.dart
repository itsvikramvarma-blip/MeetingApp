import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    if (email.isNotEmpty && password.length >= 6) {
      _currentUser = User(
        id: '1',
        email: email,
        name: email.split('@').first,
        role: UserRole.user,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    
    if (phoneNumber.isNotEmpty) {
      _currentUser = User(
        id: '1',
        email: '',
        name: 'Phone User',
        role: UserRole.user,
      );
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> authenticateWithBiometrics() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.delayed(const Duration(seconds: 1)); // Simulate biometric scan
    
    // For demo, always fail biometric auth
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.phoneNumber,
    required this.role,
  });
}

enum UserRole {
  user,
  admin,
  moderator,
}
