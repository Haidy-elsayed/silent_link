
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
      // إذا كل حاجة تمام، نرجع على Sign In
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Create New Password",
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                "Your new password must be different from your previously used password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.black),
              ),
              const SizedBox(height: 30),

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
              const SizedBox(height: 30),

              /// Continue Button
              PrimaryButton(
                text: "Continue",
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


