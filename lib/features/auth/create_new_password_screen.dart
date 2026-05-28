
/**
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../core/constants/app_colors.dart';
import 'service/auth_service.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  final String resetToken;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
    required this.resetToken,
  });

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends State<CreateNewPasswordScreen> {

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
        resetToken: widget.resetToken,
        password: _newPassController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SignInScreen(),
        ),
            (route) => false,
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceAll("Exception: ", "");
      });

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
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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

                /// NEW PASSWORD
                CustomTextField(
                  hint: "New Password",
                  prefixIcon: Icons.lock_outline,
                  obscure: newPass,
                  controller: _newPassController,
                  focusNode: _newPassFocus,
                  textInputAction: TextInputAction.next,
                  suffixIcon: newPass
                      ? Icons.visibility_off
                      : Icons.visibility,
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

                /// CONFIRM PASSWORD
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

                /// BUTTON
                PrimaryButton(
                  text: _isLoading
                      ? "Loading..."
                      : "Continue",
                  onPressed:
                  _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
    **/

import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../core/constants/app_colors.dart';
import 'service/auth_service.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  final String resetToken;

  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
    required this.resetToken,
  });

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends State<CreateNewPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

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
        resetToken: widget.resetToken,
        password: _newPassController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password changed successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInScreen()),
            (route) => false,
      );

    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceAll("Exception: ", "");
      });
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
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

                /// NEW PASSWORD
                CustomTextField(
                  hint: "New Password",
                  prefixIcon: Icons.lock_outline,
                  obscure: _obscureNew,
                  controller: _newPassController,
                  focusNode: _newPassFocus,
                  textInputAction: TextInputAction.next,
                  suffixIcon: _obscureNew
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixPressed: () =>
                      setState(() => _obscureNew = !_obscureNew),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Password required";
                    }
                    if (v.length < 6) {
                      return "Minimum 6 characters";
                    }
                    return null;
                  },
                  nextFocus: _confirmPassFocus,
                ),

                const SizedBox(height: 20),

                /// CONFIRM PASSWORD
                CustomTextField(
                  hint: "Confirm Password",
                  prefixIcon: Icons.lock_outline,
                  obscure: _obscureConfirm,
                  controller: _confirmPassController,
                  focusNode: _confirmPassFocus,
                  textInputAction: TextInputAction.done,
                  suffixIcon: _obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
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

                /// BUTTON
                PrimaryButton(
                  text: _isLoading ? "Loading..." : "Continue",
                  onPressed: _isLoading ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}