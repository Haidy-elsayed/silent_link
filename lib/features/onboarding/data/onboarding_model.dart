
import 'package:flutter/material.dart';

// 1. لازم نضيف الـ Enum ده عشان نحدد شكل كل صفحة
enum OnboardingLayoutType {
  normal,       // للكل (عنوان فوق، صورة، وصف تحت) - زي الصورة الأولى
  gridImages,   // لصفحة الـ 4 صور
  bottomText,   // للصورة اللي عنوانها تحتها - زي الصورة الثالثة والرابعة
}

class OnboardingModel {
  final String title;
  final String subTitle;
  final String description;
  final String? image;
  final List<String>? gridImages;
  final OnboardingLayoutType layoutType; // ده المتغير اللي هيتحكم في الشكل

  const OnboardingModel({
    required this.title,
    required this.subTitle,
    required this.description,
    this.image,
    this.gridImages,
    // هنا بنخلي الـ normal هو الافتراضي لو نسينا نحدد
    this.layoutType = OnboardingLayoutType.normal,
  });
}