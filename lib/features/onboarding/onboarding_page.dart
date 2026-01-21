
import 'package:flutter/material.dart';
import 'package:silent_link/features/onboarding/widgets/onboarding_item.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/colors.dart';
import '../../core/storage/app_statement_manager.dart';
import '../auth/sign_in_page.dart';
import '../permission/pirmission_page.dart';
import 'data/onboarding_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  bool _isLast = false;

  final List<OnboardingModel> _pages = const [
    OnboardingModel(
      title: "welcome to the disaster safety app",
      subTitle: "stay updated on earthquakes and floods in real time",
      description: "Stay safe anytime",
      image: "assets/images/welcome_photo.png",
      layoutType: OnboardingLayoutType.normal,
    ),
    OnboardingModel(
      title: "what does the app cover",
      subTitle: "track earthquakes, floods, hurricanes and other emergencies",
      description: "",
      gridImages: [
        "assets/images/1.png",
        "assets/images/2.png",
        "assets/images/3.png",
        "assets/images/4.png",
      ],
      layoutType: OnboardingLayoutType.gridImages,
    ),
    OnboardingModel(
      title: "Instant alerts",
      subTitle: "Receive real-time notifications about important events",
      description: "",
      image: "assets/images/notification_photo.png",
      layoutType: OnboardingLayoutType.bottomText,
    ),
  ];

  // 👇 دالة موحدة للانتقال لصفحة تسجيل الدخول وحفظ الحالة
  Future<void> _completeOnboarding() async {
    await AppStateManager.setOnboardingSeen();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const PermissionsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea( // لضمان عدم تداخل زر Skip مع شريط الساعة
        child: Stack(
          children: [
            // 1. عرض الصفحات
            PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              onPageChanged: (i) =>
                  setState(() => _isLast = i == _pages.length - 1),
              itemBuilder: (_, i) => OnboardingItem(model: _pages[i]),
            ),

            // 2. زر الـ Skip (يظهر فقط إذا لم نكن في الصفحة الأخيرة)
            if (!_isLast)
              Positioned(
                top: 10,
                right: 20,
                child: TextButton(
                  onPressed: _completeOnboarding, // يودي للـ Sign In فوراً
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Color(0xFF5BA480), // نفس لون الأخضر
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // 3. التحكم السفلي (Indicator + Next/Get Started)
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotHeight: 10,
                      dotWidth: 10,
                      dotColor: Colors.grey,
                      activeDotColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5BA480),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (_isLast) {
                          _completeOnboarding(); // يودي للـ Sign In
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _isLast ? "Get Started" : "Next",
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}