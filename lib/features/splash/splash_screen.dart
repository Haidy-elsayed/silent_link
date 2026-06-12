import 'package:flutter/material.dart';

import 'package:silent_link/core/storage/app_statement_manager.dart';
import 'package:silent_link/core/navigation/main_navigation_screen.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';
import 'package:silent_link/features/onboarding/onboarding_screen.dart';
import 'package:silent_link/features/permission/pirmission_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    //**********
    final logged = false;
    final permissions =false;
    final seen = false;
    //*********
    //final seen = await AppStateManager.isOnboardingSeen();

    //final permissions = await AppStateManager.isPermissionsGranted();

    //final logged = await AppStateManager.isLoggedIn();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    /// أول مرة
    if (!seen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    }
    /// permissions
    else if (!permissions) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionsPage()),
      );
    }
    /// logged in
    else if (logged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
    /// مش عامل login
    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [Image.asset('assets/images/splash3.png', fit: BoxFit.cover)],
      ),
    );
  }
}
