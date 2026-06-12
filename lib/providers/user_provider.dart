import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_model.dart'; 
import '../services/api_service.dart'; 

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  final String _defaultName = "Malak Ahmed";
  final String _defaultEmail = "malakali2005@gmail.com";
  final String _defaultPhone = "01155919419";
  final String _defaultGender = "Female";
  final String _defaultBirthDate = "2005-03-07";
  String _country = "Egypt";

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  String get name => _user?.fullName ?? _defaultName;
  String get email => _user?.email ?? _defaultEmail;
  String get phone => _user?.phoneNumber ?? _defaultPhone;
  String get gender => _user?.gender ?? _defaultGender;
  String get birthDate => _user?.dateOfBirth ?? _defaultBirthDate;
  String get country => _country;

  Future<void> fetchUserData(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserModel? fetchedUser = await ApiService().getProfile(token);
      if (fetchedUser != null) {
        _user = fetchedUser;
      }
    } catch (e) {
      debugPrint("Error fetching user data from API: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String newName,
    required String newPhone,
    String? newGender,
    DateTime? newBirthDate,
    String? newCountry,
    required String token, 
  }) async {
    _isLoading = true;
    notifyListeners();

    String? formattedBirthDate = newBirthDate != null 
        ? DateFormat('yyyy-MM-dd').format(newBirthDate) 
        : _user?.dateOfBirth ?? _defaultBirthDate;

    UserModel updatedModel = UserModel(
      fullName: newName,
      phoneNumber: newPhone,
      gender: newGender ?? _user?.gender ?? _defaultGender,
      dateOfBirth: formattedBirthDate,
      email: _user?.email ?? _defaultEmail, 
    );

    bool isSuccess = false;

    try {
      isSuccess = await ApiService().updateProfile(updatedModel, token);
      
      if (isSuccess) {
        _user = updatedModel;
        if (newCountry != null) {
          _country = newCountry;
        }
        debugPrint("Profile updated successfully on Server and Provider!");
      }
    } catch (e) {
      debugPrint("Error updating profile in provider: $e");
    }

    _isLoading = false;
    notifyListeners();
    return isSuccess; 
  }

  void updateCountry(String countryName) {
    _country = countryName;
    notifyListeners();
  }
}