import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sos_request_model.dart';
import '../../auth/service/auth_service.dart';

/// SOS API Service — كل الـ API calls بتاعت الـ SOS في ملف واحد
class SosApiService {
  static final SosApiService _instance = SosApiService._internal();
  factory SosApiService() => _instance;
  SosApiService._internal();

  static const String _baseUrl = 'http://silentlink.runasp.net';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (AuthServices.token != null)
          'Authorization': 'Bearer ${AuthServices.token}',
      };

  // ═══════════════════════════════════════
  // POST /api/App/S0S — إرسال طلب SOS جديد
  // ═══════════════════════════════════════
  Future<Map<String, dynamic>?> submitSos(SosRequestModel request) async {
    try {
      final body = jsonEncode(request.toJson());
      print('[SOS API] POST /api/App/S0S');
      print('[SOS API] Body: $body');
      print('[SOS API] Token: ${AuthServices.token != null ? "✅ موجود" : "❌ مفيش"}');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/App/S0S'),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('[SOS API] Status: ${response.statusCode}');
      print('[SOS API] Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final sosId = data['sosId']?.toString() ?? data['SosId']?.toString();
        final state =
            (data['state'] ?? data['State'] ?? 'pending').toString().toLowerCase();
        return {'SosId': sosId, 'State': state};
      }

      return null;
    } catch (e) {
      print('[SOS API] Error: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════
  // GET /api/App/{sosId}/state — جلب حالة الطلب
  // ═══════════════════════════════════════
  Future<String?> getSosState(String sosId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/api/App/$sosId/state'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['state'] ?? data['State'])?.toString().toLowerCase();
      }
      return null;
    } catch (e) {
      print('[SOS API] getSosState Error: $e');
      return null;
    }
  }
}