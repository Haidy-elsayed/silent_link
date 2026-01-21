
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/presentation/widgets/social_buttons.dart';
import 'package:silent_link/features/auth/sign_in_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle_bar.dart';
import '../../core/storage/app_statement_manager.dart';
import '../home/home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscure = true;

  final _formKey = GlobalKey<FormState>();

  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController  = TextEditingController();

  final _nameFocus  = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus  = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  "Create Your New Account",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Sign Up With The Following Method",
                  style: TextStyle(fontSize: 16, color: AppColors.black),
                ),
                const SizedBox(height: 40),

                AuthToggleBar(
                  isSignIn: false,
                  onToggle: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                    );
                  },
                ),
                const SizedBox(height: 30),

                CustomTextField(
                  hint: "Enter Username",
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                  focusNode: _nameFocus,
                  nextFocus: _emailFocus,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Username is required";
                    if (v.length < 3) return "At least 3 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Enter Email",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: _phoneFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@")) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  nextFocus: _passFocus,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Phone is required";
                    if (v.length < 10) return "Invalid phone number";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Create Password",
                  prefixIcon: Icons.lock_outline,
                  controller: _passController,
                  focusNode: _passFocus,
                  obscure: obscure,
                  textInputAction: TextInputAction.done,
                  suffixIcon: obscure ? Icons.visibility_off : Icons.visibility,
                  onSuffixPressed: () => setState(() => obscure = !obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    if (v.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: "Sign Up",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // 1. حفظ المستخدم كمسجل دخول
                      await AppStateManager.setLoggedIn();

                      // 2. الانتقال للـ HomePage وإزالة كل الصفحات السابقة
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                      );
                    }
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColors.primary, thickness: 1, endIndent: 10)),
                    Text("OR", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(child: Divider(color: AppColors.primary, thickness: 1, indent: 10)),
                  ],
                ),
                const SizedBox(height: 20),

                const SocialButtons(),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already Have An Account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      ),
                      child: const Text(
                        "Sign In",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}