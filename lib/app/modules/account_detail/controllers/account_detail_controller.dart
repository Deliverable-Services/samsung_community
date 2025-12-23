import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../data/core/utils/common_snackbar.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class AccountDetailController extends GetxController {
  final count = 0.obs;

  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final ValueNotifier<String?> selectedCollege = ValueNotifier<String?>(null);
  final ValueNotifier<String> selectedStudent = ValueNotifier('yes');
  final authRepo = Get.find<AuthRepo>();
  final phoneNumber = ''.obs;
  final isSaving = false.obs;

  Map<String, dynamic>? personalDetailsData;

  @override
  void onInit() {
    super.onInit();
    final parameters = Get.parameters as Map<String, dynamic>?;
    if (parameters != null && parameters.isNotEmpty) {
      personalDetailsData = parameters;
    }
    if (phoneNumber.value.isEmpty) {
      phoneNumber.value =
          (parameters?['phoneNumber'] as String? ??
              personalDetailsData?['phoneNumber'] as String?) ??
          '';
    }

    selectedStudent.addListener(onStudentSelectionChanged);
  }

  void onStudentSelectionChanged() {
    if (selectedStudent.value == 'no') {
      selectedCollege.value = null;
      classController.clear();
    }
  }

  @override
  void dispose() {
    selectedStudent.removeListener(onStudentSelectionChanged);
    socialMediaController.dispose();
    professionController.dispose();
    bioController.dispose();
    classController.dispose();
    selectedCollege.dispose();
    super.dispose();
  }

  String? parseSocialMediaPlatform(String url) {
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;

    final host = uri.host.toLowerCase();

    final cleanHost = host.replaceFirst(RegExp(r'^www\.'), '');

    if (cleanHost.contains('instagram.com')) {
      return 'instagram';
    } else if (cleanHost.contains('facebook.com')) {
      return 'facebook';
    } else if (cleanHost.contains('twitter.com') ||
        cleanHost.contains('x.com')) {
      return 'twitter';
    } else if (cleanHost.contains('linkedin.com')) {
      return 'linkedin';
    } else if (cleanHost.contains('youtube.com')) {
      return 'youtube';
    } else if (cleanHost.contains('tiktok.com')) {
      return 'tiktok';
    }

    return null;
  }

  bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }

  Future<void> handleSubmit() async {
    final List<String> errors = [];

    final socialMediaUrl = socialMediaController.text.trim();
    String? platform;

    if (socialMediaUrl.isNotEmpty) {
      if (!isValidUrl(socialMediaUrl)) {
        errors.add('social_media'.tr + ' (invalid URL)');
      } else {
        platform = parseSocialMediaPlatform(socialMediaUrl);
        if (platform == null) {
          errors.add('social_media'.tr + ' (invalid platform)');
        }
      }
    }

    if (selectedStudent.value == 'yes') {
      if (selectedCollege.value == null || selectedCollege.value!.isEmpty) {
        errors.add('choose_college'.tr);
      }

      if (classController.text.trim().isEmpty) {
        errors.add('name_of_class'.tr);
      }
    }

    if (phoneNumber.value.isEmpty) {
      errors.add('mobile_number'.tr);
    }

    if (errors.isNotEmpty) {
      final errorMessage = '${errors.join(', ')} is required';
      CommonSnackbar.error(errorMessage);
      return;
    }

    isSaving.value = true;

    final profileData = <String, dynamic>{};

    if (personalDetailsData != null) {
      final personalData = personalDetailsData!;
      if (personalData.containsKey('fullName') &&
          personalData['fullName'] != null) {
        profileData['fullName'] = personalData['fullName'];
      }
      if (personalData.containsKey('birthday') &&
          personalData['birthday'] != null) {
        profileData['birthday'] = personalData['birthday'];
      }
      if (personalData.containsKey('email') && personalData['email'] != null) {
        profileData['email'] = personalData['email'];
      }
      if (personalData.containsKey('city') && personalData['city'] != null) {
        profileData['city'] = personalData['city'];
      }
      if (personalData.containsKey('gender') &&
          personalData['gender'] != null) {
        profileData['gender'] = personalData['gender'];
      }
      if (personalData.containsKey('deviceModel') &&
          personalData['deviceModel'] != null) {
        profileData['deviceModel'] = personalData['deviceModel'];
      }
      if (personalData.containsKey('profilePictureUrl') &&
          personalData['profilePictureUrl'] != null) {
        profileData['profilePictureUrl'] = personalData['profilePictureUrl'];
      }
    }

    final profession = professionController.text.trim();
    if (profession.isNotEmpty) {
      profileData['profession'] = profession;
    }

    final bio = bioController.text.trim();
    if (bio.isNotEmpty) {
      profileData['bio'] = bio;
    }

    if (socialMediaUrl.isNotEmpty && platform != null) {
      profileData['socialMediaLinks'] = {platform: socialMediaUrl};
    }

    if (selectedStudent.value == 'yes') {
      profileData['college'] = selectedCollege.value ?? '';
      profileData['className'] = classController.text.trim();
    }

    try {
      final success = await authRepo.saveProfile(
        phoneNumber: phoneNumber.value,
        profileData: profileData,
      );

      isSaving.value = false;

      if (success) {
        Get.offNamed(Routes.REQUEST_SENT);
      }
    } catch (e) {
      isSaving.value = false;
      CommonSnackbar.error('Failed to save profile. Please try again.');
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
}
