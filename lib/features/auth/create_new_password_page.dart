/**
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/sign_in_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool newPass = true;
  bool confirmPass = true;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
            (_) => false,
      );
    }
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
                    "Create New Password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your new password must be different from your previously used password",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.black),
                  ),
                  const SizedBox(height: 40),

                  /// New Password
                  CustomTextField(
                    hint: "New Password",
                    prefixIcon: Icons.lock_outline,
                    obscure: newPass,
                    controller: _newPassController,
                    focusNode: _newPassFocus,
                    textInputAction: TextInputAction.next,
                    suffixIcon: newPass ? Icons.visibility_off : Icons.visibility,
                    onSuffixPressed: () => setState(() => newPass = !newPass),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "New password is required";
                      if (v.length < 6) return "Password must be at least 6 characters";
                      return null;
                    },
                    nextFocus: _confirmPassFocus,
                  ),
                  const SizedBox(height: 20),

                  /// Confirm Password
                  CustomTextField(
                    hint: "Confirm Password",
                    prefixIcon: Icons.lock_outline,
                    obscure: confirmPass,
                    controller: _confirmPassController,
                    focusNode: _confirmPassFocus,
                    textInputAction: TextInputAction.done,
                    suffixIcon: confirmPass? Icons.visibility_off : Icons.visibility,
                    onSuffixPressed: () => setState(() => confirmPass = !confirmPass),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Confirm password is required";
                      if (v != _newPassController.text) return "Passwords do not match";
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),

                  /// Continue Button
                  PrimaryButton(
                    text: "Continue",
                    onPressed: _submit,
                  ),

                  // مساحة إضافية في الآخر عشان الزرار ميبقاش لازق في حافة الكيبورد
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

**/
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/sign_in_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import 'service/auth_service.dart'; // 👈 مهم

class CreateNewPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const CreateNewPasswordPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool newPass = true;
  bool confirmPass = true;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthServices.resetPassword(
        email: widget.email,
        otp: widget.otp,
        password: _newPassController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
            (route) => false,
      );

    } catch (e) {
      setState(() {
        _errorMessage = "Failed to reset password";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    "Create New Password",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Your password must be different from previous one",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  CustomTextField(
                    hint: "New Password",
                    prefixIcon: Icons.lock_outline,
                    obscure: newPass,
                    controller: _newPassController,
                    focusNode: _newPassFocus,
                    textInputAction: TextInputAction.next,
                    suffixIcon: newPass ? Icons.visibility_off : Icons.visibility,
                    onSuffixPressed: () =>
                        setState(() => newPass = !newPass),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "New password is required";
                      }
                      if (v.length < 6) {
                        return "Min 6 characters";
                      }
                      return null;
                    },
                    nextFocus: _confirmPassFocus,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    hint: "Confirm Password",
                    prefixIcon: Icons.lock_outline,
                    obscure: confirmPass,
                    controller: _confirmPassController,
                    focusNode: _confirmPassFocus,
                    textInputAction: TextInputAction.done,
                    suffixIcon: confirmPass
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixPressed: () =>
                        setState(() => confirmPass = !confirmPass),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return "Confirm password required";
                      }
                      if (v != _newPassController.text) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 40),

                  PrimaryButton(
                    text: _isLoading ? "Loading..." : "Continue",
                    onPressed: _isLoading ? null : _submit,
                  ),

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