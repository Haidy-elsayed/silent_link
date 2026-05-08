import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/map_location.dart';
/**
class MapApiService {
  final String baseUrl = "https://your-api.com";

  Future<List<MapLocationModel>> getLocations() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/locations"),
        headers: {
          "Content-Type": "application/json",
          // لو عندك token:
          // "Authorization": "Bearer YOUR_TOKEN",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => MapLocationModel.fromJson(e))
            .toList();
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      throw Exception("No Internet or Server Down");
    }
  }
}
    **/
import '../models/map_location.dart';

class MapApiService {
  Future<List<MapLocationModel>> getLocations() async {
    await Future.delayed(Duration(seconds: 1));

    return [
      MapLocationModel(id: 1, lat: 30.0444, lng: 31.2357, type: "danger"),
      MapLocationModel(id: 2, lat: 30.05, lng: 31.24, type: "safe"),
      MapLocationModel(id: 3, lat: 30.03, lng: 31.22, type: "help"),
    ];
  }
}