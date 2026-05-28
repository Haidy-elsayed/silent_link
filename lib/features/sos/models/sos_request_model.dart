class SosRequestModel {
  // ===========================
  // Fields
  // ===========================

  // Backend fields (PascalCase in JSON)
  final String? sosId; // nullable — الـ backend هو اللي بيبعته في الـ Response
  final String emergencyType;
  final String injuryType;
  final String state;
  final String severity;
  final double latitude;
  final double longitude;
  final String locationName;
  final String organization;
  final String country;
  final String requestedByUserId;

  // Local fields (kept as-is)
  final String name;
  final String phone;
  final String deliveryMethod;
  final DateTime createdAt;

  const SosRequestModel({
    this.sosId,
    required this.emergencyType,
    required this.injuryType,
    required this.state,
    required this.severity,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.organization,
    required this.country,
    required this.requestedByUserId,
    required this.name,
    required this.phone,
    required this.deliveryMethod,
    required this.createdAt,
  });

  // ===========================
  // Empty Factory
  // ===========================
  factory SosRequestModel.empty() {
    return SosRequestModel(
      sosId: null,
      emergencyType: '',
      injuryType: '',
      state: 'pending',
      severity: '',
      latitude: 0,
      longitude: 0,
      locationName: '',
      organization: '',
      country: '',
      requestedByUserId: '',
      name: '',
      phone: '',
      deliveryMethod: 'local',
      createdAt: DateTime.now(),
    );
  }

  // ===========================
  // copyWith
  // ===========================
  SosRequestModel copyWith({
    String? sosId,
    String? emergencyType,
    String? injuryType,
    String? state,
    String? severity,
    double? latitude,
    double? longitude,
    String? locationName,
    String? organization,
    String? country,
    String? requestedByUserId,
    String? name,
    String? phone,
    String? deliveryMethod,
    DateTime? createdAt,
  }) {
    return SosRequestModel(
      sosId: sosId ?? this.sosId,
      emergencyType: emergencyType ?? this.emergencyType,
      injuryType: injuryType ?? this.injuryType,
      state: state ?? this.state,
      severity: severity ?? this.severity,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      organization: organization ?? this.organization,
      country: country ?? this.country,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ===========================
  // toJson — بدون SosId (الـ backend هو اللي بيولده)
  // ===========================
  // toJson — بيتطابق مع الـ Swagger بالظبط
  Map<String, dynamic> toJson() {
    // split name → firstName + lastName
    final parts = name.trim().split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    // clientRequestId — local ID بنبعته للـ backend عشان يعرف لو اتبعت قبل كده
    final clientRequestId = sosId ?? createdAt.millisecondsSinceEpoch.toString();

    return {
      "firstName": firstName,
      "lastName": lastName,
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
      "emergencyType": emergencyType,
      "injuryType": injuryType,
      "severity": severity,
      "clientRequestId": clientRequestId,
    };
  }

  // ===========================
  // fromJson — بيستلم SosId من الـ backend
  // ===========================
  factory SosRequestModel.fromJson(Map<String, dynamic> json) {
    return SosRequestModel(
      sosId: json["SosId"],
      emergencyType: json["EmergencyType"] ?? '',
      injuryType: json["InjuryType"] ?? '',
      state: json["State"] ?? 'pending',
      severity: json["Severity"] ?? '',
      latitude: (json["Latitude"] ?? 0).toDouble(),
      longitude: (json["Longitude"] ?? 0).toDouble(),
      locationName: json["LocationName"] ?? '',
      organization: json["Organization"] ?? '',
      country: json["Country"] ?? '',
      requestedByUserId: json["RequestedByUserId"] ?? '',
      name: json["Name"] ?? '',
      phone: json["Phone"] ?? '',
      deliveryMethod: json["DeliveryMethod"] ?? 'local',
      createdAt: DateTime.parse(
        json["CreatedAt"] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}