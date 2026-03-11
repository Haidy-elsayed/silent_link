import 'package:flutter/material.dart';

import '../core/widgets/curved_nav_bar.dart';

import '../features/home/home_screen.dart';
import '../features/sos/sos_screen.dart';
import '../features/map/map_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/chat_bot/chat_bot_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 2;

  final List<Widget> pages = const [
    SosPage(),
    HomeScreen(),
    MapPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex > 1 ? currentIndex - 1 : currentIndex],

      bottomNavigationBar: CustomCurvedNavBar(
        currentIndex: currentIndex,

        onTap: (index) {
          /// لو ضغط ChatBot
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatBotScreen()),
            );

            return;
          }

          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
