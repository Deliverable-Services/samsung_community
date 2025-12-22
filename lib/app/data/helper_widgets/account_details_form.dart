import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'reusable_form.dart';

/// Reusable Account Details Form
/// Excludes top navigation - that should be handled by the parent view
class AccountDetailsForm extends StatelessWidget {
  /// Text controllers for form fields
  final TextEditingController socialMediaController;
  final TextEditingController professionController;
  final TextEditingController bioController;
  final TextEditingController classController;

  /// Value notifiers for dropdowns and radio
  final ValueNotifier<String?> selectedCollege;
  final ValueNotifier<String> selectedStudent;

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

  /// Optional callback for field blur events (key, value)
  final void Function(String key, dynamic value)? onFieldBlur;

  const AccountDetailsForm({
    super.key,
    required this.socialMediaController,
    required this.professionController,
    required this.bioController,
    required this.classController,
    required this.selectedCollege,
    required this.selectedStudent,
    required this.saveButtonText,
    required this.onSave,
    this.isLoading = false,
    this.padding,
    this.hideSaveButton = false,
    this.onFieldBlur,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedStudent,
      builder: (context, studentValue, _) {
        return ReusableForm(
          fields: [
            FormFieldConfig(
              key: 'socialMedia',
              type: FormFieldType.text,
              label: 'social_media'.tr,
              placeholder: 'type'.tr,
              textController: socialMediaController,
              spacing: 30.h,
              onBlur: onFieldBlur != null
                  ? () =>
                        onFieldBlur!('socialMedia', socialMediaController.text)
                  : null,
            ),
            FormFieldConfig(
              key: 'profession',
              type: FormFieldType.text,
              label: 'profession'.tr,
              placeholder: 'type'.tr,
              textController: professionController,
              spacing: 30.h,
              onBlur: onFieldBlur != null
                  ? () => onFieldBlur!('profession', professionController.text)
                  : null,
            ),
            FormFieldConfig(
              key: 'bio',
              type: FormFieldType.multiline,
              label: 'bio'.tr,
              placeholder: 'type'.tr,
              textController: bioController,
              maxLines: 5,
              spacing: 30.h,
              onBlur: onFieldBlur != null
                  ? () => onFieldBlur!('bio', bioController.text)
                  : null,
            ),
            FormFieldConfig(
              key: 'isStudent',
              type: FormFieldType.radio,
              label: "are_you_student".tr,
              radioNotifier: selectedStudent,
              spacing: 20.h,
            ),
            FormFieldConfig(
              key: 'college',
              type: FormFieldType.college,
              label: "choose_college".tr,
              dropdownNotifier: selectedCollege,
              spacing: 30.h,
              condition: () => studentValue == 'yes',
            ),
            FormFieldConfig(
              key: 'className',
              type: FormFieldType.text,
              label: 'name_of_class'.tr,
              placeholder: 'type'.tr,
              textController: classController,
              readOnlyBuilder: () => studentValue != 'yes',
              spacing: 30.h,
              condition: () => studentValue == 'yes',
              onBlur: onFieldBlur != null
                  ? () => onFieldBlur!('className', classController.text)
                  : null,
            ),
          ],
          saveButtonText: saveButtonText,
          isLoading: isLoading,
          padding: padding,
          hideSaveButton: hideSaveButton,
          onSave: onSave,
        );
      },
    );
  }
}
