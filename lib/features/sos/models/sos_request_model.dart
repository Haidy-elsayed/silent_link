class SosRequestModel {
  // ===========================
  // Fields
  // ===========================

  // Backend fields (PascalCase in JSON)
  final String? sosId; // nullable — الـ backend هو اللي بيبعته في الـ Response
  final String? clientRequestId; // ثابت لكل request عشان يمنع التكرار
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
    this.clientRequestId,
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
      clientRequestId: null,
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
    String? clientRequestId,
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
      clientRequestId: clientRequestId ?? this.clientRequestId,
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
    // clientRequestId — ثابت لكل request، لو مش موجود نولده من الـ createdAt
    final clientReqId = clientRequestId ?? createdAt.millisecondsSinceEpoch.toString();

    return {
      "firstName": firstName,
      "lastName": lastName,
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
      "emergencyType": emergencyType,
      "injuryType": injuryType,
      "severity": severity,
      "clientRequestId": clientReqId,
    };
  }

  // toBluetoothJson — بيبعت كل البيانات عبر Bluetooth
  Map<String, dynamic> toBluetoothJson() {
    return {
      "sosId": sosId,
      "emergencyType": emergencyType,
      "injuryType": injuryType,
      "state": state,
      "severity": severity,
      "latitude": latitude,
      "longitude": longitude,
      "locationName": locationName,
      "name": name,
      "phone": phone,
      "deliveryMethod": deliveryMethod,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  // ===========================
  // fromJson — بيستلم SosId من الـ backend
  // ===========================
  factory SosRequestModel.fromJson(Map<String, dynamic> json) {
    // بيقبل PascalCase من الـ backend وcamelCase من الـ Bluetooth
    String get(String pascal, String camel) =>
        (json[pascal] ?? json[camel] ?? '').toString();

    return SosRequestModel(
      sosId: json["SosId"]?.toString() ?? json["sosId"]?.toString(),
      emergencyType: get("EmergencyType", "emergencyType"),
      injuryType: get("InjuryType", "injuryType"),
      state: get("State", "state").isEmpty ? 'pending' : get("State", "state"),
      severity: get("Severity", "severity"),
      latitude: ((json["Latitude"] ?? json["latitude"]) ?? 0).toDouble(),
      longitude: ((json["Longitude"] ?? json["longitude"]) ?? 0).toDouble(),
      locationName: get("LocationName", "locationName"),
      organization: get("Organization", "organization"),
      country: get("Country", "country"),
      requestedByUserId: get("RequestedByUserId", "requestedByUserId"),
      name: get("Name", "name"),
      phone: get("Phone", "phone"),
      deliveryMethod: get("DeliveryMethod", "deliveryMethod").isEmpty
          ? 'local'
          : get("DeliveryMethod", "deliveryMethod"),
      createdAt: DateTime.tryParse(
            json["CreatedAt"]?.toString() ??
                json["createdAt"]?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}