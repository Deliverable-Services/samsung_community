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

class ReusableForm extends StatefulWidget {
  final List<FormFieldConfig> fields;

  final String saveButtonText;
  final Future<void> Function(Map<String, dynamic> formData) onSave;

  final bool isLoading;

  final EdgeInsetsGeometry? padding;

  final bool isScrollable;

  final bool hideSaveButton;
  final double? saveButtonSpacing;

  const ReusableForm({
    super.key,
    required this.fields,
    required this.saveButtonText,
    required this.onSave,
    this.isLoading = false,
    this.padding,
    this.isScrollable = true,
    this.hideSaveButton = false,
    this.saveButtonSpacing,
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
          if (field.textController != null) {
            _controllers[field.key] = field.textController!;
          } else {
            _controllers[field.key] = TextEditingController(
              text: field.initialValue,
            );
          }
          if (field.type == FormFieldType.date) {
            final existingText = _controllers[field.key]!.text;
            if (existingText.isNotEmpty) {
              try {
                final parsed = DateTime.parse(existingText);
                _dateValues[field.key] = parsed;
                _controllers[field.key]!.text = _formatDateDisplay(parsed);
              } catch (e) {}
            } else if (field.initialValue != null) {
              try {
                final parsed = DateTime.parse(field.initialValue!);
                _dateValues[field.key] = parsed;
                _controllers[field.key]!.text = _formatDateDisplay(parsed);
              } catch (e) {}
            }
          }
          break;
        case FormFieldType.dropdown:
        case FormFieldType.gender:
        case FormFieldType.deviceModel:
        case FormFieldType.college:
          if (field.dropdownNotifier != null) {
            _dropdownNotifiers[field.key] = field.dropdownNotifier!;
          } else {
            _dropdownNotifiers[field.key] = ValueNotifier<String?>(
              field.initialValue,
            );
          }
          break;
        case FormFieldType.radio:
          if (field.radioNotifier != null) {
            _radioNotifiers[field.key] = field.radioNotifier!;
          } else {
            _radioNotifiers[field.key] = ValueNotifier<String>(
              field.initialValue ?? 'yes',
            );
          }
          break;
        case FormFieldType.label:
          break;
      }
    }
  }

  @override
  void dispose() {
    for (final field in widget.fields) {
      switch (field.type) {
        case FormFieldType.text:
        case FormFieldType.email:
        case FormFieldType.multiline:
        case FormFieldType.date:
          if (field.textController == null) {
            _controllers[field.key]?.dispose();
          }
          break;
        case FormFieldType.dropdown:
        case FormFieldType.gender:
        case FormFieldType.deviceModel:
        case FormFieldType.college:
          if (field.dropdownNotifier == null) {
            _dropdownNotifiers[field.key]?.dispose();
          }
          break;
        case FormFieldType.radio:
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
    // Validate all fields including dropdowns
    for (final field in widget.fields) {
      if (field.validator != null) {
        String? errorMessage;
        switch (field.type) {
          case FormFieldType.text:
          case FormFieldType.email:
          case FormFieldType.multiline:
          case FormFieldType.date:
            final controller = _controllers[field.key];
            if (controller != null) {
              errorMessage = field.validator!(controller.text);
            }
            break;
          case FormFieldType.dropdown:
          case FormFieldType.gender:
          case FormFieldType.deviceModel:
          case FormFieldType.college:
            final notifier = _dropdownNotifiers[field.key];
            if (notifier != null) {
              errorMessage = field.validator!(notifier.value);
            }
            break;
          default:
            break;
        }
        if (errorMessage != null) {
          Get.snackbar(
            'Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            margin: EdgeInsets.all(16.w),
          );
          return;
        }
      }
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formData = <String, dynamic>{};

    for (final entry in _controllers.entries) {
      final value = entry.value.text.trim();
      if (value.isNotEmpty) {
        formData[entry.key] = value;
      }
    }

    for (final entry in _dropdownNotifiers.entries) {
      final value = entry.value.value;
      if (value != null && value.isNotEmpty) {
        formData[entry.key] = value;
      }
    }

    for (final entry in _radioNotifiers.entries) {
      formData[entry.key] = entry.value.value;
    }

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

    DateTime? currentDate = _dateValues[fieldKey];
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
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dateValues[fieldKey] = picked;
        _controllers[fieldKey]?.text = _formatDateDisplay(picked);

        // Find the field config and trigger onBlur if available
        final field = widget.fields.firstWhere(
          (f) => f.key == fieldKey,
          orElse: () => widget.fields.first,
        );
        if (field.onBlur != null) {
          // Call onBlur with the date string
          field.onBlur!();
        }
      });
    }
  }

  String _formatDateDisplay(DateTime date) {
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final monthName = monthNames[date.month - 1];
    final year = date.year.toString();
    return '$day $monthName $year';
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
          onEditingComplete: field.onBlur,
        );

      case FormFieldType.multiline:
        return CustomTextField(
          label: field.label,
          controller: _controllers[field.key]!,
          placeholder: field.placeholder ?? 'type'.tr,
          maxLines: field.maxLines ?? 5,
          validator: field.validator,
          onEditingComplete: field.onBlur,
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
            SizedBox(height: widget.saveButtonSpacing ?? 30.h),
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

class FormFieldConfig {
  final String key;

  final FormFieldType type;

  final String label;

  final String? placeholder;

  final String? initialValue;

  final String? Function(String?)? validator;

  final double? spacing;

  final int? maxLines;

  final List<Map<String, String>>? dropdownItems;

  final bool readOnly;

  final bool Function()? readOnlyBuilder;

  final bool Function()? condition;

  final TextEditingController? textController;

  final ValueNotifier<String?>? dropdownNotifier;

  final ValueNotifier<String>? radioNotifier;

  /// Optional callback when field loses focus (on blur)
  final VoidCallback? onBlur;

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
    this.onBlur,
  });
}

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
