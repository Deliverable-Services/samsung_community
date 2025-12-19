import 'package:get/get.dart';

import '../../../common/services/content_service.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/models/content_model.dart';

class VodController extends BaseController {
  final ContentService _contentService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<ContentModel> contentList = <ContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  VodController({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  void setFilter(int index) {
    selectedFilterIndex.value = index;
    _currentOffset = 0;
    contentList.clear();
    hasMoreData.value = true;
    loadContent();
  }

  Future<void> loadContent({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMoreData.value) return;
      isLoadingMore.value = true;
    } else {
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

      final result = await _contentService.getContent(
        contentType: filterType,
        isPublished: true,
        limit: _pageSize,
        offset: loadMore ? _currentOffset : 0,
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
