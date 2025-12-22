import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'reusable_form.dart';

/// Reusable Personal Details Form
/// Excludes top navigation - that should be handled by the parent view
class PersonalDetailsForm extends StatelessWidget {
  /// Text controllers for form fields
  final TextEditingController fullNameController;
  final TextEditingController birthdayController;
  final TextEditingController emailController;
  final TextEditingController cityController;

  /// Value notifiers for dropdowns
  final ValueNotifier<String?> selectedGender;
  final ValueNotifier<String?> selectedDeviceModel;

  /// Text to display on the save button
  final String saveButtonText;

  /// Callback function that receives the form data when save is clicked
  /// The Map contains field keys and their values
  final Future<void> Function(Map<String, dynamic> formData) onSave;

  /// Optional loading state - if true, button will be disabled
  final bool isLoading;

  /// Optional padding around the form
  final EdgeInsetsGeometry? padding;

  /// Optional - hide save button (for auto-save forms)
  final bool hideSaveButton;

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
  });

  @override
  Widget build(BuildContext context) {
    return ReusableForm(
      fields: [
        FormFieldConfig(
          key: 'fullName',
          type: FormFieldType.text,
          label: 'fullName'.tr,
          placeholder: 'type'.tr,
          textController: fullNameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'fullName'.tr + ' is required';
            }
            return null;
          },
          spacing: 20.h,
        ),
        FormFieldConfig(
          key: 'birthday',
          type: FormFieldType.date,
          label: 'birthday'.tr,
          placeholder: 'type'.tr,
          textController: birthdayController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'birthday'.tr + ' is required';
            }
            return null;
          },
          spacing: 20.h,
        ),
        FormFieldConfig(
          key: 'email',
          type: FormFieldType.email,
          label: 'emailAddress'.tr,
          placeholder: 'type'.tr,
          textController: emailController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'emailAddress'.tr + ' is required';
            }
            final emailRegex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            if (!emailRegex.hasMatch(value.trim())) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          spacing: 20.h,
        ),
        FormFieldConfig(
          key: 'city',
          type: FormFieldType.text,
          label: 'city'.tr,
          placeholder: 'type'.tr,
          textController: cityController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'city'.tr + ' is required';
            }
            return null;
          },
          spacing: 20.h,
        ),
        FormFieldConfig(
          key: 'gender',
          type: FormFieldType.gender,
          label: 'gender'.tr,
          dropdownNotifier: selectedGender,
          spacing: 20.h,
        ),
        FormFieldConfig(
          key: 'deviceModel',
          type: FormFieldType.deviceModel,
          label: 'deviceModel'.tr,
          dropdownNotifier: selectedDeviceModel,
          spacing: 20.h,
        ),
      ],
      saveButtonText: saveButtonText,
      isLoading: isLoading,
      padding: padding,
      hideSaveButton: hideSaveButton,
      onSave: onSave,
    );
  }
}

