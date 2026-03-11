import 'package:flutter/material.dart';
import '../../core/storage/app_statement_manager.dart';
import '../auth/sign_in_screen.dart';
import '../home/home_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../permission/pirmission_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    // فقط أثناء التطوير:*******************************
    final logged = false;
    final permissions = false;
    final seen = false;
    //*************************
    //final seen = await AppStateManager.isOnboardingSeen();
    //final permissions = await AppStateManager.isPermissionsGranted();
    //final logged = await AppStateManager.isLoggedIn();

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (!seen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
      );
    } else if (!permissions) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionsPage()),
      );
    } else if (logged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // صورة الخلفية تغطي كل الشاشة
          Image.asset('assets/images/splash.png', fit: BoxFit.cover),
          // اللوجو في النص (اختياري)
          // Center(
          //child: Image.asset(
          //'assets/images/logo.png',
          // width: 120,
          // height: 120,
          // ),
          //),
        ],
      ),
    );
  }
}
