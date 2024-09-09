import 'package:flutter/material.dart';

class GlobalTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final InputBorder? border;
  final InputBorder? errorBorder;

  const GlobalTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.onFieldSubmitted,
    this.onChanged,
    this.suffixIcon,
    this.border,
    this.errorBorder,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: border ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        errorBorder: errorBorder ??
            OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10),
            ),
        enabledBorder: border ??
            OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
