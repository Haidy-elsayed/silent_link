
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
//import '../../../core/constants/colors.dart';
import '../data/onboarding_model.dart';



class OnboardingItem extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingItem({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          _buildLayout(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    switch (model.layoutType) {
      case OnboardingLayoutType.normal:
        return Column(
          children: [
            _title(),
            const SizedBox(height: 50),
            _subTitle(),
            const SizedBox(height: 30),
            _image(height: 220),
            const SizedBox(height: 50),
            _descriptionLarge(), // تم استخدام المقاس الكبير هنا
          ],
        );
      case OnboardingLayoutType.gridImages:
        return Column(
          children: [
            _titleLarge(), // في صفحة الـ Grid العنوان هو الأخضر الكبير
            const SizedBox(height: 20),
            _subTitle(),
            const SizedBox(height: 30),
            _gridLayout(),
          ],
        );
      case OnboardingLayoutType.bottomText:
        return Column(
          children: [
            _image(height: 250),
            const SizedBox(height: 30),
            _titleLarge(), // في صفحات Alert العنوان هو الأخضر الكبير
            const SizedBox(height: 10),
            _subTitle(),
          ],
        );
    }
  }

  // --- نصوص باللون الأخضر وبحجم كبير جداً ---
  Widget _titleLarge() => Text(
    model.title,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 30, //مقاس ضخم
      fontWeight: FontWeight.w900,
      color: AppColors.primary,
      height: 1.1,
    ),
  );

  Widget _descriptionLarge() => Text(
    model.description,
    textAlign: TextAlign.center,
    style: const TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w900,
      color: AppColors.primary,
    ),
  );

  // --- النصوص العادية ---
  Widget _title() => Text(
    model.title,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
  );

  Widget _subTitle() => Text(
    model.subTitle,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 18, color: AppColors.black, height: 1.4),
  );

  // --- معالجة خطأ الصور ---
  Widget _image({required double height}) {
    if (model.image == null) return const SizedBox();
    return Image.asset(
      model.image!,
      height: height,
      fit: BoxFit.contain,
      // هذا الجزء يمنع التطبيق من الانهيار إذا لم يجد الصورة ويظهر أيقونة بديلة
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          color: Colors.grey[200],
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        );
      },
    );
  }

  Widget _gridLayout() => GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      physics: const NeverScrollableScrollPhysics(),
      children: model.gridImages!.map((e) => ClipRRect(
        borderRadius: BorderRadius.circular(0),
        child: Image.asset(
            e,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(color: Colors.grey[300]),
      ),
      )).toList(),
  );
}