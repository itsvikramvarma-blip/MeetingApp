import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: _roleFromString(json['role'] ?? 'user'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
    };
  }
}

enum UserRole { admin, user, guest }

UserRole _roleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return UserRole.admin;
    case 'user':
      return UserRole.user;
    case 'guest':
      return UserRole.guest;
    default:
      return UserRole.user;
  }
}

class AuthServiceRemote extends ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _authToken;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Initialize auth service
  AuthServiceRemote() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Try to restore session from previous login
    // In production, you'd store token in secure storage
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.authLogin),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid email or password';
      } else {
        _errorMessage = 'Login failed: ${response.statusCode}';
      }
    } on TimeoutException catch (_) {
      _errorMessage = 'Connection timeout. Please check your internet.';
    } catch (e) {
      _errorMessage = 'Login error: ${e.toString()}';
      print('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signInWithPhone(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/phone-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': phoneNumber,
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Phone login failed';
      }
    } catch (e) {
      _errorMessage = 'Phone login error: ${e.toString()}';
      print('Phone login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.authRegister),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'name': name,
            }),
          )
          .timeout(const Duration(seconds: ApiConfig.requestTimeout));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _authToken = data['token'];
        _currentUser = User.fromJson(data['user']);
        _isAuthenticated = true;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 409) {
        _errorMessage = 'Email already registered';
      } else {
        _errorMessage = 'Registration failed: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Registration error: ${e.toString()}';
      print('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
    _authToken = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Get authorization header for API requests
  Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }
}

class TimeoutException implements Exception {
  TimeoutException();
}
