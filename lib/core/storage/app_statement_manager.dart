import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; 

class AppStateManager {
  // Keys
  static const _loginKey = 'is_logged_in';
  static const _onboardingKey = 'onboarding_seen';
  static const _userNameKey = 'user_name';
  static const _locationKey = 'user_location';
  static const _permissionsKey = 'permissions_granted';

  // --- Auth Section ---
  static Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
    
    await prefs.remove(_userNameKey);
    await prefs.remove(_locationKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  // --- User Info Section ---
  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<void> saveLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_locationKey, location);
  }

  static Future<String?> getLocation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_locationKey);
  }

  // --- Onboarding Section ---
  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  // --- Permissions Section ---
  static Future<void> setPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsKey, true);
  }

  static Future<bool> isPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsKey) ?? false;
  }
}