import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/chat_bot/chat_bot_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/permission/pirmission_screen.dart';
import 'features/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.primary),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashPage(),

      // home: ChatBotScreen (),
    );
  }
}
