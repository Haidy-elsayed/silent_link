import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'features/sos/services/sos_queue_service.dart';
import 'features/sos/services/bluetooth_service.dart';
import 'features/sos/services/notification_service.dart';
import 'features/sos/presentation/screens/sos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  SosQueueService().start();
  final btService = BluetoothService();
  await btService.start('SilentLink User');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Silent Link',
      // FIX: navigatorKey عشان الـ notification tap يعمل navigate
      navigatorKey: navigatorKey,
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
      home: const SplashScreen(),
      // FIX: لما الـ notification تتضغط → بيروح على SosScreen مباشرةً
      routes: {
        '/sos': (context) => const SosScreen(),
      },
    );
  }
}