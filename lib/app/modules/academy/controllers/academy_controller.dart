import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/academy_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/result.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../data/models/academy_content_model.dart';

class AcademyController extends BaseController {
  final AcademyService academyService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<AcademyContentModel> contentList = <AcademyContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  Timer? searchDebounceTimer;

  static const int pageSize = 10;
  int currentOffset = 0;

  AcademyController({AcademyService? academyService})
    : academyService = academyService ?? AcademyService();

  late final ScrollController scrollController;

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
}
