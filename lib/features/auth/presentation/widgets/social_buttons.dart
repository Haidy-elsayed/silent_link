
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // استدعاء المكتبة

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  // Function لفتح الروابط
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // مقاس الأيقونات الموحد
    double iconSize = 30.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // فيسبوك
        GestureDetector(
          onTap: () => _launchURL('https://www.facebook.com'),
          child: Icon(Icons.facebook, color: Colors.blue, size: iconSize),
        ),

        const SizedBox(width: 15),

        // جوجل (باستخدام الصورة من الـ Assets)
        GestureDetector(
          onTap: () => _launchURL('https://www.google.com'),
          child: Image.asset(
            'assets/icons/Google.png', // تأكدي من المسار والاسم صح
            width:25.0,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),

        const SizedBox(width: 15),

        // أبل
        GestureDetector(
          onTap: () => _launchURL('https://www.apple.com'),
          child: Icon(Icons.apple, color: Colors.black, size: iconSize),
        ),
      ],
    );
  }
}