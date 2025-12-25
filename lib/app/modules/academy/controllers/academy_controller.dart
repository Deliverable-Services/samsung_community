import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/academy_service.dart';
import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../data/models/academy_content_model.dart';
import '../views/academic_audio_submit_module.dart';

class AcademyController extends BaseController {
  final AcademyService academyService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<AcademyContentModel> contentList = <AcademyContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isConfirmChecked = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  Timer? searchDebounceTimer;

  static const int pageSize = 10;
  int currentOffset = 0;

  AcademyController({AcademyService? academyService})
    : academyService = academyService ?? AcademyService();

  late final ScrollController scrollController;

  final selectedMediaFile = Rxn<File>();
  final uploadedMediaUrl = Rxn<String>();
  final uploadedFileName = Rxn<String>();
  final isUploadingMedia = false.obs;
  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    loadContent();
  }

  @override
  void onReady() {
    super.onReady();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    await _authRepo.loadCurrentUser();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      loadMoreContent();
    }
  }

  @override
  void onClose() {
    searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    searchDebounceTimer?.cancel();
    searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text.trim();
      if (searchQuery.value != query) {
        _pauseAllMedia();
        searchQuery.value = query;
        currentOffset = 0;
        contentList.clear();
        hasMoreData.value = true;
        loadContent();
      }
    });
  }

  void setFilter(int index) {
    _pauseAllMedia();
    selectedFilterIndex.value = index;
    currentOffset = 0;
    contentList.clear();
    hasMoreData.value = true;
    loadContent();
  }

  void _pauseAllMedia() {
    VideoPlayerManager.pauseAll();
    AudioPlayerManager.pauseAll();
  }

  Future<void> loadContent({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMoreData.value) return;
      isLoadingMore.value = true;
    } else {
      currentOffset = 0;
      contentList.clear();
      hasMoreData.value = true;
      isLoadingContent.value = true;
      setLoading(true);
    }

    try {
      AcademyFileType? filterType;
      if (selectedFilterIndex.value == 1) {
        filterType = AcademyFileType.video;
      } else if (selectedFilterIndex.value == 2) {
        filterType = AcademyFileType.reel;
      } else if (selectedFilterIndex.value == 3) {
        filterType = AcademyFileType.zoomWorkshop;
      } else if (selectedFilterIndex.value == 4) {
        filterType = AcademyFileType.assignment;
      }

      final List<AcademyFileType> allowedTypes = [
        AcademyFileType.video,
        AcademyFileType.reel,
        AcademyFileType.zoomWorkshop,
        AcademyFileType.assignment,
      ];

      final result = await academyService.getAcademy(
        contentType: filterType,
        // allowedAcademyTypes: allowedTypes,
        isPublished: true,
        limit: pageSize,
        offset: loadMore ? currentOffset : 0,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (result.isSuccess) {
        final newContent = result.dataOrNull ?? [];

        if (loadMore) {
          contentList.addAll(newContent);
        } else {
          contentList.value = newContent;
        }

        if (newContent.length < pageSize) {
          hasMoreData.value = false;
        } else {
          currentOffset = contentList.length;
        }
      } else {
        handleError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoadingContent.value = false;
        setLoading(false);
      }
    }
  }

  Future<void> loadMoreContent() async {
    await loadContent(loadMore: true);
  }

  List<AcademyContentModel> get filteredContent {
    return contentList;
  }

  void clickOnButtonTap({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    /// 🔒 Assignment guard
    if (content.assignmentId == null) {
      CommonSnackbar.error('This content does not accept submissions');
      return;
    }

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
        Get.back();
      },
      content: AcademicAudioSubmitModule(
        title: content.title,
        description: content.description ?? '',
        pointsToEarn: content.pointsToEarn,
        onPublish1: selectMediaFile,
        onPublish: () async {
          if (!(uploadedMediaUrl.value != null &&
              uploadedMediaUrl.value!.isNotEmpty)) {
            CommonSnackbar.error('Please select audio file');
            return;
          }
          if (!isConfirmChecked.value) {
            CommonSnackbar.error('Please enable check box');
            return;
          }

          Get.back();

          final user = SupabaseService.currentUser;
          if (user == null) {
            CommonSnackbar.error('User not found');
            return;
          }

          final data = {
            'solution': uploadedMediaUrl.value,
            'assignment_id': content.assignmentId, // ✅ now guaranteed non-null
            'user_id': user.id,
          };

          final result = await AcademyService().assignmentSubmissions(
            content: data,
          );

          if (result is Success<Map<String, dynamic>>) {
            clearFields();
            CommonSnackbar.success('Audio published successfully');
          } else {
            CommonSnackbar.error('Failed to publish audio');
          }
        },
      ),
    );
  }

  Future<void> selectMediaFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        selectedMediaFile.value = File(result.files.single.path!);
        uploadedFileName.value = result.files.single.name;
        await _uploadMediaFile(mediaType: MediaType.audio);
      }
    } catch (e) {
      CommonSnackbar.error('Failed to select file');
    }
  }

  Future<void> _uploadMediaFile({required MediaType mediaType}) async {
    if (selectedMediaFile.value == null) return;

    isUploadingMedia.value = true;
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('User not found');
        return;
      }

      final file = selectedMediaFile.value!;

      final url = await StorageService.uploadMedia(
        mediaFile: file,
        userId: currentUser.id,
        bucketName: 'assignments',
        mediaType: mediaType, // image / video / audio
      );

      if (url != null) {
        uploadedMediaUrl.value = url;
      } else {
        CommonSnackbar.error('Failed to upload file');
        clearFields();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to upload file');
      clearFields();
    } finally {
      isUploadingMedia.value = false;
    }
  }

  void clearFields() {
    selectedMediaFile.value = null;
    uploadedMediaUrl.value = '';
    uploadedFileName.value = null;
    isConfirmChecked.value = false;
  }
}
