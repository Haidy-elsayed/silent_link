import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/presentation/widgets/social_buttons.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';
import 'package:silent_link/navigation/main_navigation_screen.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle_bar.dart';
import '../../core/storage/app_statement_manager.dart';
import '../home/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 1. إدارة الحالة (UI Logic)
  bool _obscure = true;
  bool _obscureConfirm = true;
  final _formKey = GlobalKey<FormState>();

  // 2. التحكم في الحقول (Controllers)
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _dobController = TextEditingController();

  // 3. تخزين القيم المختارة (Data)
  String? _selectedCountry;
  String? _selectedGender;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _dobController.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                AuthToggleBar(
                  isSignIn: false,
                  onToggle: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                  ),
                ),
                const SizedBox(height: 25),

                // --- الحقول النصية (تستخدم الـ CustomTextField الخاص بك) ---
                CustomTextField(
                  hint: "First Name",
                  prefixIcon: Icons.person_outline,
                  controller: _firstNameController,
                  validator: (v) =>
                      v!.isEmpty ? "First name is required" : null,
                ),
                CustomTextField(
                  hint: "Last Name",
                  prefixIcon: Icons.person_outline,
                  controller: _lastNameController,
                  validator: (v) => v!.isEmpty ? "Last name is required" : null,
                ),
                CustomTextField(
                  hint: "Enter Email",
                  prefixIcon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains("@")) ? "Invalid email" : null,
                ),
                CustomTextField(
                  hint: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Phone is required" : null,
                ),
                CustomTextField(
                  hint: "Create Password",
                  prefixIcon: Icons.lock_outline,
                  controller: _passController,
                  obscure: _obscure,
                  suffixIcon: _obscure
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixPressed: () => setState(() => _obscure = !_obscure),
                  validator: (v) =>
                      v!.length < 6 ? "Minimum 6 characters" : null,
                ),
                CustomTextField(
                  hint: "Confirm Password",
                  prefixIcon: Icons.lock_reset,
                  controller: _confirmPassController,
                  obscure: _obscureConfirm,
                  suffixIcon: _obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) => v != _passController.text
                      ? "Passwords don't match"
                      : null,
                ),

                const SizedBox(height: 20),

                _buildFieldLabel("Date Of Birth"),
                CustomTextField(
                  hint: "YYYY-MM-DD",
                  controller: _dobController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_outlined,
                  validator: (v) =>
                      v!.isEmpty ? "Please select birth date" : null,
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dobController.text = "${picked.toLocal()}".split(' ')[0];
                    }
                  },
                ),

                // --- حقول الاختيار (Dropdowns) المنظمة ---
                _buildFieldLabel("Country"),
                _buildDropdownField(
                  hint: "Select Country",
                  value: _selectedCountry,
                  items: [
                    "Egypt",
                    "Libya",
                    "Tunisia",
                    "Algeria",
                    "Morocco",
                    "Sudan",
                    "Mauritania",
                  ],
                  onChanged: (val) => setState(() => _selectedCountry = val),
                  validator: (val) =>
                      val == null ? "Please select your country" : null,
                ),

                const SizedBox(height: 15),

                _buildFieldLabel("Gender"),
                _buildDropdownField(
                  hint: "Select Gender",
                  value: _selectedGender,
                  items: ["Male", "Female"],
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) =>
                      val == null ? "Please select your gender" : null,
                ),

                const SizedBox(height: 35),
                PrimaryButton(
                  text: "Sign Up",
                  onPressed: () => _handleSignUp(),
                ),
                const SizedBox(height: 20),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      await AppStateManager.setLoggedIn();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text(
          "Create Your New Account",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Sign Up With The Following Method",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider(color: AppColors.primary, endIndent: 10)),
            Text("OR", style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(child: Divider(color: AppColors.primary, indent: 10)),
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
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignInPage()),
              ),
              child: const Text(
                "Sign In",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
