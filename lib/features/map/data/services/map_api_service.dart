import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../models/map_location.dart';

/**
class MapApiService {
  Future<List<MapLocationModel>> getLocations() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      MapLocationModel(id: 1, lat: 30.0444, lng: 31.2357, type: "danger"),
      MapLocationModel(id: 2, lat: 30.05, lng: 31.24, type: "safe"),
      MapLocationModel(id: 3, lat: 30.03, lng: 31.22, type: "help"),
    ];
  }
}
    **/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_location.dart';
import '../../../../features/auth/service/auth_service.dart';

class MapApiService {
  static const String _endpoint =
      "https://silentlink.runasp.net/api/App/map/pins";

  // ✅ الـ key اللي بنحفظ بيه الـ pins في الـ cache
  static const String _cacheKey = "cached_map_pins";

  // ============================================================
  // 🟡 LOCAL FALLBACK DATA — شيلي الـ comment دي لو مش عايزاه
  // ============================================================
  static List<MapLocationModel> _getFallbackData() {
    return [
      MapLocationModel(id: 1,  lat: 30.0444, lng: 31.2357, type: "danger"),
      MapLocationModel(id: 2,  lat: 30.0626, lng: 31.2497, type: "danger"),
      MapLocationModel(id: 3,  lat: 29.9773, lng: 31.1325, type: "danger"),
      MapLocationModel(id: 4,  lat: 30.0210, lng: 31.2118, type: "danger"),
      MapLocationModel(id: 5,  lat: 30.0480, lng: 31.2400, type: "danger"),
      MapLocationModel(id: 6,  lat: 30.0330, lng: 31.2500, type: "danger"),
      MapLocationModel(id: 7,  lat: 30.0732, lng: 31.3461, type: "safe"),
      MapLocationModel(id: 8,  lat: 30.0956, lng: 31.3178, type: "safe"),
      MapLocationModel(id: 9,  lat: 30.0185, lng: 31.4152, type: "safe"),
      MapLocationModel(id: 10, lat: 30.0595, lng: 31.2239, type: "safe"),
      MapLocationModel(id: 11, lat: 30.0700, lng: 31.3300, type: "safe"),
      MapLocationModel(id: 12, lat: 30.0800, lng: 31.3000, type: "safe"),
      MapLocationModel(id: 13, lat: 30.0500, lng: 31.2350, type: "help"),
      MapLocationModel(id: 14, lat: 30.0409, lng: 31.2090, type: "help"),
      MapLocationModel(id: 15, lat: 30.0276, lng: 31.2331, type: "help"),
      MapLocationModel(id: 16, lat: 29.9970, lng: 31.1710, type: "help"),
      MapLocationModel(id: 17, lat: 30.0600, lng: 31.2400, type: "help"),
      MapLocationModel(id: 18, lat: 30.0550, lng: 31.2600, type: "help"),
    ];
  }
  // ============================================================

  // ✅ حفظ الـ pins في الـ cache
  static Future<void> _cachePins(List<MapLocationModel> pins) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(pins.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, encoded);
  }

  // ✅ جيب الـ pins من الـ cache
  static Future<List<MapLocationModel>?> _getCachedPins() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return null;
    final List decoded = jsonDecode(raw);
    return decoded.map((e) => MapLocationModel.fromJson(e)).toList();
  }

  // ✅ الـ main function

  Future<List<MapLocationModel>> getLocations() async {
    try {
      final token = AuthServices.token;

      final response = await http.get(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",


        },
      ).timeout(const Duration(seconds: 10));


      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        final pins = data.map((e) => MapLocationModel.fromJson(e)).toList();

        // ✅ حفظ آخر update في الـ cache
        await _cachePins(pins);
        return pins;
      } else {
        // ❌ API error → جرب الـ cache الأول
        return await _getCachedPins() ?? _getFallbackData();
      }
    } catch (_) {
      // ❌ No internet → جرب الـ cache الأول
      return await _getCachedPins() ?? _getFallbackData();
    }
  }

}