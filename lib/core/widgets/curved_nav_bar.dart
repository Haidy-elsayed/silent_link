import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../constants/app_icons.dart';


class CustomCurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomCurvedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double iconSize = 28;

  Widget navIcon(String icon, bool selected) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: SvgPicture.asset(
        icon,
        fit: BoxFit.contain,
        color: selected
            ? AppColors.navIconSelected
            : AppColors.navIconUnselected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,

      height: 65,

      backgroundColor: Colors.transparent,

      color: AppColors.navBar,

      buttonBackgroundColor: AppColors.navBarCircle,

      animationDuration: const Duration(milliseconds: 300),

      items: [
        navIcon(AppIcons.sos, currentIndex == 0),

        navIcon(AppIcons.ai, currentIndex == 1),

        navIcon(AppIcons.home, currentIndex == 2),

        navIcon(AppIcons.map, currentIndex == 3),

        navIcon(AppIcons.settings, currentIndex == 4),
      ],

      onTap: onTap,
    );
  }
}
