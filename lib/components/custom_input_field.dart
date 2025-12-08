import 'package:flutter/material.dart';
import 'package:samsung_community/constants/colors.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.placeholder,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Rubik',
            color: AppColors.white,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 350,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 48,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.inputGradientStart,
                  AppColors.inputGradientEnd,
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.inputShadow,
                  offset: Offset(2, -2),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: const TextStyle(
                fontFamily: 'Rubik',
                color: AppColors.white,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: placeholder,
                hintStyle: const TextStyle(
                  fontFamily: 'Rubik',
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}


