import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:samsung_community_mobile/app/routes/app_pages.dart';

import '../../../common/services/analytics_service.dart';
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
    final List<String> requiredErrors = [];

    final socialMediaInput = socialMediaController.text.trim();
    final Map<String, String> socialMediaMap = {};

    if (socialMediaInput.isNotEmpty) {
      final urls = socialMediaInput
          .split(',')
          .map((url) => url.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      for (var url in urls) {
        if (!isValidUrl(url)) {
          errors.add('Invalid URL: $url');
          continue;
        }
        final platform = parseSocialMediaPlatform(url);
        if (platform == null) {
          errors.add('Unsupported platform: $url');
          continue;
        }
        // Use platform as key, or add index if platform already exists
        final key = socialMediaMap.containsKey(platform)
            ? '${platform}_${socialMediaMap.length}'
            : platform;
        socialMediaMap[key] = url;
      }
    }

    // Show social media validation errors first
    if (errors.isNotEmpty) {
      CommonSnackbar.error(errors.join(', '));
      return;
    }

    if (selectedStudent.value == 'yes') {
      if (selectedCollege.value == null || selectedCollege.value!.isEmpty) {
        requiredErrors.add('choose_college'.tr);
      }

      if (classController.text.trim().isEmpty) {
        requiredErrors.add('name_of_class'.tr);
      }
    }

    if (phoneNumber.value.isEmpty) {
      requiredErrors.add('mobile_number'.tr);
    }

    if (requiredErrors.isNotEmpty) {
      final errorMessage = '${requiredErrors.join(', ')} is_required'.tr;
      CommonSnackbar.error(errorMessage);
      return;
    }

    // Log button click event with student and college parameters
    AnalyticsService.logButtonClick(
      screenName: 'signup screen personal details',
      buttonName: 'signup',
      eventName: 'signup_personal_details_click',
      additionalParams: {
        'student': selectedStudent.value == 'yes' ? 'Yes' : 'no',
        'college': selectedCollege.value ?? '',
      },
    );

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

    if (socialMediaMap.isNotEmpty) {
      profileData['socialMediaLinks'] = socialMediaMap;
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
      CommonSnackbar.error('failed_to_save_profile'.tr);
    }
  }

  void increment() => count.value++;
}
