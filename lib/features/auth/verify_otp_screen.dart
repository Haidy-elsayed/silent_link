
/**
import 'package:flutter/material.dart';
//import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../core/constants/app_colors.dart';
//import 'create_new_password_page.dart';
import 'create_new_password_screen.dart';
import 'service/auth_service.dart'; // 👈 IMPORTANT

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((e) => e.text).join();

  bool _isValidOtp(String otp) {
    return otp.length == 6 && RegExp(r'^[0-9]+$').hasMatch(otp);
  }

  Future<void> _verifyOtp() async {
    if (!_isValidOtp(_otpCode)) {
      setState(() {
        _errorMessage = "Enter valid 6-digit OTP";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthServices.verifyOtp(
        email: widget.email,
        otp: _otpCode.trim(),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateNewPasswordScreen(
            email: widget.email,
            otp: _otpCode,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = "OTP verification failed";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      await AuthServices.resendOtp(
        email: widget.email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP resent successfully")),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to resend OTP"),
          backgroundColor: Colors.red,
        ),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Code sent to ${widget.email}",
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),

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

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                      (index) => OtpInputWidget(
                    controller: _controllers[index],
                    autoFocus: index == 0,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              PrimaryButton(
                text: _isLoading ? "Verifying..." : "Verify",
                onPressed: _isLoading ? null : _verifyOtp,
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Didn't receive code? "),
                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      "Resend",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
**/
import 'package:flutter/material.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/otp_input.dart';
import '../../core/constants/app_colors.dart';
import 'create_new_password_screen.dart';
import 'service/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() =>
      _VerifyOtpScreenState();
}

class _VerifyOtpScreenState
    extends State<VerifyOtpScreen> {

  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String get _otpCode =>
      _controllers.map((e) => e.text).join();

  bool _isValidOtp(String otp) {
    return otp.length == 6 &&
        RegExp(r'^[0-9]+$').hasMatch(otp);
  }

  Future<void> _verifyOtp() async {
    if (!_isValidOtp(_otpCode)) {
      setState(() {
        _errorMessage = "Enter valid 6-digit OTP";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthServices.verifyOtp(
        email: widget.email,
        otp: _otpCode.trim(),
      );

      if (!mounted) return;

      final resetToken = result["resetToken"];

      if (resetToken == null) {
        setState(() {
          _errorMessage =
          "Invalid server response";
        });
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CreateNewPasswordScreen(
                email: widget.email,
                otp: _otpCode,
                resetToken: resetToken,
              ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      setState(() {
        _errorMessage = e
            .toString()
            .replaceAll("Exception: ", "");
      });

    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    try {
      await AuthServices.resendOtp(
        email: widget.email,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
              "OTP resent successfully"),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text("Failed to resend OTP"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor:
        AppColors.background,
        elevation: 0,
        leading: const BackButton(
          color: AppColors.primary,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(20),

          child: Column(
            children: [

              const SizedBox(height: 20),

              const Text(
                "Verify OTP",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Code sent to ${widget.email}",
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(
                      12),
                  margin:
                  const EdgeInsets.only(
                      bottom: 15),
                  decoration: BoxDecoration(
                    color:
                    Colors.red.shade50,
                    borderRadius:
                    BorderRadius.circular(
                        10),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              /// OTP FIELDS
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceEvenly,
                children: List.generate(
                  6,
                      (index) => OtpInputWidget(
                    controller:
                    _controllers[index],
                    autoFocus:
                    index == 0,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              /// VERIFY BUTTON
              PrimaryButton(
                text: _isLoading
                    ? "Verifying..."
                    : "Verify",
                onPressed:
                _isLoading
                    ? null
                    : _verifyOtp,
              ),

              const SizedBox(height: 30),

              /// RESEND
              Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  const Text(
                      "Didn't receive code? "),

                  GestureDetector(
                    onTap: _resendOtp,
                    child: const Text(
                      "Resend",
                      style: TextStyle(
                        color:
                        AppColors.primary,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}