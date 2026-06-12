import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
//import '../../../core/constants/colors.dart';

class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isGranted;
  final VoidCallback? onAllow;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isGranted,
    required this.onAllow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // تم تغيير height لـ constraints ليكون مرن
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isGranted
            ? AppColors.primaryDark.withOpacity(0.85)
            : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: AppColors.background),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // يجعل العمود يأخذ مساحة المحتوى فقط
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.background,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.background.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // تقليل المسافة قليلاً لتوفير مساحة
          _AllowButton(isGranted: isGranted, onPressed: onAllow),
        ],
      ),
    );
  }
}


class _AllowButton extends StatelessWidget {
  final bool isGranted;
  final VoidCallback? onPressed;

  const _AllowButton({required this.isGranted, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SizedBox(
        width: 100, // زيادة العرض قليلاً لتجنب ضيق النص داخل الزر
        height: 36,
        child: ElevatedButton(
          onPressed: isGranted ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isGranted ? Colors.white : AppColors.background,
            disabledBackgroundColor: Colors.white.withOpacity(0.8),
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isGranted ? "Granted" : "Allow",
                style: TextStyle(
                  color: isGranted ? AppColors.secondary : AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isGranted) ...[
                const SizedBox(width: 2),
                const Icon(Icons.check, size: 14, color: AppColors.primaryDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}