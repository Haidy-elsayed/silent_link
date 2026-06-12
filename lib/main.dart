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
// import 'package:flutter/material.dart';
// import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
// import 'core/constants/app_colors.dart';
// import 'features/auth/service/auth_service.dart';
// import 'features/splash/splash_screen.dart';
// import 'features/sos/services/bluetooth_service.dart';
// import 'features/sos/services/notification_service.dart';
// import 'features/sos/services/local_db_service.dart';
// import 'features/sos/services/sos_queue_service.dart';
// import 'features/sos/presentation/screens/sos_success_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await FMTCObjectBoxBackend().initialise();

//   // تحميل التوكن
//   await AuthServices.loadToken();

//   // تشغيل الـ notification service
//   await NotificationService().init();

//   // لما المستخدم يدوس على notification بتاعة state_change
//   // → روح على SosSuccessScreen بالـ sosId والـ state الجديدة
//   NotificationService().onNotificationOpenSosSuccess = (sosId, state) {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (_) => SosSuccessScreen(
//           requestId: sosId,
//           status: state,
//         ),
//       ),
//     );
//   };

//   // تشغيل الـ retry queue في الـ background
//   SosQueueService().start();

//   // تشغيل الـ Bluetooth في الـ background عشان يستقبل SOS
//   final btService = BluetoothService();
//   btService.onSosReceived = (request) async {
//     await LocalDbService().insertSosRequest(request);
//   };
//   await btService.start('SilentLink User');

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       debugShowCheckedModeBanner: false,
//       title: 'Silent Link',
//       theme: ThemeData(
//         primaryColor: AppColors.primary,
//         scaffoldBackgroundColor: AppColors.background,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: AppColors.background,
//           elevation: 0,
//           iconTheme: IconThemeData(color: AppColors.primary),
//         ),
//         colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

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
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'features/auth/service/auth_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/sos/services/bluetooth_service.dart';
import 'features/sos/services/notification_service.dart';
import 'features/sos/services/local_db_service.dart';
import 'features/sos/services/sos_queue_service.dart';
import 'features/sos/presentation/screens/sos_success_screen.dart';

import 'package:silent_link/features/auth/widgets/auth_provider.dart';
import 'providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FMTCObjectBoxBackend().initialise();

  // تحميل التوكن
  await AuthServices.loadToken();

  // تشغيل الـ notification service
  await NotificationService().init();

  NotificationService().onNotificationOpenSosSuccess = (sosId, state) {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.popUntil((route) => route.isFirst);
    nav.push(
      MaterialPageRoute(
        builder: (_) => SosSuccessScreen(
          requestId: sosId,
          status: state,
        ),
      ),
    );
  };

  SosQueueService().start();

  final btService = BluetoothService();

  btService.onSosReceived = (request) async {
    await LocalDbService().insertSosRequest(request);

    await NotificationService().sendIncomingSosNotification(
      senderName: request.name.isEmpty ? 'Unknown' : request.name,
      emergencyType:
          request.emergencyType.isEmpty ? 'Emergency' : request.emergencyType,
      location: request.locationName.isEmpty
          ? '${request.latitude.toStringAsFixed(3)}, ${request.longitude.toStringAsFixed(3)}'
          : request.locationName,
      createdAt: request.createdAt.toIso8601String(),
    );

    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.push(
        MaterialPageRoute(
          builder: (_) => SosSuccessScreen(
            requestId: request.clientRequestId ??
                request.createdAt.millisecondsSinceEpoch.toString(),
            status: 'pending_connection',
            request: request,
          ),
        ),
      );
    }
  };

  btService.onSosIdReceived = (sosId, state) async {
    await NotificationService().trackSosId(sosId);
    NotificationService().startPolling();

    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.popUntil((route) => route.isFirst);
      nav.push(
        MaterialPageRoute(
          builder: (_) => SosSuccessScreen(
            requestId: sosId,
            status: state,
          ),
        ),
      );
    }
  };

  await btService.start('SilentLink User');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Silent Link',
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
    );
  }
}