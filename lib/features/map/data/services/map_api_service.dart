// 
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/map_location.dart';
import '../../../../features/auth/service/auth_service.dart';

class MapApiService {
  static const String _endpoint =
      "http://silentlink.runasp.net/api/App/map/pins";

  static const String _cacheKey = "cached_map_pins";

  // ================= CACHE =================

  static Future<void> _cachePins(List<MapLocationModel> pins) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      pins.map((e) => e.toJson()).toList(),
    );

    await prefs.setString(_cacheKey, encoded);
  }

  static Future<List<MapLocationModel>?> _getCachedPins() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);

    if (raw == null) return null;

    try {
      final List decoded = jsonDecode(raw);

      return decoded
          .map((e) => MapLocationModel.fromJson(e))
          .toList();
    } catch (_) {
      return null;
    }
  }

  // ================= API =================

  Future<List<MapLocationModel>> _fetchFromApi() async {
    final token = AuthServices.token;

    final response = await http.get(
      Uri.parse(_endpoint),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception("API failed");
    }

    final body = jsonDecode(response.body);
    final List data = body['data'] ?? [];

    final pins = data
        .map((e) => MapLocationModel.fromJson(e))
        .toList();

    await _cachePins(pins);

    return pins;
  }

  // ================= MAIN LOGIC =================

  Future<List<MapLocationModel>> getLocations() async {
    final cached = await _getCachedPins();

    try {
      final fresh = await _fetchFromApi();
      return fresh;
    } catch (_) {
      return cached ?? [];
    }
  }
}