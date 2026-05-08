import 'dart:convert';
import 'package:http/http.dart' as http;

/// ===============================
/// AUTH SERVICES (ALL IN ONE FILE)
/// ===============================
class AuthServices {
  /// 🔥 BASE URL
  static const String baseUrl = "https://YOUR_BASE_URL.com/api";

  /// 🔐 TOKEN STORAGE (simple in-memory for now)
  static String? _token;

  /// ===============================
  /// TOKEN METHODS
  /// ===============================
  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  /// ===============================
  /// SIGN IN
  /// ===============================
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: _headers(),
      body: jsonEncode({
        "Email": email,
        "Password": password,
      }),
    );

    final data = jsonDecode(response.body);

    /// Save token if exists
    if (data["token"] != null) {
      setToken(data["token"]);
    }

    return data;
  }

  /// ===============================
  /// SIGN UP
  /// ===============================
  static Future<Map<String, dynamic>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String dob,
    required String? country,
    required String? gender,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: _headers(),
      body: jsonEncode({
        "FirstName": firstName,
        "LastName": lastName,
        "Email": email,
        "Phone": phone,
        "Password": password,
        "DateOfBirth": dob,
        "Country": country,
        "Gender": gender,
      }),
    );

    return jsonDecode(response.body);
  }

  /// ===============================
  /// FORGOT PASSWORD (SEND OTP)
  /// ===============================
  static Future<void> forgotPassword({
    required String email,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: _headers(),
      body: jsonEncode({
        "Email": email,
      }),
    );
  }

  /// ===============================
  /// VERIFY OTP
  /// ===============================
  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: _headers(),
      body: jsonEncode({
        "Email": email,
        "Otp": otp,
      }),
    );
  }

  /// ===============================
  /// RESEND OTP
  /// ===============================
  static Future<void> resendOtp({
    required String email,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/auth/resend-otp"),
      headers: _headers(),
      body: jsonEncode({
        "Email": email,
      }),
    );
  }

  /// ===============================
  /// RESET PASSWORD
  /// ===============================
  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/auth/reset-password"),
      headers: _headers(),
      body: jsonEncode({
        "Email": email,
        "Otp": otp,
        "Password": password,
      }),
    );
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  static void logout() {
    clearToken();
  }

  /// ===============================
  /// CHECK LOGIN STATUS
  /// ===============================
  static bool get isLoggedIn => _token != null;
}