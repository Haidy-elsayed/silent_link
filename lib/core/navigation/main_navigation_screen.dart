import 'package:flutter/material.dart';
import '../widgets/curved_nav_bar.dart';
import '../../features/home/home_screen.dart';
import '../../features/sos/presentation/screens/sos_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/chat_bot/chat_bot_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 2;

  // FIX: مش const عشان IndexedStack يشتغل صح
  final List<Widget> pages = [
    const SosScreen(),
    const HomeScreen(),
    const MapScreen(),
    const SettingsScreen(),
  ];

  int get _pageIndex => currentIndex > 1 ? currentIndex - 1 : currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: IndexedStack بيحتفظ بكل الـ screens في الـ memory
      // SosScreen مش بيتـdispose لما تتنقل بين الـ tabs أو الـ screens
      body: IndexedStack(
        index: _pageIndex,
        children: pages,
      ),
      bottomNavigationBar: CustomCurvedNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatBotScreen()),
            );
            return;
          }
          setState(() => currentIndex = index);
        },
      ),
    );
  }
}