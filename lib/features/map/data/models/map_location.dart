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