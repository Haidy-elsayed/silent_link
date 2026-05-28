import '../../domain/map_location_entity.dart';

/**
class MapLocationModel extends MapLocationEntity {
  MapLocationModel({
    required super.id,
    required super.lat,
    required super.lng,
    required super.type,
  });

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: json['id'],
      lat: json['lat'].toDouble(),
      lng: json['lng'].toDouble(),
      type: json['type'],
    );
  }
}
    **/

/**
class MapLocationModel extends MapLocationEntity {
  MapLocationModel({
    required super.id,
    required super.lat,
    required super.lng,
    required super.type,
  });

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: json['id'],
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: json['type'] ?? 'unknown',
    );
  }
}
**/
import '../../domain/map_location_entity.dart';

// ✅ الـ model الحقيقي بيتعامل مع الـ API response
class MapLocationModel extends MapLocationEntity {
  MapLocationModel({
    required super.id,
    required super.lat,
    required super.lng,
    required super.type,
  });

  factory MapLocationModel.fromJson(Map<String, dynamic> json) {
    return MapLocationModel(
      id: json['pinId'],                              // ✅ API بيبعت pinId
      lat: (json['Latitude'] as num).toDouble(),      // ✅ API بيبعت Latitude بـ Capital
      lng: (json['Longitude'] as num).toDouble(),     // ✅ API بيبعت Longitude بـ Capital
      type: (json['type'] as String).toLowerCase(),   // ✅ "Danger" → "danger"
    );
  }

  // ✅ لحفظ الـ cache محلياً في SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'pinId': id,
      'Latitude': lat,
      'Longitude': lng,
      'type': type,
    };
  }
}





