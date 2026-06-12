import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:silent_link/services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isAuthenticated => _token != null;

  final String baseUrl = 'http://silentlink.runasp.net';

  void setToken(String t) {
    _token = t;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/auth/login'), 
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token']; 
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint("Error in login API: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String currentToken = _token ?? "";

      bool isSuccess = await ApiService().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        token: currentToken,
      );

      _isLoading = false;
      notifyListeners();
      return isSuccess; 
    } catch (e) {
      debugPrint("Error in AuthProvider changePassword: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestForgotPassword({required String email}) async {
    _isLoading = true;
    notifyListeners();

    bool isSuccess = await ApiService().forgotPassword(email: email);

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    bool isSuccess = await ApiService().createPassword(
      email: email,
      resetToken: token,
      newPassword: newPassword,
    );

    _isLoading = false;
    notifyListeners();
    return isSuccess;
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}