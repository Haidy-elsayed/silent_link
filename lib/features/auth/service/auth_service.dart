
/**
import 'dart:convert';
import 'package:http/http.dart' as http;

/// ===============================
/// AUTH SERVICES
/// ===============================
class AuthServices {
  /// 🔥 BASE URL (IMPORTANT - updated to match your API)
  static const String baseUrl =
      "http://silentlink.runasp.net/api/user";

  /// ===============================
  /// TOKEN STORAGE (in memory)
  /// ===============================
  static String? _token;
  static String? _resetToken;

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

  /// reset token (for forgot password flow)
  static void setResetToken(String token) {
    _resetToken = token;
  }

  static String? get resetToken => _resetToken;

  static Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null)
        "Authorization": "Bearer $_token",
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
      Uri.parse("$baseUrl/auth/signin"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["token"] != null) {
        setToken(data["token"]);
      }
      return data;
    } else {
      throw Exception(
          data["message"] ?? "Sign in failed");
    }
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
      Uri.parse("$baseUrl/auth/signup"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "phone": phone,
        "password": password,
        "dateOfBirth": dob,
        "country": country,
        "gender": gender,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      if (data["token"] != null) {
        setToken(data["token"]);
      }
      return data;
    } else {
      throw Exception(
          data["message"] ?? "Sign up failed");
    }
  }

  /// ===============================
  /// FORGOT PASSWORD (SEND OTP)
  /// ===============================
  static Future<void> forgotPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/forgot-password"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
          data["message"] ?? "Failed to send OTP");
    }
  }

  /// ===============================
  /// VERIFY OTP
  /// ===============================
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/verify-otp"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["resetToken"] != null) {
        setResetToken(data["resetToken"]);
      }
      return data;
    } else {
      throw Exception(
          data["message"] ?? "OTP verification failed");
    }
  }

  /// ===============================
  /// RESEND OTP
  /// ===============================
  static Future<void> resendOtp({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/resend-otp"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(
          data["message"] ?? "Failed to resend OTP");
    }
  }

  /// ===============================
  /// RESET PASSWORD
  /// ===============================
  static Future<void> resetPassword({
    required String email,
    //required String otp,
    required String resetToken,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/create-password"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "resetToken": resetToken,
        "new_Password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
          data["message"] ?? "Reset password failed");
    }
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  static void logout() {
    _token = null;
    _resetToken = null;
  }

  /// ===============================
  /// CHECK LOGIN STATUS
  /// ===============================
  static bool get isLoggedIn => _token != null;
}

**/


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// ===============================
/// AUTH SERVICES
/// ===============================
class AuthServices {

  /// BASE URL
  static const String baseUrl =
      "http://silentlink.runasp.net/api/user";

  /// ===============================
  /// TOKEN STORAGE
  /// ===============================
  static String? _token;
  static String? _resetToken;

  static const String _tokenKey = "auth_token";

  /// ===============================
  /// TOKEN METHODS
  /// ===============================
  static void setToken(String token) {
    _token = token;
  }

  static String? get token => _token;

  static Future<void> saveToken(
      String token,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    _token = token;
  }

  static Future<void> loadToken() async {
    final prefs =
    await SharedPreferences.getInstance();

    _token =
        prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);

    _token = null;
  }

  /// reset token
  static void setResetToken(
      String token) {
    _resetToken = token;
  }

  static String? get resetToken =>
      _resetToken;

  static Map<String, String>
  _headers() {
    return {
      "Content-Type":
      "application/json",

      if (_token != null)
        "Authorization":
        "Bearer $_token",
    };
  }

  /// ===============================
  /// SIGN IN
  /// ===============================
  static Future<
      Map<String, dynamic>>
  signIn({
    required String email,
    required String password,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/signin",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode ==
        200) {

      /// حفظ التوكن
      if (data["token"] !=
          null) {
        await saveToken(
          data["token"],
        );
      }

      return data;
    } else {
      throw Exception(
        data["message"] ??
            "Sign in failed",
      );
    }
  }

  /// ===============================
  /// SIGN UP
  /// ===============================
  static Future<
      Map<String, dynamic>>
  signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String dob,
    required String? country,
    required String? gender,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/signup",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "firstName":
        firstName,
        "lastName":
        lastName,
        "email": email,
        "phone": phone,
        "password":
        password,
        "dateOfBirth":
        dob,
        "country":
        country,
        "gender":
        gender,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode ==
        200 ||
        response.statusCode ==
            201) {

      /// حفظ التوكن
      if (data["token"] !=
          null) {
        await saveToken(
          data["token"],
        );
      }

      return data;
    } else {
      throw Exception(
        data["message"] ??
            "Sign up failed",
      );
    }
  }

  /// ===============================
  /// FORGOT PASSWORD
  /// ===============================
  static Future<void>
  forgotPassword({
    required String email,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/forgot-password",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "email": email,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode !=
        200) {
      throw Exception(
        data["message"] ??
            "Failed to send OTP",
      );
    }
  }

  /// ===============================
  /// VERIFY OTP
  /// ===============================
  static Future<
      Map<String, dynamic>>
  verifyOtp({
    required String email,
    required String otp,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/verify-otp",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "email": email,
        "otp": otp,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode ==
        200) {

      if (data[
      "resetToken"] !=
          null) {
        setResetToken(
          data["resetToken"],
        );
      }

      return data;
    } else {
      throw Exception(
        data["message"] ??
            "OTP verification failed",
      );
    }
  }

  /// ===============================
  /// RESEND OTP
  /// ===============================
  static Future<void>
  resendOtp({
    required String email,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/resend-otp",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "email": email,
      }),
    );

    if (response.statusCode !=
        200) {
      final data =
      jsonDecode(
        response.body,
      );

      throw Exception(
        data["message"] ??
            "Failed to resend OTP",
      );
    }
  }

  /// ===============================
  /// RESET PASSWORD
  /// ===============================
  static Future<void>
  resetPassword({
    required String email,
    required String
    resetToken,
    required String
    password,
  }) async {
    final response =
    await http.post(
      Uri.parse(
        "$baseUrl/auth/create-password",
      ),

      headers: {
        "Content-Type":
        "application/json",
      },

      body: jsonEncode({
        "email": email,
        "resetToken":
        resetToken,
        "new_Password":
        password,
      }),
    );

    final data =
    jsonDecode(response.body);

    if (response.statusCode !=
        200) {
      throw Exception(
        data["message"] ??
            "Reset password failed",
      );
    }
  }

  /// ===============================
  /// LOGOUT
  /// ===============================
  static Future<void>
  logout() async {
    await clearToken();

    _resetToken = null;
  }

  /// ===============================
  /// CHECK LOGIN STATUS
  /// ===============================
  static bool get
  isLoggedIn =>
      _token != null;
}