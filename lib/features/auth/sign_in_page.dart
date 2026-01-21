
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/presentation/widgets/social_buttons.dart';
import 'package:silent_link/features/auth/sign_up_page.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle_bar.dart';
import '../../core/storage/app_statement_manager.dart';
import '../home/home_page.dart';
import 'forgot_password_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscure = true;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passController  = TextEditingController();

  final _emailFocus = FocusNode();
  final _passFocus  = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();

    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const BackButton(color: AppColors.primary),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form( //  إضافة Form
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Please Sign In To Your Account",
                  style: TextStyle(fontSize: 16, color: AppColors.black),
                ),
                const SizedBox(height: 40),

                AuthToggleBar(
                  isSignIn: true,
                  onToggle: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpPage()),
                    );
                  },
                ),
                const SizedBox(height: 30),

                /// Email
                CustomTextField(
                  hint: "Enter Email",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  nextFocus: _passFocus,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@")) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                /// Password
                CustomTextField(
                  hint: "Password",
                  prefixIcon: Icons.lock_outline,
                  controller: _passController,
                  focusNode: _passFocus,
                  obscure: _obscure,
                  textInputAction: TextInputAction.done,
                  suffixIcon: _obscure ? Icons.visibility_off : Icons.visibility,
                  onSuffixPressed: () => setState(() => _obscure = !_obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password is required";
                    if (v.length < 6) return "Minimum 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 5),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                    ),
                    child: Text(
                      "Forget Password?",
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                /// Button
                PrimaryButton(
                  text: "Sign In",
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // 1. تسجيل الدخول
                      await AppStateManager.setLoggedIn();

                      // 2. الانتقال للصفحة الرئيسية وإزالة كل الصفحات السابقة
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomePage()),
                            (route) => false,
                      );
                    }
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  children: const [
                    Expanded(
                        child: Divider(
                          color: AppColors.primary,
                          thickness: 1,
                          endIndent: 10,
                        )),
                    Text(
                      "OR",
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                        child: Divider(
                          color: AppColors.primary,
                          thickness: 1,
                          indent: 10,
                        )),
                  ],
                ),
                const SizedBox(height: 20),

                const SocialButtons(),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't Have An Account? "),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
