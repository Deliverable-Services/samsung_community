import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constants/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/college_options.dart';
import '../constants/device_model_options.dart';
import '../constants/gender_options.dart';
import 'custom_dropdown.dart';
import 'custom_radio_button.dart';
import 'custom_text.dart';
import 'custom_text_field.dart';

/// Reusable form component that can be used for account details and personal details
/// Excludes top navigation - that should be handled by the parent view
class ReusableForm extends StatefulWidget {
  /// List of form field configurations
  final List<FormFieldConfig> fields;

  /// Text to display on the save button
  final String saveButtonText;

  /// Callback function that receives the form data when save is clicked
  /// The Map contains field keys and their values
  final Future<void> Function(Map<String, dynamic> formData) onSave;

  /// Optional loading state - if true, button will be disabled
  final bool isLoading;

  /// Optional padding around the form
  final EdgeInsetsGeometry? padding;

  /// Optional scrollable - defaults to true
  final bool isScrollable;

  /// Optional - hide save button (for auto-save forms)
  final bool hideSaveButton;

  const ReusableForm({
    super.key,
    required this.fields,
    required this.saveButtonText,
    required this.onSave,
    this.isLoading = false,
    this.padding,
    this.isScrollable = true,
    this.hideSaveButton = false,
  });

  @override
  State<ReusableForm> createState() => _ReusableFormState();
}

class _ReusableFormState extends State<ReusableForm> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, ValueNotifier<String?>> _dropdownNotifiers = {};
  final Map<String, ValueNotifier<String>> _radioNotifiers = {};
  final Map<String, DateTime?> _dateValues = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.fields) {
      switch (field.type) {
        case FormFieldType.text:
        case FormFieldType.email:
        case FormFieldType.multiline:
        case FormFieldType.date:
          // Use external controller if provided, otherwise create one
          if (field.textController != null) {
            _controllers[field.key] = field.textController!;
          } else {
            _controllers[field.key] = TextEditingController(
              text: field.initialValue,
            );
          }
          if (field.type == FormFieldType.date && field.initialValue != null) {
            try {
              _dateValues[field.key] = DateTime.parse(field.initialValue!);
            } catch (e) {
              // Invalid date format, ignore
            }
          }
          break;
        case FormFieldType.dropdown:
        case FormFieldType.gender:
        case FormFieldType.deviceModel:
        case FormFieldType.college:
          // Use external notifier if provided, otherwise create one
          if (field.dropdownNotifier != null) {
            _dropdownNotifiers[field.key] = field.dropdownNotifier!;
          } else {
            _dropdownNotifiers[field.key] = ValueNotifier<String?>(
              field.initialValue,
            );
          }
          break;
        case FormFieldType.radio:
          // Use external notifier if provided, otherwise create one
          if (field.radioNotifier != null) {
            _radioNotifiers[field.key] = field.radioNotifier!;
          } else {
            _radioNotifiers[field.key] = ValueNotifier<String>(
              field.initialValue ?? 'yes',
            );
          }
          break;
        case FormFieldType.label:
          // No controller needed for labels
          break;
      }
    }
  }

  @override
  void dispose() {
    // Only dispose controllers/notifiers that we created (not external ones)
    for (final field in widget.fields) {
      switch (field.type) {
        case FormFieldType.text:
        case FormFieldType.email:
        case FormFieldType.multiline:
        case FormFieldType.date:
          // Only dispose if we created it (not external)
          if (field.textController == null) {
            _controllers[field.key]?.dispose();
          }
          break;
        case FormFieldType.dropdown:
        case FormFieldType.gender:
        case FormFieldType.deviceModel:
        case FormFieldType.college:
          // Only dispose if we created it (not external)
          if (field.dropdownNotifier == null) {
            _dropdownNotifiers[field.key]?.dispose();
          }
          break;
        case FormFieldType.radio:
          // Only dispose if we created it (not external)
          if (field.radioNotifier == null) {
            _radioNotifiers[field.key]?.dispose();
          }
          break;
        case FormFieldType.label:
          break;
      }
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formData = <String, dynamic>{};

    // Collect text field values
    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        formData[entry.key] = value;
      }
    }

    // Collect dropdown values
    for (final entry in _dropdownNotifiers.entries) {
      final value = entry.value.value;
      if (value != null && value.isNotEmpty) {
        formData[entry.key] = value;
      }
    }

    // Collect radio values
    for (final entry in _radioNotifiers.entries) {
      formData[entry.key] = entry.value.value;
    }

    // Collect date values
    for (final entry in _dateValues.entries) {
      if (entry.value != null) {
        formData[entry.key] = entry.value!.toIso8601String().split('T')[0];
      }
    }

    await widget.onSave(formData);
  }

  Future<void> _selectDate(String fieldKey, String label) async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Try to get current date from controller text or _dateValues
    DateTime? currentDate = _dateValues[fieldKey];
    if (currentDate == null &&
        _controllers[fieldKey]?.text.isNotEmpty == true) {
      try {
        currentDate = DateTime.parse(_controllers[fieldKey]!.text);
      } catch (e) {
        // Invalid date format, use default
      }
    }
    currentDate ??= today.subtract(const Duration(days: 365 * 18));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: today,
      selectableDayPredicate: (DateTime date) {
        final dateOnly = DateTime(date.year, date.month, date.day);
        return dateOnly.isBefore(today.add(const Duration(days: 1)));
      },
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.linkBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black87),
              labelLarge: TextStyle(color: Colors.black87),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Colors.white,
              headerBackgroundColor: AppColors.linkBlue,
              headerForegroundColor: Colors.white,
              dayStyle: const TextStyle(color: Colors.black87),
              weekdayStyle: const TextStyle(color: Colors.black87),
              yearStyle: const TextStyle(color: Colors.black87),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateValues[fieldKey] = picked;
        final year = picked.year.toString();
        final month = picked.month.toString().padLeft(2, '0');
        final day = picked.day.toString().padLeft(2, '0');
        _controllers[fieldKey]?.text = '$year-$month-$day';
      });
    }
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
      case FormFieldType.email:
        return CustomTextField(
          label: field.label,
          controller: _controllers[field.key]!,
          keyboardType: field.type == FormFieldType.email
              ? TextInputType.emailAddress
              : TextInputType.text,
          placeholder: field.placeholder ?? 'type'.tr,
          validator: field.validator,
          readOnly: field.readOnlyBuilder?.call() ?? field.readOnly,
        );

      case FormFieldType.multiline:
        return CustomTextField(
          label: field.label,
          controller: _controllers[field.key]!,
          placeholder: field.placeholder ?? 'type'.tr,
          maxLines: field.maxLines ?? 5,
          validator: field.validator,
        );

      case FormFieldType.date:
        return GestureDetector(
          onTap: () => _selectDate(field.key, field.label),
          child: AbsorbPointer(
            child: CustomTextField(
              label: field.label,
              controller: _controllers[field.key]!,
              keyboardType: TextInputType.datetime,
              placeholder: field.placeholder ?? 'type'.tr,
              readOnly: true,
              validator: field.validator,
            ),
          ),
        );

      case FormFieldType.dropdown:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14.h,
              child: Text(
                field.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 22 / 22,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
            SizedBox(height: 10.h),
            CustomDropDown<String>(
              items: (field.dropdownItems ?? []).map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'] as String,
                  child: Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      letterSpacing: 0,
                      color: AppColors.black,
                      height: 22 / 14,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                );
              }).toList(),
              valueNotifier: _dropdownNotifiers[field.key]!,
              hintText: field.placeholder ?? 'select'.tr,
              onChanged: field.readOnly
                  ? null
                  : (value) {
                      _dropdownNotifiers[field.key]!.value = value;
                    },
            ),
          ],
        );

      case FormFieldType.gender:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14.h,
              child: Text(
                field.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 22 / 22,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
            SizedBox(height: 10.h),
            CustomDropDown<String>(
              items: GenderOptions.options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      letterSpacing: 0,
                      color: AppColors.black,
                      height: 22 / 14,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                );
              }).toList(),
              valueNotifier: _dropdownNotifiers[field.key]!,
              hintText: 'select'.tr,
              onChanged: (String? value) {
                _dropdownNotifiers[field.key]!.value = value;
              },
            ),
          ],
        );

      case FormFieldType.deviceModel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 14.h,
              child: Text(
                field.label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  letterSpacing: 0,
                  color: AppColors.white,
                  height: 22 / 22,
                ),
                textScaler: const TextScaler.linear(1.0),
              ),
            ),
            SizedBox(height: 10.h),
            CustomDropDown<String>(
              items: DeviceModelOptions.options.map((option) {
                return DropdownMenuItem<String>(
                  value: option.id,
                  child: Text(
                    option.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      letterSpacing: 0,
                      color: AppColors.black,
                      height: 22 / 14,
                    ),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                );
              }).toList(),
              valueNotifier: _dropdownNotifiers[field.key]!,
              hintText: 'select'.tr,
              onChanged: (String? value) {
                _dropdownNotifiers[field.key]!.value = value;
              },
            ),
          ],
        );

      case FormFieldType.college:
        return ValueListenableBuilder<String>(
          valueListenable: _radioNotifiers['isStudent'] ?? ValueNotifier('no'),
          builder: (context, studentValue, _) {
            final enabled = studentValue == 'yes';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: enabled ? 1.0 : 0.5,
                  child: SizedBox(
                    height: 14.h,
                    child: Text(
                      field.label,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        letterSpacing: 0,
                        color: AppColors.white,
                        height: 22 / 22,
                      ),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Opacity(
                  opacity: enabled ? 1.0 : 0.5,
                  child: CustomDropDown<String>(
                    items: CollegeOptions.options.map((college) {
                      return DropdownMenuItem<String>(
                        value: college.id,
                        child: Text(
                          college.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            letterSpacing: 0,
                            color: AppColors.black,
                            height: 22 / 14,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      );
                    }).toList(),
                    valueNotifier: _dropdownNotifiers[field.key]!,
                    hintText: 'select'.tr,
                    onChanged: enabled
                        ? (value) {
                            _dropdownNotifiers[field.key]!.value = value;
                          }
                        : null,
                  ),
                ),
              ],
            );
          },
        );

      case FormFieldType.radio:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(field.label),
            SizedBox(height: 10.h),
            CustomRadioButton(_radioNotifiers[field.key]!),
          ],
        );

      case FormFieldType.label:
        return CustomText(field.label);
    }
  }

  Widget _buildConditionalField(FormFieldConfig field) {
    if (field.condition != null && !field.condition!()) {
      return const SizedBox.shrink();
    }
    return _buildField(field);
  }

  @override
  Widget build(BuildContext context) {
    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < widget.fields.length; i++) ...[
            _buildConditionalField(widget.fields[i]),
            if (i < widget.fields.length - 1)
              SizedBox(height: widget.fields[i].spacing ?? 30.h),
          ],
          if (!widget.hideSaveButton) ...[
            SizedBox(height: 30.h),
            AppButton(
              onTap: widget.isLoading ? null : _handleSave,
              text: widget.isLoading ? 'saving'.tr : widget.saveButtonText,
              height: 48.h,
              isEnabled: !widget.isLoading,
            ),
          ],
        ],
      ),
    );

    final content = Padding(
      padding:
          widget.padding ??
          EdgeInsetsGeometry.directional(start: 20.w, end: 20.w, top: 68.h),
      child: formContent,
    );

    if (widget.isScrollable) {
      return SingleChildScrollView(child: content);
    }

    return content;
  }
}

/// Configuration for a form field
class FormFieldConfig {
  /// Unique key for the field (used to identify the field in form data)
  final String key;

  /// Type of field
  final FormFieldType type;

  /// Label text for the field
  final String label;

  /// Optional placeholder text
  final String? placeholder;

  /// Optional initial value
  final String? initialValue;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Optional spacing after the field
  final double? spacing;

  /// Optional max lines for multiline fields
  final int? maxLines;

  /// Optional dropdown items (for dropdown type)
  final List<Map<String, String>>? dropdownItems;

  /// Optional read-only flag
  final bool readOnly;

  /// Optional read-only function (evaluated dynamically)
  final bool Function()? readOnlyBuilder;

  /// Optional conditional field - only shown when condition is true
  final bool Function()? condition;

  /// Optional external text controller (if provided, form won't create its own)
  final TextEditingController? textController;

  /// Optional external dropdown notifier (if provided, form won't create its own)
  final ValueNotifier<String?>? dropdownNotifier;

  /// Optional external radio notifier (if provided, form won't create its own)
  final ValueNotifier<String>? radioNotifier;

  FormFieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.placeholder,
    this.initialValue,
    this.validator,
    this.spacing,
    this.maxLines,
    this.dropdownItems,
    this.readOnly = false,
    this.readOnlyBuilder,
    this.condition,
    this.textController,
    this.dropdownNotifier,
    this.radioNotifier,
  });
}

/// Types of form fields supported
enum FormFieldType {
  text,
  email,
  multiline,
  date,
  dropdown,
  gender,
  deviceModel,
  college,
  radio,
  label,
}
