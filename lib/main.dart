import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'features/splash/splash_screen.dart';
import 'features/sos/services/sos_queue_service.dart';
import 'features/sos/services/bluetooth_service.dart';
import 'features/sos/services/notification_service.dart';
import 'features/sos/services/local_db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تشغيل الـ notification service
  await NotificationService().init();

  // تشغيل الـ retry queue
  SosQueueService().start();

  // تشغيل الـ Bluetooth في الـ background عشان يستقبل SOS من أجهزة تانية
  final btService = BluetoothService();
  btService.onSosReceived = (request) async {
    // لما يجي SOS عبر Bluetooth → حفظه محلياً تلقائياً
    await LocalDbService().insertSosRequest(request);
  };
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
    );
  }
}