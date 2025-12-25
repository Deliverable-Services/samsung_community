import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/content_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../data/models/content_model.dart';

class VodController extends BaseController {
  final ContentService _contentService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<ContentModel> contentList = <ContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounceTimer;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  VodController({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
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

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text.trim();
      if (searchQuery.value != query) {
        _pauseAllMedia();
        searchQuery.value = query;
        _currentOffset = 0;
        contentList.clear();
        hasMoreData.value = true;
        loadContent();
      }
    });
  }

  void setFilter(int index) {
    _pauseAllMedia();
    selectedFilterIndex.value = index;
    _currentOffset = 0;
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
      _currentOffset = 0;
      contentList.clear();
      hasMoreData.value = true;
      isLoadingContent.value = true;
      setLoading(true);
    }

    try {
      ContentType? filterType;
      if (selectedFilterIndex.value == 1) {
        filterType = ContentType.vod;
      } else if (selectedFilterIndex.value == 2) {
        filterType = ContentType.podcast;
      }

      final List<ContentType> allowedTypes = [
        ContentType.vod,
        ContentType.podcast,
      ];

      final result = await _contentService.getContent(
        contentType: filterType,
        allowedContentTypes: allowedTypes,
        isPublished: true,
        limit: _pageSize,
        offset: loadMore ? _currentOffset : 0,
        searchQuery: searchQuery.value.isNotEmpty ? searchQuery.value : null,
      );

      if (result.isSuccess) {
        final newContent = result.dataOrNull ?? [];

        if (loadMore) {
          contentList.addAll(newContent);
        } else {
          contentList.value = newContent;
        }

        if (newContent.length < _pageSize) {
          hasMoreData.value = false;
        } else {
          _currentOffset = contentList.length;
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

  List<ContentModel> get filteredContent {
    return contentList;
  }
}
