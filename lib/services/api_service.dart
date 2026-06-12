import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:silent_link/models/user_model.dart'; 

class ApiService {
  final String baseUrl = 'http://silentlink.runasp.net';

  
  Future<UserModel?> getProfile(String token) async {
  
    if (token.isEmpty || token == "null" || token.trim() == "") {
      print('ApiService (getProfile) skipped: Token is empty or null');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/App/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('data') && responseData['data'] != null) {
          return UserModel.fromJson(responseData['data']);
        }
        
        return UserModel.fromJson(responseData);
      }
    } catch (e) {
      print('Error in API Service (getProfile): $e');
    }
    return null;
  }

  Future<bool> updateProfile(UserModel updatedProfile, String token) async {
    if (token.isEmpty || token == "null") return false;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/App/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(updatedProfile.toJson()),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error in API Service (updateProfile): $e');
    }
    return false;
  }


  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String token,
  }) async {
    if (token.isEmpty || token == "null") return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/auth/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error in API Service (changePassword): $e');
    }
    return false;
  }

 
  Future<bool> forgotPassword({required String email}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true; 
      }
    } catch (e) {
      print('Error in ApiService (forgotPassword): $e');
    }
    return false;
  }

  Future<bool> createPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/user/auth/create-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'resetToken': resetToken,
          'new_Password': newPassword, 
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print('Error in ApiService (createPassword): $e');
    }
    return false;
  }

 
  Future<bool> sendSOS(String token) async {
    if (token.isEmpty || token == "null") return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/App/SOS'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print('Error in API Service (sendSOS): $e');
    }
    return false;
  }
}