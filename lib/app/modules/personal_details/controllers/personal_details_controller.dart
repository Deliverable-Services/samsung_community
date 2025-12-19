import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/constants/app_colors.dart';

class PersonalDetailsController extends GetxController {
  //TODO: Implement PersonalDetailsController

  final count = 0.obs;

  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final selectedGender = ValueNotifier<String?>('male'); // Default to Male
  final selectedDeviceModel = ValueNotifier<String?>(
    'galaxys24ultra',
  ); // Default to Galaxy S24 Ultra
  final phoneNumber = ''.obs;
  DateTime? selectedBirthday;
  final genderError = ''.obs;
  final deviceModelError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get phone number from route arguments
    final parameters = Get.parameters as Map<String, dynamic>?;
    phoneNumber.value = (parameters?['phoneNumber'] as String?) ?? '';

    // Pre-fill birthday with date 18 years ago from now
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    selectedBirthday = eighteenYearsAgo;
    // Format date as yyyy-MM-dd
    final year = eighteenYearsAgo.year.toString();
    final month = eighteenYearsAgo.month.toString().padLeft(2, '0');
    final day = eighteenYearsAgo.day.toString().padLeft(2, '0');
    birthdayController.text = '$year-$month-$day';
  }

  @override
  void dispose() {
    fullNameController.dispose();
    birthdayController.dispose();
    emailController.dispose();
    cityController.dispose();
    selectedGender.dispose();
    selectedDeviceModel.dispose();
    super.dispose();
  }

  Future<void> selectDate() async {
    // Unfocus any active text fields
    FocusScope.of(Get.context!).unfocus();

    // Get today's date to ensure no future dates can be selected
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          selectedBirthday ?? today.subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: today,
      selectableDayPredicate: (DateTime date) {
        // Disable all dates after today
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
      // Double-check that the selected date is not in the future
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(picked.year, picked.month, picked.day);

      if (selectedDate.isAfter(today)) {
        // If somehow a future date was selected, don't save it
        return;
      }

      selectedBirthday = picked;
      // Format date as yyyy-MM-dd
      final year = picked.year.toString();
      final month = picked.month.toString().padLeft(2, '0');
      final day = picked.day.toString().padLeft(2, '0');
      birthdayController.text = '$year-$month-$day';
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  Future<void> handleNext() async {
    // Clear previous errors
    genderError.value = '';
    deviceModelError.value = '';

    // Validate form
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validate gender
    if (selectedGender.value == null || selectedGender.value!.isEmpty) {
      genderError.value = 'gender'.tr + ' is required';
      return;
    }

    // Validate device model
    if (selectedDeviceModel.value == null ||
        selectedDeviceModel.value!.isEmpty) {
      deviceModelError.value = 'deviceModel'.tr + ' is required';
      return;
    }

    // Validate phone number
    if (phoneNumber.isEmpty) {
      print('Error: Phone number not found');
      return;
    }

    // Prepare personal details data to pass to next screen
    final personalDetailsData = <String, String>{
      'phoneNumber': phoneNumber.value,
      'fullName': fullNameController.text.trim(),
      'birthday': selectedBirthday?.toIso8601String().split('T')[0] ?? '',
      'email': emailController.text.trim(),
      'city': cityController.text.trim(),
      'gender': selectedGender.value ?? '',
      'deviceModel': selectedDeviceModel.value ?? '',
    };

    Get.toNamed(Routes.ACCOUNT_DETAIL, parameters: personalDetailsData);
  }
}
