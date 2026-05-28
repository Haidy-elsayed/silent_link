/**
import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';

import 'features/auth/sign_in_screen.dart';
import 'features/chat_bot/chat_bot_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/permission/pirmission_screen.dart';
import 'features/splash/splash_screen.dart';
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


          // home:HomeScreen (),


    );
  }
}

**/
/**
import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';

import 'features/auth/sign_in_screen.dart';
import 'features/chat_bot/chat_bot_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/permission/pirmission_screen.dart';
import 'features/splash/splash_screen.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FMTCObjectBoxBackend().initialise();

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
          iconTheme: IconThemeData(
            color: AppColors.primary,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ),
        visualDensity:
        VisualDensity.adaptivePlatformDensity,
      ),

      home: const SplashPage(),

      // home: HomeScreen(),
    );
  }
}
**/
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/service/auth_service.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FMTCObjectBoxBackend().initialise();

  /// تحميل التوكن
  await AuthServices.loadToken();

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
    );
  }
}
