import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../common/services/storage_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/core/utils/common_snackbar.dart';

class PersonalDetailsController extends GetxController {
  //TODO: Implement PersonalDetailsController

  final count = 0.obs;

  late final GlobalKey<FormState> formKey;
  final fullNameController = TextEditingController();
  final birthdayController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final selectedGender = ValueNotifier<String?>('male');
  final selectedDeviceModel = ValueNotifier<String?>('galaxys24ultra');
  final phoneNumber = ''.obs;
  DateTime? selectedBirthday;
  final genderError = ''.obs;
  final deviceModelError = ''.obs;
  final selectedImagePath = Rxn<File>();
  final profilePictureUrl = Rxn<String>();
  final isUploadingImage = false.obs;

  @override
  void onInit() {
    super.onInit();
    formKey = GlobalKey<FormState>();
    final parameters = Get.parameters as Map<String, dynamic>?;
    if (phoneNumber.value.isEmpty) {
      phoneNumber.value = (parameters?['phoneNumber'] as String?) ?? '';
    }

    if (birthdayController.text.isEmpty) {
      final now = DateTime.now();
      final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
      selectedBirthday = eighteenYearsAgo;
      final year = eighteenYearsAgo.year.toString();
      final month = eighteenYearsAgo.month.toString().padLeft(2, '0');
      final day = eighteenYearsAgo.day.toString().padLeft(2, '0');
      birthdayController.text = '$year-$month-$day';
    }
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
    FocusScope.of(Get.context!).unfocus();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate:
          selectedBirthday ?? today.subtract(const Duration(days: 365 * 18)),
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
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selectedDate = DateTime(picked.year, picked.month, picked.day);

      if (selectedDate.isAfter(today)) {
        return;
      }

      selectedBirthday = picked;
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

  Future<void> selectProfilePicture() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await StorageService.pickImage(source: source);
      if (pickedFile != null) {
        selectedImagePath.value = File(pickedFile.path);
        await _uploadProfilePicture();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to select image');
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await Get.dialog<ImageSource>(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: AppColors.white,
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: Text(
                  'Take Photo',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: Text('Cancel', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture() async {
    if (selectedImagePath.value == null || phoneNumber.value.isEmpty) return;

    isUploadingImage.value = true;
    try {
      final userId = phoneNumber.value.replaceAll(RegExp(r'\D'), '');
      final url = await StorageService.uploadProfilePicture(
        imageFile: selectedImagePath.value!,
        userId: userId,
      );

      if (url != null) {
        profilePictureUrl.value = url;
      } else {
        CommonSnackbar.error('Failed to upload profile picture');
        selectedImagePath.value = null;
      }
    } catch (e) {
      CommonSnackbar.error('Failed to upload profile picture');
      selectedImagePath.value = null;
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> handleNext() async {
    genderError.value = '';
    deviceModelError.value = '';

    final List<String> errors = [];

    final fullName = fullNameController.text.trim();
    if (fullName.isEmpty) {
      errors.add('fullName'.tr);
    }

    final birthday = birthdayController.text.trim();
    if (birthday.isEmpty) {
      errors.add('birthday'.tr);
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      errors.add('emailAddress'.tr);
    } else {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      if (!emailRegex.hasMatch(email)) {
        errors.add('emailAddress'.tr + ' (invalid format)');
      }
    }

    final city = cityController.text.trim();
    if (city.isEmpty) {
      errors.add('city'.tr);
    }

    if (selectedGender.value == null || selectedGender.value!.isEmpty) {
      errors.add('gender'.tr);
    }

    if (selectedDeviceModel.value == null ||
        selectedDeviceModel.value!.isEmpty) {
      errors.add('deviceModel'.tr);
    }

    if (phoneNumber.value.isEmpty) {
      errors.add('mobile_number'.tr);
    }

    if (errors.isNotEmpty) {
      final errorMessage = '${errors.join(', ')} is required';
      CommonSnackbar.error(errorMessage);
      formKey.currentState?.validate();
      return;
    }

    final personalDetailsData = <String, String>{
      'phoneNumber': phoneNumber.value,
      'fullName': fullNameController.text.trim(),
      'birthday': selectedBirthday?.toIso8601String().split('T')[0] ?? '',
      'email': emailController.text.trim(),
      'city': cityController.text.trim(),
      'gender': selectedGender.value ?? '',
      'deviceModel': selectedDeviceModel.value ?? '',
    };

    if (profilePictureUrl.value != null) {
      personalDetailsData['profilePictureUrl'] = profilePictureUrl.value!;
    }

    Get.toNamed(Routes.ACCOUNT_DETAIL, parameters: personalDetailsData);
  }
}
