import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_link/features/home/widgets/emergency_slider.dart';
import 'package:silent_link/features/home/widgets/weather_card.dart';
import 'package:silent_link/features/auth/widgets/auth_provider.dart'; 
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_app_bar.dart';
import '../../providers/user_provider.dart';
import 'widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String userToken = Provider.of<AuthProvider>(context, listen: false).token ?? ""; 
      if (userToken.isNotEmpty) {
        Provider.of<UserProvider>(context, listen: false).fetchUserData(userToken);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Home',
        leadingIcon: Icons.wifi,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 10),
            const WeatherCard(),
            const SizedBox(height: 30),
            
            SizedBox(
              height: 300,
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                    child: EmergencyNumbersCard(),
                  ),
                  _buildTipCard("Keep your Bluetooth turned ON during emergencies to stay connected to the nearby rescue network."),
                  _buildTipCard("Lower your screen brightness and close background apps to save battery life."),
                  _buildTipCard("Ensure your Location Services (GPS) are active so rescue teams can pinpoint your location."),
                  _buildTipCard("Drop, Cover, and Hold on! Stay away from glass, windows, and heavy furniture."),
                  _buildTipCard("Heavy smoke? Stay low and crawl to the nearest exit to breathe cleaner air."),
                  _buildTipCard("Always have a 'Go-Bag' ready with water, a flashlight, and a first-aid kit."),
                  _buildTipCard("Need immediate first-aid steps? Ask our offline AI assistant for quick guidance."),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPaginationDots(8), 
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 40),
          const SizedBox(height: 15),
          Text(
            tip,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDots(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 12 : 8,
        height: 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
        ),
      )),
    );
  }
}