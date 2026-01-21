
import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixPressed;
  final bool obscure;

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixPressed,
    this.obscure = false,
    this.controller,
    this.validator,
    this.focusNode,
    this.nextFocus,
    this.textInputAction,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(0.7),
             // لون الشادو
              blurRadius: 2,
              // مدى التمويه
              spreadRadius: 0,
              offset: const Offset(0, 5), // إزاحة الشادو
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon, color: AppColors.black),
            suffixIcon: suffixIcon == null
                ? null
                : IconButton(
              icon: Icon(suffixIcon, color: AppColors.black),
              onPressed: onSuffixPressed,
            ),
            filled: true,
            fillColor: Colors.transparent, // خليها شفاف عشان يظهر الشادو
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: _border(),
            enabledBorder: _border(),
            focusedBorder: _border(width: 1.5),
            errorBorder: _border(color: Colors.red),
            focusedErrorBorder: _border(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: color ?? AppColors.primary,
        width: width,
      ),
    );
  }
}