// import 'package:flutter/material.dart';

// import '../core/widgets/curved_nav_bar.dart';

// import '../features/home/home_screen.dart';
// import '../features/sos/sos_screen.dart';
// import '../features/map/map_page.dart';
// import '../features/settings/settings_screen.dart';
// import '../features/chat_bot/chat_bot_screen.dart';
// /**
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int currentIndex = 2;

//   final List<Widget> pages = [
//     const SosPage(),
//     const HomeScreen(),
//     MapPage(),
//     const SettingsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex > 1 ? currentIndex - 1 : currentIndex],

//       bottomNavigationBar: CustomCurvedNavBar(
//         currentIndex: currentIndex,

//         onTap: (index) {
//           /// لو ضغط ChatBot
//           if (index == 1) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const ChatBotScreen()),
//             );

//             return;
//           }

//           setState(() {
//             currentIndex = index;
//           });
//         },
//       ),
//     );
//   }
// }
// **/
// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int currentIndex = 2; // Home default

//   final List<Widget> pages = [
//     const SosPage(),       // 0
//     const ChatBotScreen(), // 1 (placeholder فقط)
//     const HomeScreen(),    // 2
//     MapPage(),             // 3
//     const SettingsPage(),  // 4
//   ];

//   void onTap(int index) {
//     /// 🔴 ChatBot زر مستقل
//     if (index == 1) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const ChatBotScreen(),
//         ),
//       );
//       return;
//     }

//     setState(() {
//       currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[currentIndex],

//       bottomNavigationBar: CustomCurvedNavBar(
//         currentIndex: currentIndex,
//         onTap: onTap,
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:silent_link/core/widgets/curved_nav_bar.dart';
import 'package:silent_link/features/sos/presentation/screens/sos_screen.dart';

import '../../../features/home/home_screen.dart';

import '../../../features/map/map_page.dart';
import '../../../features/settings/settings_screen.dart';
import '../../../features/chat_bot/chat_bot_screen.dart';

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
     MapPage(),
    const SettingsPage(),
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