
import 'package:flutter/material.dart';
import '../constants/colors.dart';
class AuthToggleBar extends StatelessWidget {
  final bool isSignIn;
  final VoidCallback onToggle;

  const AuthToggleBar({
    super.key,
    required this.isSignIn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        // 1. درجة الرمادي الثابتة للمستطيل الخلفي
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(15),
        // 2. إضافة الشادو ليعطي عمق للتصميم
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 7,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Stack( // استخدمنا Stack لعمل تأثير الحركة فوق الخلفية الرمادية
        children: [
          Row(
            children: [
              // زر الـ Sign In
              Expanded(
                child: GestureDetector(
                  onTap: () { if (!isSignIn) onToggle(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSignIn ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Sign In",
                      style: TextStyle(
                        color: isSignIn ? AppColors.black : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // زر الـ Sign Up
              Expanded(
                child: GestureDetector(
                  onTap: () { if (isSignIn) onToggle(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: !isSignIn ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: !isSignIn ? AppColors.black : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}