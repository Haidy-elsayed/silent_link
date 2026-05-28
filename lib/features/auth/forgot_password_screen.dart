
/**
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/verify_otp_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../core/constants/app_colors.dart';
import 'service/auth_service.dart'; // 👈 IMPORTANT

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isLoading = false;

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
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Enter your email to receive OTP",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 60),

                  CustomTextField(
                    hint: "Enter Email",
                    prefixIcon: Icons.email_outlined,
                    controller: _emailController,
                    focusNode: _emailFocus,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Email is required";
                      }
                      if (!v.contains("@")) {
                        return "Invalid email format";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 60),

                  PrimaryButton(
                    text: _isLoading ? "Sending..." : "Send OTP",
                    onPressed: _isLoading ? null : _sendOtp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 CLEAN SERVICE CALL
  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthServices.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send OTP"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
**/
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/verify_otp_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../core/constants/app_colors.dart';
import 'service/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocus = FocusNode();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await AuthServices.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("OTP sent successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const BackButton(
          color: AppColors.primary,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Form(
            key: _formKey,

            child: Column(
              children: [

                const SizedBox(height: 20),

                const Text(
                  "Forgot Password",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Enter your email to receive OTP",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 60),

                /// EMAIL FIELD
                CustomTextField(
                  hint: "Enter Email",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Email is required";
                    }

                    if (!v.contains("@")) {
                      return "Invalid email format";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 60),

                /// SEND OTP BUTTON
                PrimaryButton(
                  text: _isLoading
                      ? "Sending..."
                      : "Send OTP",

                  onPressed:
                  _isLoading ? null : _sendOtp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}