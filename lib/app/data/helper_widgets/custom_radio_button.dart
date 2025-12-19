import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../constants/app_colors.dart';

class CustomRadioButton extends StatelessWidget {
  final ValueNotifier<String> selectedValue;

  const CustomRadioButton(this.selectedValue, {super.key});

  @override
  Widget build(BuildContext context) {
    return RadioGroup<String>(
      groupValue: selectedValue.value,
      onChanged: (value) => selectedValue.value = value ?? 'yes',
      child: Row(
        children: [
          Row(
            children: [
              Transform.scale(
                scale: 1.3,
                child: Radio(
                  value: "yes",
                  fillColor: WidgetStateProperty.all(
                    AppColors.linkBlue,
                  ), // blue
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "yes".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(width: 40),
          Row(
            children: [
              Transform.scale(
                scale: 1.3,
                child: Radio(
                  value: "no",
                  fillColor: WidgetStateProperty.all(
                    AppColors.linkBlue,
                  ), // dim grey outline
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "no".tr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
