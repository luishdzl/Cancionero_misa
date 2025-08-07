import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final bool expands;
  final int? maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.validator,
    this.expands = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.obscureText = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        alignLabelWithHint: true,
      ),
      validator: validator,
      expands: expands,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );
  }
}