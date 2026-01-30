import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
      ),
    );
  }
}
