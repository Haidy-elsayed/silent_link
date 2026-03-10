import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import 'verify_otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(color: AppColors.primary),
      ),
      //SafeArea و SingleChildScrollView لضمان تجربة مستخدم سلسة
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Forgot your password?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Quickly Reset Your Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                    ),
                  ),
                  const SizedBox(height: 60),

                  CustomTextField(
                    hint: "Enter Email Or Phone",
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Email or phone is required";
                      // تحسين بسيط في الـ validation
                      if (!v.contains("@") && v.length < 10) {
                        return "Enter a valid email or phone";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 60),

                  PrimaryButton(
                    text: "Submit Now",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const VerifyOtpPage()),
                        );
                      }
                    },
                  ),
                  // مساحة إضافية لتسهيل السكرول فوق الكيبورد
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

