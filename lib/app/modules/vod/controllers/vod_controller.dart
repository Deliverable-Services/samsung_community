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

  VodController({ContentService? contentService})
    : _contentService = contentService ?? ContentService();

  @override
  void onInit() {
    super.onInit();
    loadContent();
  }

  void setFilter(int index) {
    selectedFilterIndex.value = index;
    loadContent();
  }

  Future<void> loadContent() async {
    isLoadingContent.value = true;
    setLoading(true);

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
      );

      if (result.isSuccess) {
        contentList.value = result.dataOrNull ?? [];
      } else {
        handleError(result.errorOrNull ?? 'somethingWentWrong'.tr);
      }
    } catch (e) {
      handleError('somethingWentWrong'.tr);
    } finally {
      isLoadingContent.value = false;
      setLoading(false);
    }
  }

  List<ContentModel> get filteredContent {
    if (selectedFilterIndex.value == 0) {
      return contentList;
    }
    return contentList;
  }
}
