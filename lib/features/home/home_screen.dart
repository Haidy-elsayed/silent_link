import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
//import '../../core/constants/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 20),

              /// نفس ستايل SOS و MAP
              const Text(
                "Home",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              ),

              const Expanded(
                child: Center(
                  child: Text(
                    "Welcome Home",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
