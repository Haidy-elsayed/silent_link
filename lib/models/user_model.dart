class UserModel {
  final String? fullName;
  final String? email; 
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? country; // 🚀 متغيّر البلد لايف

  UserModel({
    this.fullName,
    this.email,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.country, 
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'] ?? json['name'], 
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['phone'],
      dateOfBirth: json['dateOfBirth'],
      gender: json['gender'],
      // 🌍 بيقرأ البلد من السيرفر (تأكدي إن الباك اند بيرجعها باسم country أو countryName)
      country: json['country'] ?? json['countryName'], 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'country': country, // 🚀 إرسال البلد للـ API أثناء التسجيل أو التحديث
    };
  }
}