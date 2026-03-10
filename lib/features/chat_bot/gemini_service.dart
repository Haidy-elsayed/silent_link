
import 'dart:convert';
import 'package:flutter/services.dart'; // ضروري جداً لقراءة ملف الـ JSON من الـ assets
import 'package:http/http.dart' as http;

class GeminiService {
  final String _apiKey = "AIzaSyCX2C2LaD4F4uzrzbz-JB57P-uOe9QfAzU";
  final String _url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

  Future<String> getResponse(String userInput) async {
    try {
      // 1. محاولة الاتصال بـ Gemini (الوضع أونلاين)
      final response = await http.post(
        Uri.parse("$_url?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": "You are a professional First Aid Assistant. "
                      "Provide concise, step-by-step guidance. "
                      "If the case is critical, always start by advising to call emergency services. "
                      "Respond ONLY in the same language used by the user: $userInput"
                }
              ]
            }
          ]
        }),
      ); // شيلنا الـ timeout بناءً على طلبك

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        // لو السيرفر رد بأي خطأ (مثل 404 أو 500)، ابحث في الداتا المحلية فوراً
        return await _getOfflineResponse(userInput);
      }
    } catch (e) {
      // 2. في حالة انقطاع الإنترنت تماماً أو أي خطأ في الاتصال، ابحث في الداتا المحلية
      print("Switching to Offline Mode: $e");
      return await _getOfflineResponse(userInput);
    }
  }

  // دالة البحث الذكي داخل الـ 200 حالة في ملف الـ JSON المحلي
  Future<String> _getOfflineResponse(String userInput) async {
    try {
      // قراءة ملف الـ JSON
      final String jsonString = await rootBundle.loadString('assets/first_aid_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List cases = data['cases'];

      // تجهيز النص للبحث (حروف صغيرة وبدون مسافات زائدة)
      String inputLower = userInput.toLowerCase().trim();

      for (var item in cases) {
        List keywords = item['keywords'];
        // التحقق إذا كانت أي كلمة مفتاحية موجودة في سؤال المستخدم
        if (keywords.any((key) => inputLower.contains(key.toLowerCase()))) {
          return "\n\n${item['response']}";
        }
      }

      // في حال لم يتم العثور على الكلمة في الـ 200 حالة
      return "No internet connection and this specific case is not in our local database. Please try common keywords like: Burn, Bleeding, or Heart Attack.";

    } catch (e) {
      // في حال حدث خطأ تقني في قراءة ملف الـ JSON نفسه
      return "Connection error and local database is unavailable. Please check your network.";
    }
  }
}