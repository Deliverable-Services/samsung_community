import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/services/content_service.dart';
import '../../../common/services/event_service.dart';
import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../common/services/weekly_riddle_service.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/reusable_submission_modules.dart';
import '../../../data/models/content_model.dart';
import '../../../data/models/event_model.dart';
import '../../../data/models/home_item_model.dart';
import '../../../data/models/weekly_riddle_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../repo/promotion_model.dart';
import '../repo/promotion_service.dart';
import '../views/promotion_card.dart';

class HomeController extends GetxController {
  final AuthRepo _authRepo = Get.find<AuthRepo>();
  final WeeklyRiddleService _weeklyRiddleService = WeeklyRiddleService();
  final EventService _eventService = EventService();
  final ContentService _contentService = ContentService();

  // Latest Items State
  final Rxn<EventModel> latestEvent = Rxn<EventModel>();
  final Rxn<WeeklyRiddleModel> weeklyRiddle = Rxn<WeeklyRiddleModel>();
  final Rxn<ContentModel> latestVod = Rxn<ContentModel>();
  final Rxn<ContentModel> latestPodcast = Rxn<ContentModel>();

  // Infinite Scroll Items
  final RxList<HomeItem> allItems = <HomeItem>[].obs;
  final RxBool isLoadingLatestItems = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingRiddle = false.obs;
  final RxBool hasSubmittedRiddle = false.obs;

  static const int _pageSize = 10;
  int _itemsLoaded = 0;

  // Scroll Controller
  ScrollController? scrollController;

  // Submission State
  final TextEditingController textController = TextEditingController();
  final RxBool isConfirmChecked = false.obs;
  final selectedMediaFile = Rxn<File>();
  final uploadedMediaUrl = Rxn<String>();
  final uploadedFileName = Rxn<String>();
  final isUploadingMedia = false.obs;

  final PromotionService _promotionService = PromotionService();

  final RxList<PromotionModel> promotions = <PromotionModel>[].obs;
  final RxBool isLoadingPromotions = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController?.addListener(_onScroll);

    loadLatestItems().then((_) {
      loadAllItems();
    });
  }

  Future<void> loadPromotions() async {
    isLoadingPromotions.value = true;
    final result = await _promotionService.fetchPromotions();

    if (result.isSuccess) {
      promotions.value = result.dataOrNull ?? [];
      isLoadingPromotions.value = false;
      showPromotionsOneByOne();
    }

    isLoadingPromotions.value = false;
  }

  void _onScroll() {
    if (scrollController != null &&
        scrollController!.position.pixels >=
            scrollController!.position.maxScrollExtent * 0.8) {
      loadMoreItems();
    }
  }

  void showPromotionsOneByOne() {
    if (promotions.isEmpty) return;
    _showPromotionAtIndex(0);
  }

  void _showPromotionAtIndex(int index) {
    if (index >= promotions.length) return;

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (_) => PromotionPopup(
        promotion: promotions[index],
        onClose: () {
          Get.back(); // close current popup

          // Show next popup after close
          Future.delayed(const Duration(milliseconds: 300), () {
            _showPromotionAtIndex(index + 1);
          });
        },
      ),
    );
  }

  /// Load all latest items
  Future<void> loadLatestItems() async {
    isLoadingLatestItems.value = true;
    await Future.wait([
      loadPromotions(),
      loadWeeklyRiddle(),
      loadLatestEvent(),
      loadLatestVod(),
      loadLatestPodcast(),
    ]);
    isLoadingLatestItems.value = false;
  }

  /// Load latest event
  Future<void> loadLatestEvent() async {
    try {
      final result = await _eventService.getEvents(isPublished: true, limit: 1);
      if (result.isSuccess) {
        final events = result.dataOrNull ?? [];
        latestEvent.value = events.isNotEmpty ? events.first : null;
      }
    } catch (e) {
      debugPrint('Error loading latest event: $e');
    }
  }

  /// Load latest VOD
  Future<void> loadLatestVod() async {
    try {
      final result = await _contentService.getContent(
        contentType: ContentType.vod,
        isPublished: true,
        limit: 1,
      );
      if (result.isSuccess) {
        final content = result.dataOrNull ?? [];
        latestVod.value = content.isNotEmpty ? content.first : null;
      }
    } catch (e) {
      debugPrint('Error loading latest VOD: $e');
    }
  }

  /// Load latest podcast
  Future<void> loadLatestPodcast() async {
    try {
      final result = await _contentService.getContent(
        contentType: ContentType.podcast,
        isPublished: true,
        limit: 1,
      );
      if (result.isSuccess) {
        final content = result.dataOrNull ?? [];
        latestPodcast.value = content.isNotEmpty ? content.first : null;
      }
    } catch (e) {
      debugPrint('Error loading latest podcast: $e');
    }
  }

  /// Load all items for infinite scroll (merged and sorted by createdAt)
  Future<void> loadAllItems({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMoreData.value) return;
      isLoadingMore.value = true;
    } else {
      _itemsLoaded = 0;
      allItems.clear();
      hasMoreData.value = true;
    }

    try {
      // Fetch from all tables in parallel (excluding store products)
      final results = await Future.wait([
        _eventService.getEvents(isPublished: true, limit: 100),
        _fetchAllRiddles(),
        _contentService.getContent(
          contentType: ContentType.vod,
          isPublished: true,
          limit: 100,
        ),
        _contentService.getContent(
          contentType: ContentType.podcast,
          isPublished: true,
          limit: 100,
        ),
      ]);

      // Combine all items
      final List<HomeItem> combinedItems = [];

      // Add events
      if (results[0].isSuccess) {
        final events = (results[0] as Success<List<EventModel>>).data;
        combinedItems.addAll(events.map((e) => HomeItem.fromEvent(e)));
      }

      // Add weekly riddles
      if (results[1].isSuccess) {
        final riddles = (results[1] as Success<List<WeeklyRiddleModel>>).data;
        combinedItems.addAll(riddles.map((r) => HomeItem.fromRiddle(r)));
      }

      // Add VODs
      if (results[2].isSuccess) {
        final vods = (results[2] as Success<List<ContentModel>>).data;
        combinedItems.addAll(vods.map((v) => HomeItem.fromVod(v)));
      }

      // Add podcasts
      if (results[3].isSuccess) {
        final podcasts = (results[3] as Success<List<ContentModel>>).data;
        combinedItems.addAll(podcasts.map((p) => HomeItem.fromPodcast(p)));
      }

      // Sort by createdAt descending
      combinedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Exclude the 4 latest items that are shown at the top
      final latestIds = <String>{};
      if (latestEvent.value != null) latestIds.add(latestEvent.value!.id);
      if (weeklyRiddle.value != null) latestIds.add(weeklyRiddle.value!.id);
      if (latestVod.value != null) latestIds.add(latestVod.value!.id);
      if (latestPodcast.value != null) latestIds.add(latestPodcast.value!.id);

      final filteredItems = combinedItems
          .where((item) => !latestIds.contains(item.id))
          .toList();

      // Apply pagination
      final startIndex = _itemsLoaded;
      final endIndex = startIndex + _pageSize;
      final pageItems = startIndex < filteredItems.length
          ? (endIndex <= filteredItems.length
                ? filteredItems.sublist(startIndex, endIndex)
                : filteredItems.sublist(startIndex))
          : <HomeItem>[];

      if (loadMore) {
        allItems.addAll(pageItems);
      } else {
        allItems.value = pageItems;
      }

      _itemsLoaded += pageItems.length;
      hasMoreData.value = _itemsLoaded < filteredItems.length;
    } catch (e) {
      debugPrint('Error loading all items: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Fetch all weekly riddles
  Future<Result<List<WeeklyRiddleModel>>> _fetchAllRiddles() async {
    try {
      final response = await SupabaseService.client
          .from('weekly_riddles')
          .select('*, question')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(100);

      final riddles = (response as List)
          .map(
            (json) => WeeklyRiddleModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      return Success(riddles);
    } catch (e) {
      debugPrint('Error fetching all riddles: $e');
      return Failure(e.toString());
    }
  }

  /// Load more items for infinite scroll
  Future<void> loadMoreItems() async {
    await loadAllItems(loadMore: true);
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
    scrollController?.removeListener(_onScroll);
    scrollController?.dispose();
    textController.dispose();
    super.onClose();
  }

  /// Load the current active weekly riddle
  Future<void> loadWeeklyRiddle() async {
    isLoadingRiddle.value = true;
    try {
      final result = await _weeklyRiddleService.getCurrentWeeklyRiddle();
      if (result.isSuccess) {
        weeklyRiddle.value = result.dataOrNull;

        // Check if user has already submitted
        if (weeklyRiddle.value != null) {
          await _checkSubmissionStatus();
        }
      } else {
        CommonSnackbar.error(
          result.errorOrNull ?? 'failedToLoadWeeklyRiddle'.tr,
        );
      }
    } catch (e) {
      CommonSnackbar.error('failedToLoadWeeklyRiddle'.tr);
    } finally {
      isLoadingRiddle.value = false;
    }
  }

  /// Check if user has already submitted for the current riddle
  Future<void> _checkSubmissionStatus() async {
    final riddle = weeklyRiddle.value;
    if (riddle == null) {
      hasSubmittedRiddle.value = false;
      return;
    }

    final user = SupabaseService.currentUser;
    if (user == null) {
      hasSubmittedRiddle.value = false;
      return;
    }

    final result = await _weeklyRiddleService.hasUserSubmitted(
      riddleId: riddle.id,
      userId: user.id,
    );

    hasSubmittedRiddle.value = result.isSuccess && (result.dataOrNull ?? false);
  }

  /// Handle riddle submission button tap
  void onRiddleSubmitTap() {
    final context = Get.context;
    if (context == null || weeklyRiddle.value == null) return;

    // Don't allow submission if already submitted
    if (hasSubmittedRiddle.value) {
      return;
    }

    final riddle = weeklyRiddle.value!;
    final solutionType = riddle.solutionType;

    // Check if user has already submitted
    _checkAndShowSubmissionModal(riddle, solutionType);
  }

  Future<void> _checkAndShowSubmissionModal(
    WeeklyRiddleModel riddle,
    RiddleSolutionType solutionType,
  ) async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('userNotFound'.tr);
      return;
    }

    final hasSubmitted = await _weeklyRiddleService.hasUserSubmitted(
      riddleId: riddle.id,
      userId: user.id,
    );

    if (hasSubmitted.isSuccess && hasSubmitted.dataOrNull == true) {
      CommonSnackbar.error('alreadySubmittedRiddle'.tr);
      return;
    }

    _showSubmissionModal(riddle, solutionType);
  }

  void _showSubmissionModal(
    WeeklyRiddleModel riddle,
    RiddleSolutionType solutionType,
  ) {
    final context = Get.context;
    if (context == null) return;

    Widget submissionWidget;

    // Check if it's MCQ
    // MCQ is detected by:
    // 1. Solution type is explicitly "mcq"
    // 2. OR question field exists and has content (multiple choice options)
    final isMcqType = riddle.solutionType == RiddleSolutionType.mcq;
    final hasQuestionField =
        riddle.question != null &&
        ((riddle.question is List && (riddle.question as List).isNotEmpty) ||
            (riddle.question is Map && (riddle.question as Map).isNotEmpty));
    final isMcq = isMcqType || hasQuestionField;

    debugPrint('isMcq: $isMcq');

    if (isMcq) {
      debugPrint('riddle.question: ${riddle.question}');
      // Check if question exists, if not show error or fallback
      if (riddle.question == null ||
          (riddle.question is List && (riddle.question as List).isEmpty) ||
          (riddle.question is Map && (riddle.question as Map).isEmpty)) {
        // If MCQ type but no options, show error message
        CommonSnackbar.error('mcqMissingOptions'.tr);
        return;
      }

      // Convert question to list format for MCQ
      List<Map<String, dynamic>> options;
      if (riddle.question is List) {
        // If question is a List (e.g., ["tables","chair","ring","ladder"])
        // Convert to format: [{'A': 'tables'}, {'B': 'chair'}, ...]
        final questionList = riddle.question as List;
        final letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
        options = List.generate(
          questionList.length,
          (index) => {
            letters[index % letters.length]: questionList[index].toString(),
          },
        );
      } else if (riddle.question is Map) {
        // If question is already a Map, convert entries to list format
        final questionMap = riddle.question as Map<String, dynamic>;
        options = questionMap.entries.map((entry) {
          return {entry.key: entry.value};
        }).toList();
      } else {
        CommonSnackbar.error('invalidQuestionFormat'.tr);
        return;
      }

      submissionWidget = ReusableMcqSubmitModule(
        title: riddle.title,
        description: riddle.description ?? '',
        pointsToEarn: riddle.pointsToEarn,
        options: options,
        onSubmit: (selectedIndex) => submitMcqSolution(riddle, selectedIndex),
      );
    } else {
      switch (solutionType) {
        case RiddleSolutionType.text:
        case RiddleSolutionType.mcq:
          // If it's text type but has question field, it should have been caught above
          // But if somehow it reaches here with mcq type, show text input as fallback
          // (though this shouldn't happen if detection is correct)
          final hasQuestion =
              riddle.question != null &&
              ((riddle.question is List &&
                      (riddle.question as List).isNotEmpty) ||
                  (riddle.question is Map &&
                      (riddle.question as Map).isNotEmpty));
          if (hasQuestion) {
            // This should have been caught above, but handle it just in case
            List<Map<String, dynamic>> options;
            if (riddle.question is List) {
              final questionList = riddle.question as List;
              final letters = [
                'A',
                'B',
                'C',
                'D',
                'E',
                'F',
                'G',
                'H',
                'I',
                'J',
              ];
              options = List.generate(
                questionList.length,
                (index) => {
                  letters[index % letters.length]: questionList[index]
                      .toString(),
                },
              );
            } else {
              final questionMap = riddle.question as Map<String, dynamic>;
              options = questionMap.entries.map((entry) {
                return {entry.key: entry.value};
              }).toList();
            }
            submissionWidget = ReusableMcqSubmitModule(
              title: riddle.title,
              description: riddle.description ?? '',
              pointsToEarn: riddle.pointsToEarn,
              options: options,
              onSubmit: (selectedIndex) =>
                  submitMcqSolution(riddle, selectedIndex),
            );
          } else {
            submissionWidget = ReusableTextSubmitModule(
              title: riddle.title,
              description: riddle.description ?? '',
              pointsToEarn: riddle.pointsToEarn,
              textController: textController,
              isConfirmChecked: isConfirmChecked,
              onPublish: () => submitTextSolution(riddle),
            );
          }
          break;
        case RiddleSolutionType.audio:
          submissionWidget = ReusableAudioSubmitModule(
            title: riddle.title,
            description: riddle.description ?? '',
            pointsToEarn: riddle.pointsToEarn,
            isConfirmChecked: isConfirmChecked,
            uploadedFileName: uploadedFileName,
            isUploadingMedia: isUploadingMedia,
            onPublish1: selectMediaFile,
            onRemove: () {
              selectedMediaFile.value = null;
              uploadedMediaUrl.value = null;
              uploadedFileName.value = null;
            },
            onPublish: () => submitAudioSolution(riddle),
          );
          break;
      }
    }

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
        Get.back();
      },
      content: submissionWidget,
    );
  }

  /// Submit text solution
  Future<void> submitTextSolution(WeeklyRiddleModel riddle) async {
    if (!(textController.text.trim().isNotEmpty)) {
      CommonSnackbar.error('pleaseEnterText'.tr);
      return;
    }
    if (!isConfirmChecked.value) {
      CommonSnackbar.error('pleaseEnableCheckbox'.tr);
      return;
    }

    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('userNotFound'.tr);
      return;
    }

    final submittedAnswer = textController.text.trim();
    final correctAnswer = riddle.answer?.trim() ?? '';

    // Compare answers (case-insensitive)
    final isCorrect =
        submittedAnswer.toLowerCase() == correctAnswer.toLowerCase();

    final data = {
      'solution': submittedAnswer,
      'riddle_id': riddle.id,
      'user_id': user.id,
      'is_correct': isCorrect,
      'points_earned': isCorrect ? riddle.pointsToEarn : 0,
    };

    final result = await _weeklyRiddleService.submitRiddleSolution(
      submission: data,
    );

    if (result.isSuccess) {
      clearFields();
      // Show success or failure modal based on correctness
      if (isCorrect) {
        // Create points transaction and update balance
        await _awardPoints(
          points: riddle.pointsToEarn,
          riddleId: riddle.id,
          description: 'Weekly riddle correct answer',
        );
        _showSuccessModal(riddle.pointsToEarn);
      } else {
        _showFailureModal();
      }
      loadWeeklyRiddle(); // Refresh to update submission status
    } else {
      CommonSnackbar.error('failedToSubmitSolution'.tr);
    }
  }

  /// Submit MCQ solution
  Future<void> submitMcqSolution(
    WeeklyRiddleModel riddle,
    int selectedIndex,
  ) async {
    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('userNotFound'.tr);
      return;
    }

    // Get the selected option value (the actual answer text)
    String selectedOptionValue;
    if (riddle.question is List) {
      // If question is a List, get the value at selectedIndex
      final questionList = riddle.question as List;
      selectedOptionValue = questionList[selectedIndex].toString();
    } else if (riddle.question is Map) {
      // If question is a Map, get the value at selectedIndex
      final questionMap = riddle.question as Map<String, dynamic>;
      selectedOptionValue = questionMap.values
          .elementAt(selectedIndex)
          .toString();
    } else {
      CommonSnackbar.error('Invalid question format');
      return;
    }

    final correctAnswer = riddle.answer?.trim() ?? '';

    // Compare selected option value with correct answer
    final isCorrect =
        selectedOptionValue.toLowerCase() == correctAnswer.toLowerCase();

    final data = {
      'solution': selectedOptionValue,
      'riddle_id': riddle.id,
      'user_id': user.id,
      'is_correct': isCorrect,
      'points_earned': isCorrect ? riddle.pointsToEarn : 0,
    };

    final result = await _weeklyRiddleService.submitRiddleSolution(
      submission: data,
    );

    if (result.isSuccess) {
      clearFields();
      // Update submission status
      hasSubmittedRiddle.value = true;
      // Show success or failure modal based on correctness
      if (isCorrect) {
        // Create points transaction and update balance
        await _awardPoints(
          points: riddle.pointsToEarn,
          riddleId: riddle.id,
          description: 'Weekly riddle correct answer',
        );
        _showSuccessModal(riddle.pointsToEarn);
      } else {
        _showFailureModal();
      }
      loadWeeklyRiddle(); // Refresh to update submission status
    } else {
      CommonSnackbar.error('Failed to submit solution');
    }
  }

  /// Submit audio solution
  Future<void> submitAudioSolution(WeeklyRiddleModel riddle) async {
    if (!(uploadedMediaUrl.value != null &&
        uploadedMediaUrl.value!.isNotEmpty)) {
      CommonSnackbar.error('pleaseSelectAudioFile'.tr);
      return;
    }
    if (!isConfirmChecked.value) {
      CommonSnackbar.error('pleaseEnableCheckbox'.tr);
      return;
    }

    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('userNotFound'.tr);
      return;
    }

    final data = {
      'solution': uploadedMediaUrl.value,
      'riddle_id': riddle.id,
      'user_id': user.id,
    };

    final result = await _weeklyRiddleService.submitRiddleSolution(
      submission: data,
    );

    if (result.isSuccess) {
      clearFields();
      // Update submission status
      hasSubmittedRiddle.value = true;
      // Show submitted modal for audio/video
      _showSubmittedModal();
      loadWeeklyRiddle(); // Refresh to update submission status
    } else {
      CommonSnackbar.error('failedToSubmitSolution'.tr);
    }
  }

  /// Submit video solution
  Future<void> submitVideoSolution(WeeklyRiddleModel riddle) async {
    if (!(uploadedMediaUrl.value != null &&
        uploadedMediaUrl.value!.isNotEmpty)) {
      CommonSnackbar.error('pleaseSelectVideoFile'.tr);
      return;
    }
    if (!isConfirmChecked.value) {
      CommonSnackbar.error('pleaseEnableCheckbox'.tr);
      return;
    }

    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('userNotFound'.tr);
      return;
    }

    final data = {
      'solution': uploadedMediaUrl.value,
      'riddle_id': riddle.id,
      'user_id': user.id,
    };

    final result = await _weeklyRiddleService.submitRiddleSolution(
      submission: data,
    );

    if (result.isSuccess) {
      clearFields();
      // Update submission status
      hasSubmittedRiddle.value = true;
      // Show submitted modal for audio/video
      _showSubmittedModal();
      loadWeeklyRiddle(); // Refresh to update submission status
    } else {
      CommonSnackbar.error('failedToSubmitSolution'.tr);
    }
  }

  /// Show success modal when answer is correct
  void _showSuccessModal(int pointsEarned) {
    final context = Get.context;
    if (context == null) return;

    AlertModal.show(
      context,
      icon: SvgPicture.asset(AppImages.correctAnswerRiddleIcon),
      iconWidth: 50.w,
      iconHeight: 50.h,
      title: 'amazingGotItRight'.tr,
      descriptionWidget: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.textWhiteOpacity70,
          ),
          children: [
            TextSpan(text: 'youveEarned'.tr),
            TextSpan(
              text: '$pointsEarned ${'points'.tr}',
              style: TextStyle(
                color: const Color(0xFF4FC3F7), // Light blue
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: 'forCorrectAnswer'.tr),
          ],
        ),
      ),
      buttonText: 'close'.tr,
    );
  }

  /// Show failure modal when answer is incorrect
  void _showFailureModal() {
    final context = Get.context;
    if (context == null) return;

    AlertModal.show(
      context,
      iconPath: AppImages.incorrectAnswerRiddleIcon,
      // Using failed icon
      iconWidth: 50.w,
      iconHeight: 50.h,
      title: 'answerNotQuiteRight'.tr,
      description: 'maybeNextTime'.tr,
      buttonText: 'close'.tr,
    );
  }

  /// Show submitted modal for audio/video submissions
  void _showSubmittedModal() {
    final context = Get.context;
    if (context == null) return;

    AlertModal.show(
      context,
      iconPath: AppImages.icVerify,
      // Using verify icon for submitted
      iconWidth: 60.w,
      iconHeight: 60.h,
      title: 'answerSubmitted'.tr,
      description: 'reviewingAnswer'.tr,
      buttonText: 'close'.tr,
    );
  }

  Future<void> showUploadTypeDialog() async {
    await Get.dialog(
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
                leading: const Icon(Icons.image, color: AppColors.white),
                title: const Text(
                  'Upload Image',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Get.back();
                  selectImageFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.audiotrack, color: AppColors.white),
                title: const Text(
                  'Upload Audio',
                  style: TextStyle(color: AppColors.white),
                ),
                onTap: () {
                  Get.back();
                  selectMediaFile(); // your existing audio function
                },
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> selectImageFile() async {
    try {
      final source = await _showImageSourceDialog();
      if (source == null) return;

      final XFile? pickedFile = await StorageService.pickImage(source: source);

      if (pickedFile != null) {
        selectedMediaFile.value = File(pickedFile.path);
        uploadedFileName.value = pickedFile.name;
        await _uploadMediaFile(mediaType: MediaType.image);
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

  Future<void> selectMediaFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio);
      if (result != null && result.files.single.path != null) {
        selectedMediaFile.value = File(result.files.single.path!);
        uploadedFileName.value = result.files.single.name;
        await _uploadMediaFile(mediaType: MediaType.audio);
      }
    } catch (e) {
      CommonSnackbar.error('failed_to_select_file'.tr);
    }
  }

  Future<void> _uploadMediaFile({required MediaType mediaType}) async {
    if (selectedMediaFile.value == null) return;

    isUploadingMedia.value = true;
    try {
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return;
      }

      final file = selectedMediaFile.value!;

      final url = await StorageService.uploadMedia(
        mediaFile: file,
        userId: currentUser.id,
        bucketName: 'weekly_riddle_files',
        mediaType: mediaType, // image / video / audio
      );

      if (url != null) {
        uploadedMediaUrl.value = url;
      } else {
        CommonSnackbar.error('failed_to_upload_file'.tr);
        clearFields();
      }
    } catch (e) {
      CommonSnackbar.error('failed_to_upload_file'.tr);
      clearFields();
    } finally {
      isUploadingMedia.value = false;
    }
  }

  void clearFields() {
    selectedMediaFile.value = null;
    uploadedMediaUrl.value = '';
    textController.clear();
    uploadedFileName.value = null;
    isConfirmChecked.value = false;
  }

  // /// Select media file (audio or video)
  // Future<void> selectMediaFile({bool isVideo = false}) async {
  //   try {
  //     final result = await FilePicker.platform.pickFiles(
  //       type: isVideo ? FileType.video : FileType.audio,
  //     );
  //     if (result != null && result.files.single.path != null) {
  //       selectedMediaFile.value = File(result.files.single.path!);
  //       uploadedFileName.value = result.files.single.name;
  //       await _uploadMediaFile(
  //         mediaType: isVideo ? MediaType.video : MediaType.audio,
  //       );
  //     }
  //   } catch (e) {
  //     CommonSnackbar.error('failedToSelectFile'.tr);
  //   }
  // }
  //
  // /// Upload media file to storage
  // Future<void> _uploadMediaFile({required MediaType mediaType}) async {
  //   if (selectedMediaFile.value == null) return;
  //
  //   isUploadingMedia.value = true;
  //   try {
  //     final currentUser = SupabaseService.currentUser;
  //     if (currentUser == null) {
  //       CommonSnackbar.error('userNotFound'.tr);
  //       return;
  //     }
  //
  //     final file = selectedMediaFile.value!;
  //
  //     final url = await StorageService.uploadMedia(
  //       mediaFile: file,
  //       userId: currentUser.id,
  //       bucketName: 'weekly_riddle_files', // Use weekly_riddle_files bucket
  //       mediaType: mediaType,
  //     );
  //
  //     if (url != null) {
  //       uploadedMediaUrl.value = url;
  //     } else {
  //       CommonSnackbar.error('failedToUploadFile'.tr);
  //       clearFields();
  //     }
  //   } catch (e) {
  //     CommonSnackbar.error('failedToUploadFile'.tr);
  //     clearFields();
  //   } finally {
  //     isUploadingMedia.value = false;
  //   }
  // }

  /// Award points to user for correct riddle answer
  Future<void> _awardPoints({
    required int points,
    required String riddleId,
    required String description,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      // Get current user balance
      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) return;

      final currentBalance = currentUser.pointsBalance;
      final balanceAfter = currentBalance + points;

      // Create points transaction
      await SupabaseService.client.from('points_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'earned',
        'amount': points,
        'balance_after': balanceAfter,
        'description': description,
        'related_entity_type': 'weekly_riddle',
        'related_entity_id': riddleId,
      });

      // Update user balance
      await SupabaseService.client
          .from('users')
          .update({'points_balance': balanceAfter})
          .eq('id', user.id);

      // Refresh user data to update balance in app
      await _authRepo.loadCurrentUser();
    } catch (e) {
      debugPrint('Error awarding points: $e');
      // Don't show error to user as submission was successful
    }
  }

  /// Clear all submission fields
  // void clearFields() {
  //   selectedMediaFile.value = null;
  //   uploadedMediaUrl.value = null;
  //   textController.clear();
  //   uploadedFileName.value = null;
  //   isConfirmChecked.value = false;
  // }
}

class PromotionPopup extends StatelessWidget {
  final PromotionModel promotion;
  final VoidCallback onClose;

  const PromotionPopup({
    super.key,
    required this.promotion,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.overlayContainerBackground,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PromotionCard(
            title: promotion.title,
            description: promotion.description ?? '',
            imageUrl: promotion.backgroundImageUrl ?? '',
            interval: promotion.intervalDuration.toString(),
          ),

          /// Floating close button
          Positioned(
            top: -14,
            right: -14,
            child: IconButton(
              onPressed: onClose,
              icon: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
