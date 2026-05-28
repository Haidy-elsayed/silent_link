
/**
import 'package:flutter/material.dart';
import 'package:silent_link/features/auth/presentation/widgets/social_buttons.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle_bar.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
import 'service/auth_service.dart'; // 👈 IMPORTANT

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _dobController = TextEditingController();

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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
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

                AuthToggleBar(
                  isSignIn: false,
                  onToggle: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                ),

                const SizedBox(height: 25),

                CustomTextField(
                  hint: "First Name",
                  prefixIcon: Icons.person_outline,
                  controller: _firstNameController,
                  validator: (v) => v!.isEmpty ? "First name is required" : null,
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Email is required";
                    if (!v.contains("@") || !v.contains(".")) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Phone Number",
                  prefixIcon: Icons.phone_outlined,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Phone is required";
                    if (v.length < 10) return "Enter valid phone";
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Create Password",
                  prefixIcon: Icons.lock_outline,
                  controller: _passController,
                  obscure: _obscure,
                  suffixIcon: _obscure ? Icons.visibility_off : Icons.visibility,
                  onSuffixPressed: () => setState(() => _obscure = !_obscure),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Password required";
                    if (v.length < 6) return "Min 6 characters";
                    return null;
                  },
                ),

                CustomTextField(
                  hint: "Confirm Password",
                  prefixIcon: Icons.lock_reset,
                  controller: _confirmPassController,
                  obscure: _obscureConfirm,
                  suffixIcon: _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  onSuffixPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Confirm your password";
                    if (v != _passController.text) return "Passwords don't match";
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                _buildFieldLabel("Date Of Birth"),
                CustomTextField(
                  hint: "YYYY-MM-DD",
                  controller: _dobController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_outlined,
                  validator: (v) => v!.isEmpty ? "Please select birth date" : null,
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

                _buildFieldLabel("Country"),
                _buildDropdownField(
                  hint: "Select Country",
                  value: _selectedCountry,
                  items: const ["Egypt","Libya","Tunisia","Algeria","Morocco","Sudan","Mauritania"],
                  onChanged: (val) => setState(() => _selectedCountry = val),
                  validator: (val) => val == null ? "Please select your country" : null,
                ),

                const SizedBox(height: 15),

                _buildFieldLabel("Gender"),
                _buildDropdownField(
                  hint: "Select Gender",
                  value: _selectedGender,
                  items: const ["Male", "Female"],
                  onChanged: (val) => setState(() => _selectedGender = val),
                  validator: (val) => val == null ? "Please select your gender" : null,
                ),

                const SizedBox(height: 35),

                PrimaryButton(
                  text: _isLoading ? "Loading..." : "Sign Up",
                  onPressed: _isLoading ? null : _handleSignUp,
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

  /// 🔥 CLEAN SIGN UP USING SERVICE
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthServices.signUp(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passController.text.trim(),
        dob: _dobController.text,
        country: _selectedCountry,
        gender: _selectedGender,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );

    } catch (e) {
      setState(() {
        _errorMessage = "Something went wrong, try again";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildHeader() {
    return Column(
      children: const [
        Text("Create Your New Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
        SizedBox(height: 10),
        Text("Sign Up With The Following Method",
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
     import '../../navigation/main_navigation_screen.dart';
   filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(child: Divider()),
            Text("OR"),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 20),
        const SocialButtons(),
        const SizedBox(height: 20),
      ],
    );
  }
}
**/

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_link/features/auth/presentation/widgets/social_buttons.dart';
import 'package:silent_link/features/auth/sign_in_screen.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/toggle_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/app_statement_manager.dart';
import '../../navigation/main_navigation_screen.dart';
import '../home/home_screen.dart';
import 'service/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscure = true;
  bool _obscureConfirm = true;

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  final _firstNameController = TextEditingController();

  final _lastNameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _passController = TextEditingController();

  final _confirmPassController = TextEditingController();

  final _dobController = TextEditingController();

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

  /// SIGN UP
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthServices.signUp(
        firstName: _firstNameController.text.trim(),

        lastName: _lastNameController.text.trim(),

        email: _emailController.text.trim(),

        phone: _phoneController.text.trim(),

        password: _passController.text.trim(),

        dob: _dobController.text.trim(),

        country: _selectedCountry,

        gender: _selectedGender,
      );



      // 🟡 حفظ الـ country عشان الـ map تبدأ عليها — شيلي السطرين دول لو مش عايزاه
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_country', (_selectedCountry ?? '').toLowerCase());



      await AppStateManager.setLoggedIn();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"] ?? "Account created successfully"),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
        leading: const BackButton(color: AppColors.primary),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

        child: SingleChildScrollView(
          child: Form(
            key: _formKey,

            child: Column(
              children: [
                _buildHeader(),

                const SizedBox(height: 30),

                /// ERROR
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

                /// TOGGLE
                AuthToggleBar(
                  isSignIn: false,

                  onToggle: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                ),

                const SizedBox(height: 25),

                /// FIRST NAME
                CustomTextField(
                  hint: "First Name",

                  prefixIcon: Icons.person_outline,

                  controller: _firstNameController,

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "First name is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// LAST NAME
                CustomTextField(
                  hint: "Last Name",

                  prefixIcon: Icons.person_outline,

                  controller: _lastNameController,

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Last name is required";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// EMAIL
                CustomTextField(
                  hint: "Enter Email",

                  prefixIcon: Icons.email_outlined,

                  controller: _emailController,

                  keyboardType: TextInputType.emailAddress,

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Email is required";
                    }

                    if (!v.contains("@") || !v.contains(".")) {
                      return "Enter valid email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// PHONE
                CustomTextField(
                  hint: "Phone Number",

                  prefixIcon: Icons.phone_outlined,

                  controller: _phoneController,

                  keyboardType: TextInputType.phone,

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Phone is required";
                    }

                    if (v.length < 10) {
                      return "Enter valid phone";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// PASSWORD
                CustomTextField(
                  hint: "Create Password",

                  prefixIcon: Icons.lock_outline,

                  controller: _passController,

                  obscure: _obscure,

                  suffixIcon: _obscure
                      ? Icons.visibility_off
                      : Icons.visibility,

                  onSuffixPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Password required";
                    }

                    if (v.length < 6) {
                      return "Minimum 6 characters";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 10),

                /// CONFIRM PASSWORD
                CustomTextField(
                  hint: "Confirm Password",

                  prefixIcon: Icons.lock_reset,

                  controller: _confirmPassController,

                  obscure: _obscureConfirm,

                  suffixIcon: _obscureConfirm
                      ? Icons.visibility_off
                      : Icons.visibility,

                  onSuffixPressed: () {
                    setState(() {
                      _obscureConfirm = !_obscureConfirm;
                    });
                  },

                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Confirm your password";
                    }

                    if (v != _passController.text) {
                      return "Passwords don't match";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 15),

                /// DATE OF BIRTH
                CustomTextField(
                  hint: "YYYY-MM-DD",
                  controller: _dobController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Please select birth date";
                    }
                    return null;
                  },
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );

                    if (picked != null) {
                      _dobController.text = picked.toIso8601String().split(
                        "T",
                      )[0];
                    }
                  },
                ),

                const SizedBox(height: 15),

                /// COUNTRY
                _buildFieldLabel("Country"),
                _buildDropdownField(
                  hint: "Select Country",
                  value: _selectedCountry,
                  items: const [
                    "Egypt",
                    "Libya",
                    "Tunisia",
                    "Algeria",
                    "Morocco",
                    "Sudan",
                    "Mauritania",
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCountry = val;
                    });
                  },
                  validator: (val) {
                    if (val == null) {
                      return "Please select your country";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                /// GENDER
                _buildFieldLabel("Gender"),
                _buildDropdownField(
                  hint: "Select Gender",
                  value: _selectedGender,
                  items: const ["Male", "Female"],
                  onChanged: (val) {
                    setState(() {
                      _selectedGender = val;
                    });
                  },
                  validator: (val) {
                    if (val == null) {
                      return "Please select your gender";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                /// SIGN UP BUTTON
                PrimaryButton(
                  text: _isLoading ? "Loading..." : "Sign Up",
                  onPressed: _isLoading ? null : _handleSignUp,
                ),

                const SizedBox(height: 20),

                /// FOOTER
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Text(" OR "),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),

                const SocialButtons(),

                const SizedBox(height: 20),

                /// GO TO SIGN IN
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SignInScreen(),
                          ),
                        );
                      },
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
            ),
          ),
        ),
      ),
    );
  }

  /// HEADER
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

  /// LABEL
  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 8, left: 4),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// DROPDOWN
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
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
