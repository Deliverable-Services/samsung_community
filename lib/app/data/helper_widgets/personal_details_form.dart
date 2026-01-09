import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'reusable_form.dart';

class PersonalDetailsForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController birthdayController;
  final TextEditingController emailController;
  final TextEditingController cityController;

  final ValueNotifier<String?> selectedGender;
  final ValueNotifier<String?> selectedDeviceModel;

  final String saveButtonText;

  final Future<void> Function(Map<String, dynamic> formData) onSave;

  final bool isLoading;

  final EdgeInsetsGeometry? padding;

  final bool hideSaveButton;

  /// Optional callback for field blur events (key, value)
  final void Function(String key, dynamic value)? onFieldBlur;

  const PersonalDetailsForm({
    super.key,
    required this.fullNameController,
    required this.birthdayController,
    required this.emailController,
    required this.cityController,
    required this.selectedGender,
    required this.selectedDeviceModel,
    required this.saveButtonText,
    required this.onSave,
    this.isLoading = false,
    this.padding,
    this.hideSaveButton = false,
    this.onFieldBlur,
  });

  @override
  Widget build(BuildContext context) {
    final fields = <FormFieldConfig>[
      FormFieldConfig(
        key: 'fullName',
        type: FormFieldType.text,
        label: 'fullName'.tr,
        placeholder: 'type'.tr,
        textController: fullNameController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'fullName'.tr + ' is_required'.tr;
          }
          return null;
        },
        spacing: 26.h,
        onBlur: onFieldBlur != null
            ? () => onFieldBlur!('fullName', fullNameController.text)
            : null,
      ),
      FormFieldConfig(
        key: 'birthday',
        type: FormFieldType.date,
        label: 'birthday'.tr,
        placeholder: 'type'.tr,
        textController: birthdayController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'birthday'.tr + ' is_required'.tr;
          }
          return null;
        },
        spacing: 26.h,
        onBlur: onFieldBlur != null
            ? () => onFieldBlur!('birthday', birthdayController.text)
            : null,
      ),
      FormFieldConfig(
        key: 'email',
        type: FormFieldType.email,
        label: 'emailAddress'.tr,
        placeholder: 'type'.tr,
        textController: emailController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'emailAddress'.tr + ' is_required'.tr;
          }
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          );
          if (!emailRegex.hasMatch(value.trim())) {
            return 'Please enter a valid email address';
          }
          return null;
        },
        spacing: 26.h,
        onBlur: onFieldBlur != null
            ? () => onFieldBlur!('email', emailController.text)
            : null,
      ),
      FormFieldConfig(
        key: 'city',
        type: FormFieldType.text,
        label: 'city'.tr,
        placeholder: 'type'.tr,
        textController: cityController,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'city'.tr + ' is_required'.tr;
          }
          return null;
        },
        spacing: 26.h,
        onBlur: onFieldBlur != null
            ? () => onFieldBlur!('city', cityController.text)
            : null,
      ),
      FormFieldConfig(
        key: 'gender',
        type: FormFieldType.gender,
        label: 'gender'.tr,
        dropdownNotifier: selectedGender,
        spacing: 26.h,
      ),
    ];

    return ReusableForm(
      fields: fields,
      saveButtonText: saveButtonText,
      isLoading: isLoading,
      padding: padding,
      hideSaveButton: hideSaveButton,
      saveButtonSpacing: 60.h,
      onSave: onSave,
    );
  }
}
