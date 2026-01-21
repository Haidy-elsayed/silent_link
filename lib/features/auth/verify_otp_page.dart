
import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/otp_input.dart';
import 'create_new_password_page.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Verify OTP Now",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter The 6-Digit Code Sent To You",
              style: TextStyle(fontSize: 16, color: AppColors.black),
            ),
            const SizedBox(height: 50),

            // Row مربعات الـ OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => OtpInputWidget(
                  controller: _controllers[index],
                  autoFocus: index == 0,
                ),
              ),
            ),
            const SizedBox(height: 60),

            PrimaryButton(
              text: "Verify",
              onPressed: () {
                if (_otpCode.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter the 6-digit OTP")),
                  );
                  return;
                }

                print("OTP Code is: $_otpCode");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateNewPasswordPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // قسم Resend Code
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don’t You Receive Any Code? "),
                GestureDetector(
                  onTap: () => print("Resend Code Clicked"),
                  child: const Text(
                    "Resend Code",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}