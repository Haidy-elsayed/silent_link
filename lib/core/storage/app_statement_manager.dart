import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
class AppStateManager {
  static const _loginKey = 'is_logged_in';
  static const _onboardingKey = 'onboarding_seen';

  static Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<bool> isOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }
  static const _permissionsKey = 'permissions_granted';

  static Future<void> setPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionsKey, true);
  }

  static Future<bool> isPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionsKey) ?? false;
  }
}