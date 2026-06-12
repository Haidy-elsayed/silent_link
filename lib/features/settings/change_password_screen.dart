import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:silent_link/features/auth/forgot_password_screen.dart';
import 'package:silent_link/features/auth/widgets/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSave(AuthProvider authProv) async {
    String currentPass = _currentPasswordController.text;
    String newPass = _newPasswordController.text;
    String confirmPass = _confirmPasswordController.text;

    
    if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar("Please fill in all fields", Colors.red);
      return;
    }

   
    if (newPass.length < 6) {
      _showSnackBar("New password must be at least 6 characters", Colors.red);
      return;
    }

    if (currentPass == newPass) {
      _showSnackBar("New password must be different from current password", Colors.red);
      return;
    }

    
    if (newPass != confirmPass) {
      _showSnackBar("Passwords do not match", Colors.red);
      return;
    }

  
    bool isSuccess = await authProv.changePassword(
      currentPassword: currentPass,
      newPassword: newPass,
    );

    if (isSuccess) {
      _showSnackBar("Password changed successfully!", AppColors.primary);
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      _showSnackBar("Failed to change password. Please try again.", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    final authProv = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Change Password",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Enter At Least 6 Characters",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),

            _buildPasswordField("Enter Your Current Password", _currentPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Enter Your New Password", _newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Confirm Password", _confirmPasswordController),
            
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                );
              },
              child: const Text(
                "Forget Password ?",
                style: TextStyle(
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            const Spacer(),

          
            Consumer<AuthProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () => _handleSave(provider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
                    ),
                    child: provider.isLoading 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Save", 
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}