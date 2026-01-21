
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Home")),
      body: const Center(child: Text("Welcome Home")),
    );
  }
}