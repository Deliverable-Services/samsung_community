import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/models/user_model copy.dart';
import '../../../repository/auth_repo/auth_repo.dart';

class EditProfileController extends BaseController {
  final AuthRepo _authRepo;

  final RxInt selectedTab = 0.obs;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final ValueNotifier<String?> selectedGender = ValueNotifier<String?>(null);
  final ValueNotifier<String?> selectedDeviceModel = ValueNotifier<String?>(
    null,
  );

  final TextEditingController socialMediaController = TextEditingController();
  final TextEditingController professionController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController classController = TextEditingController();
  final ValueNotifier<String?> selectedCollege = ValueNotifier<String?>(null);
  final ValueNotifier<String> selectedStudent = ValueNotifier('no');

  final Rxn<File> selectedImagePath = Rxn<File>();
  final Rxn<String> profilePictureUrl = Rxn<String>();
  final RxBool isUploadingImage = false.obs;
  DateTime? selectedBirthday;

  Timer? _saveTimer;
  final RxBool isSaving = false.obs;
  final Map<String, dynamic> _pendingChanges = {};

  EditProfileController({AuthRepo? authRepo})
    : _authRepo = authRepo ?? Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    _setupAutoSave();
    _detectAndSaveDeviceModel();
  }

  @override
  void onClose() {
    _saveTimer?.cancel();
    fullNameController.dispose();
    birthdayController.dispose();
    emailController.dispose();
    cityController.dispose();
    socialMediaController.dispose();
    professionController.dispose();
    bioController.dispose();
    classController.dispose();
    selectedGender.dispose();
    selectedDeviceModel.dispose();
    selectedCollege.dispose();
    selectedStudent.dispose();
    super.onClose();
  }

  void _setupAutoSave() {
    // Auto-save disabled; explicit Save buttons are used instead
  }

  Future<void> savePersonalDetails() async {
    _pendingChanges['fullName'] = fullNameController.text.trim();
    _pendingChanges['birthday'] = birthdayController.text.trim();
    _pendingChanges['email'] = emailController.text.trim();
    _pendingChanges['city'] = cityController.text.trim();
    if (selectedGender.value != null) {
      _pendingChanges['gender'] = selectedGender.value;
    }
    if (selectedDeviceModel.value != null) {
      _pendingChanges['deviceModel'] = selectedDeviceModel.value;
    }
    await _saveChanges();
    CommonSnackbar.success('profile_saved_successfully'.tr);
  }

  Future<void> saveAccountDetails() async {
    _pendingChanges['socialMedia'] = socialMediaController.text.trim();
    _pendingChanges['profession'] = professionController.text.trim();
    _pendingChanges['bio'] = bioController.text.trim();
    _pendingChanges['className'] = classController.text.trim();
    _pendingChanges['isStudent'] = selectedStudent.value;
    if (selectedCollege.value != null) {
      _pendingChanges['college'] = selectedCollege.value;
    }
    await _saveChanges();
    CommonSnackbar.success('profile_saved_successfully'.tr);
  }

  void _onFieldChanged(String key, dynamic value) {
    _pendingChanges[key] = value;
    _debounceSave();
  }

  /// Save immediately on blur (no debounce)
  void saveFieldOnBlur(String key, dynamic value) {
    _pendingChanges[key] = value;
    _saveChanges();
  }

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 1000), () {
      if (_pendingChanges.isNotEmpty) {
        _saveChanges();
      }
    });
  }

  Future<void> _saveChanges() async {
    if (_pendingChanges.isEmpty) return;

    try {
      isSaving.value = true;
      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        isSaving.value = false;
        return;
      }

      // Validate social media before saving
      if (_pendingChanges.containsKey('socialMedia')) {
        final socialMedia = _pendingChanges['socialMedia'] as String?;
        if (socialMedia != null && socialMedia.isNotEmpty) {
          final urls = socialMedia
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList();
          final List<String> errors = [];

          for (var url in urls) {
            if (!_isValidUrl(url)) {
              errors.add('invalid_url'.trParams({'url': url}));
              continue;
            }
            final platform = _parseSocialMediaPlatform(url);
            if (platform == null) {
              errors.add('unsupported_platform'.trParams({'url': url}));
            }
          }

          if (errors.isNotEmpty) {
            CommonSnackbar.error(errors.join(', '));
            isSaving.value = false;
            // Don't clear pending changes on validation error
            return;
          }
        }
      }

      final profileData = Map<String, dynamic>.from(_pendingChanges);
      _pendingChanges.clear();

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };

      if (profileData.containsKey('fullName')) {
        updateData['full_name'] = profileData['fullName'];
      }
      if (profileData.containsKey('email')) {
        updateData['email'] = profileData['email'];
      }
      if (profileData.containsKey('birthday')) {
        updateData['birthday'] = profileData['birthday'];
      }
      if (profileData.containsKey('city')) {
        updateData['city'] = profileData['city'];
      }
      if (profileData.containsKey('gender')) {
        updateData['gender'] = profileData['gender'];
      }
      if (profileData.containsKey('deviceModel')) {
        updateData['device_model'] = profileData['deviceModel'];
      }
      if (profileData.containsKey('profession')) {
        updateData['profession'] = profileData['profession'];
      }
      if (profileData.containsKey('bio')) {
        updateData['bio'] = profileData['bio'];
      }
      if (profileData.containsKey('college')) {
        updateData['college'] = profileData['college'];
      }
      if (profileData.containsKey('className')) {
        updateData['class_name'] = profileData['className'];
      }
      if (profileData.containsKey('socialMedia')) {
        final socialMedia = profileData['socialMedia'] as String?;
        if (socialMedia != null && socialMedia.isNotEmpty) {
          // Parse comma-separated URLs (already validated above)
          final urls = socialMedia
              .split(',')
              .map((url) => url.trim())
              .where((url) => url.isNotEmpty)
              .toList();
          final socialMediaMap = <String, String>{};

          for (var url in urls) {
            final platform = _parseSocialMediaPlatform(url);
            if (platform != null) {
              // Use platform as key, or add index if platform already exists
              final key = socialMediaMap.containsKey(platform)
                  ? '${platform}_${socialMediaMap.length}'
                  : platform;
              socialMediaMap[key] = url;
            }
          }

          if (socialMediaMap.isNotEmpty) {
            updateData['social_media_links'] = socialMediaMap;
          }
        } else {
          // Clear social media links if empty
          updateData['social_media_links'] = {};
        }
      }

      await SupabaseService.client
          .from('users')
          .update(updateData)
          .eq('id', currentUser.id);

      await _authRepo.loadCurrentUser();
    } catch (e) {
      debugPrint('Error auto-saving profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _detectAndSaveDeviceModel() async {
    try {
      String? model;
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        model = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        model = iosInfo.utsname.machine ?? iosInfo.model;
      }
      if (model != null && model.isNotEmpty) {
        selectedDeviceModel.value = model;
        // Do not auto-save here; saved when user presses Save
      }
    } catch (_) {}
  }

  Future<void> _loadAdditionalFields(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select('email, college, class_name')
          .eq('id', userId)
          .single();

      emailController.text = response['email'] as String? ?? '';
      selectedCollege.value = response['college'] as String?;
      classController.text = response['class_name'] as String? ?? '';

      final college = selectedCollege.value;
      if (college != null && college.isNotEmpty) {
        selectedStudent.value = 'yes';
      }
    } catch (e) {
      debugPrint('Error loading additional fields: $e');
    }
  }

  Future<void> loadUserProfile() async {
    try {
      setLoading(true);
      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) {
        handleError('user_not_found'.tr);
        return;
      }

      final userJson = currentUser.toJson();
      final user = UserModel.fromJson(userJson);

      fullNameController.text = user.fullName ?? '';
      if (user.birthday != null) {
        final year = user.birthday!.year.toString();
        final month = user.birthday!.month.toString().padLeft(2, '0');
        final day = user.birthday!.day.toString().padLeft(2, '0');
        birthdayController.text = '$year-$month-$day';
        selectedBirthday = user.birthday;
      }
      emailController.text = '';
      cityController.text = user.city ?? '';
      selectedGender.value = user.gender?.toJson();
      selectedDeviceModel.value = user.deviceModel;

      professionController.text = user.profession ?? '';
      bioController.text = user.bio ?? '';
      classController.text = '';
      selectedCollege.value = null;
      selectedStudent.value = 'no';

      // Load social media links - convert Map to comma-separated string
      if (user.socialMediaLinks.isNotEmpty) {
        final socialMediaUrls = user.socialMediaLinks.values
            .where((url) => url != null && url.toString().isNotEmpty)
            .map((url) => url.toString())
            .toList();
        socialMediaController.text = socialMediaUrls.join(', ');
      } else {
        socialMediaController.text = '';
      }

      await _loadAdditionalFields(currentUser.id);

      profilePictureUrl.value = user.profilePictureUrl;
    } catch (e) {
      debugPrint('Error loading profile: $e');
      handleError('Failed to load profile');
    } finally {
      setLoading(false);
    }
  }

  Future<void> selectProfilePicture() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await StorageService.pickImage(source: source);
      if (pickedFile != null) {
        await _uploadProfilePicture(File(pickedFile.path));
      }
    } catch (e) {
      CommonSnackbar.error('failed_to_select_image'.tr);
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
                title: const Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.white),
                title: const Text(
                  'Take Photo',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.white,
                    fontFamily: 'Samsung Sharp Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final currentUser = _authRepo.currentUser.value;
    if (currentUser == null || currentUser.id.isEmpty) {
      CommonSnackbar.error('user_not_found'.tr);
      return;
    }

    isUploadingImage.value = true;
    try {
      final url = await StorageService.uploadProfilePicture(
        imageFile: imageFile,
        userId: currentUser.id,
        bucketName: 'profile_pictures',
      );

      if (url != null) {
        await _updateUserProfilePicture(url);
        profilePictureUrl.value = url;
        CommonSnackbar.success('profile_picture_updated'.tr);
      } else {
        CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      CommonSnackbar.error('failed_to_upload_profile_picture'.tr);
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _updateUserProfilePicture(String imageUrl) async {
    try {
      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) return;

      await SupabaseService.client
          .from('users')
          .update({'profile_picture_url': imageUrl})
          .eq('id', currentUser.id);

      await _authRepo.loadCurrentUser();
    } catch (e) {
      debugPrint('Error updating user profile picture: $e');
      rethrow;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  String? _parseSocialMediaPlatform(String url) {
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

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
