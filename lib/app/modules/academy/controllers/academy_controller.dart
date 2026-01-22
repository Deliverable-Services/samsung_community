import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/services/academy_service.dart';
import '../../../common/services/storage_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/core/base/base_controller.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/helper_widgets/audio_player/audio_player_manager.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/helper_widgets/event_buying_bottom_bar_modal.dart';
import '../../../data/helper_widgets/video_player/video_player_manager.dart';
import '../../../data/models/academy_content_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../views/academic_audio_submit_module.dart';
import '../views/academic_text_submit_module.dart';
import '../../../data/models/event_model.dart';

class AcademyController extends BaseController {
  final AcademyService academyService;

  final RxInt selectedFilterIndex = 0.obs;
  final RxList<AcademyContentModel> contentList = <AcademyContentModel>[].obs;
  final RxBool isLoadingContent = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isConfirmChecked = false.obs;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxBool isPurchasing = false.obs;
  final RxSet<String> registeredEventIds = <String>{}.obs;
  final RxMap<String, EventModel> workshopEvents = <String, EventModel>{}.obs;

  Timer? searchDebounceTimer;

  static const int pageSize = 10;
  static const int maxCachedItems = 50;
  int currentOffset = 0;

  AcademyController({AcademyService? academyService})
    : academyService = academyService ?? AcademyService();

  final selectedMediaFile = Rxn<File>();
  final uploadedMediaUrl = Rxn<String>();
  final uploadedFileName = Rxn<String>();
  final isUploadingMedia = false.obs;
  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    // Removed scrollController. View will handle pagination via NotificationListener.
    searchController.addListener(_onSearchChanged);
    fetchRegisteredWorkshops();
    loadContent();
  }

  Future<void> fetchRegisteredWorkshops() async {
    final user = SupabaseService.currentUser;
    if (user == null) {
      registeredEventIds.clear();
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('event_registrations')
          .select('event_id')
          .eq('user_id', user.id);

      final ids = (response as List)
          .map((item) => item['event_id'] as String)
          .toSet();

      registeredEventIds.assignAll(ids);
      debugPrint('Fetched ${ids.length} registered event IDs for Academy');
    } catch (e) {
      debugPrint('Error fetching registered workshops: $e');
    }
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
    searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
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
      fetchRegisteredWorkshops(); // Sync registrations on refresh
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
          if (contentList.length > maxCachedItems) {
            contentList.value = contentList.sublist(
              contentList.length - maxCachedItems,
            );
            currentOffset = contentList.length;
          }
        } else {
          contentList.value = newContent;
        }

        if (newContent.length < pageSize) {
          hasMoreData.value = false;
        } else {
          currentOffset = contentList.length;
        }

        // Fetch detailed event data for Zoom Workshops
        final workshopEventIds = newContent
            .where(
              (e) =>
                  e.fileType == AcademyFileType.zoomWorkshop &&
                  e.eventId != null,
            )
            .map((e) => e.eventId!)
            .toList();

        if (workshopEventIds.isNotEmpty) {
          await _fetchWorkshopEvents(workshopEventIds);
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

  Future<void> _fetchWorkshopEvents(List<String> eventIds) async {
    try {
      final response = await SupabaseService.client
          .from('events')
          .select()
          .inFilter('id', eventIds);

      final events = (response as List)
          .map((json) => EventModel.fromJson(json as Map<String, dynamic>))
          .toList();

      for (var event in events) {
        workshopEvents[event.id] = event;
      }
      debugPrint('Fetched ${events.length} detailed events for Academy');
    } catch (e) {
      debugPrint('Error fetching detailed events: $e');
    }
  }

  Future<void> loadMoreContent() async {
    await loadContent(loadMore: true);
  }

  List<AcademyContentModel> get filteredContent {
    return contentList;
  }

  Future<void> _awardAssignmentPoints({
    required int points,
    required String assignmentId,
  }) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) return;

      final newBalance = currentUser.pointsBalance + points;

      await SupabaseService.client.from('points_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'earned',
        'amount': points,
        'balance_after': newBalance,
        'description': 'Correct assignment answer',
        'related_entity_type': 'assignment',
        'related_entity_id': assignmentId,
      });

      await SupabaseService.client
          .from('users')
          .update({'points_balance': newBalance})
          .eq('id', user.id);

      await _authRepo.loadCurrentUser();
    } catch (_) {}
  }

  void clickOnButtonTap({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    /// 🔒 Assignment guard
    if (content.assignmentId == null) {
      CommonSnackbar.error('content_does_not_accept_submissions'.tr);
      return;
    }

    final isAudio = content.taskType?.toUpperCase() == 'Audio'.toUpperCase();
    final isMCQ = content.taskType?.toUpperCase() == 'MCQ'.toUpperCase();
    final isText = content.taskType?.toUpperCase() == 'Text'.toUpperCase();

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
        Get.back();
      },
      content: isAudio
          ? AcademicAudioSubmitModule(
              title: content.title,
              description: content.description ?? '',
              pointsToEarn: content.pointsToEarn,
              onPublish1: showUploadTypeDialog,
              onPublish: () => clickOnSendAudio(content: content),
            )
          : isText
          ? AcademicTextSubmitModule(
              title: content.title,
              description: content.description ?? '',
              pointsToEarn: content.pointsToEarn,
              onPublish: () => clickOnText(content: content),
            )
          : AcademicMcqSubmitModule(
              title: content.title,
              description: content.description ?? '',
              pointsToEarn: content.pointsToEarn,
              options: content.answers ?? [],
              onSubmit: (selectedIndex) =>
                  clickOnMcq(content: content, selectedIndex: selectedIndex),
            ),
    );
  }

  void clickOnSendAudio({required AcademyContentModel content}) async {
    if (uploadedMediaUrl.value?.isEmpty ?? true) {
      CommonSnackbar.error('please_select_audio_file'.tr);
      return;
    }
    if (!isConfirmChecked.value) {
      CommonSnackbar.error('please_enable_checkbox'.tr);
      return;
    }

    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) return;

    final data = {
      'solution': uploadedMediaUrl.value,
      'assignment_id': content.assignmentId,
      'user_id': user.id,
    };

    final result = await AcademyService().assignmentSubmissions(content: data);

    if (result is Success) {
      clearFields();
      _updateSubmissionStatus(content.academyContentId, user.id);
      _showSubmittedModal(); // 👈 SAME AS RIDDLE
      loadContent();
    } else {
      CommonSnackbar.error('failed_to_publish_audio'.tr);
    }
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

  void clickOnText({required AcademyContentModel content}) async {
    if (textController.text.trim().isEmpty) {
      CommonSnackbar.error('please_enter_text'.tr);
      return;
    }
    if (!isConfirmChecked.value) {
      CommonSnackbar.error('please_enable_checkbox'.tr);
      return;
    }

    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) return;

    final submittedAnswer = textController.text.trim();
    final correctAnswer = content.answer?.trim() ?? '';

    final isCorrect =
        submittedAnswer.toLowerCase() == correctAnswer.toLowerCase();

    final data = {
      'solution': submittedAnswer,
      'assignment_id': content.assignmentId,
      'user_id': user.id,
      'is_correct': isCorrect,
      'total_points_to_win': isCorrect ? content.pointsToEarn : 0,
    };

    final result = await AcademyService().assignmentSubmissions(content: data);

    if (result is Success) {
      clearFields();
      _updateSubmissionStatus(content.academyContentId, user.id);

      if (isCorrect) {
        await _awardAssignmentPoints(
          points: content.pointsToEarn,
          assignmentId: content.assignmentId!,
        );
        _showSuccessModal(content.pointsToEarn);
      } else {
        _showFailureModal();
      }

      loadContent();
    } else {
      CommonSnackbar.error('failed_to_submit_answer'.tr);
    }
  }

  void clickOnMcq({
    required AcademyContentModel content,
    required int selectedIndex,
  }) async {
    Get.back();

    final user = SupabaseService.currentUser;
    if (user == null) return;

    final answersList = content.answers!;

    /// ✅ selected option value
    final selectedValue = answersList[selectedIndex]['option']
        ?.toString()
        .trim();

    /// ✅ correct answer from LAST object
    final correctAnswer = answersList.last['correct_answer']?.toString().trim();

    print('SELECTED => "$selectedValue"');
    print('CORRECT  => "$correctAnswer"');

    if (selectedValue == null || correctAnswer == null) {
      CommonSnackbar.error('invalid_mcq_data'.tr);
      return;
    }

    final isCorrect =
        selectedValue.toLowerCase() == correctAnswer.toLowerCase();

    final data = {
      'solution': selectedValue, // ✅ save value
      'assignment_id': content.assignmentId,
      'user_id': user.id,
      'is_correct': isCorrect,
      'total_points_to_win': isCorrect ? content.pointsToEarn : 0,
    };

    final result = await AcademyService().assignmentSubmissions(content: data);

    if (result is Success) {
      clearFields();
      _updateSubmissionStatus(content.academyContentId, user.id);

      if (isCorrect) {
        await _awardAssignmentPoints(
          points: content.pointsToEarn,
          assignmentId: content.assignmentId!,
        );
        _showSuccessModal(content.pointsToEarn);
      } else {
        _showFailureModal();
      }

      loadContent();
    } else {
      CommonSnackbar.error('failed_to_submit_answer'.tr);
    }
  }

  void clickOnButtonTap2({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    /// 🔒 Assignment guard
    if (content.assignmentId == null) {
      CommonSnackbar.error('content_does_not_accept_submissions'.tr);
      return;
    }

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
        Get.back();
      },
      content: AcademicTextSubmitModule(
        title: content.title,
        description: content.description ?? '',
        pointsToEarn: content.pointsToEarn,
        onPublish: () async {
          if (!(textController.text.trim().isNotEmpty)) {
            CommonSnackbar.error('please_enter_text'.tr);
            return;
          }
          if (!isConfirmChecked.value) {
            CommonSnackbar.error('please_enable_checkbox'.tr);
            return;
          }

          Get.back();

          final user = SupabaseService.currentUser;
          if (user == null) {
            CommonSnackbar.error('user_not_found'.tr);
            return;
          }

          final data = {
            'solution': textController.text,
            'assignment_id': content.assignmentId, // ✅ now guaranteed non-null
            'user_id': user.id,
          };

          final result = await AcademyService().assignmentSubmissions(
            content: data,
          );

          if (result is Success<Map<String, dynamic>>) {
            clearFields();
            final user = SupabaseService.currentUser;
            if (user != null) {
              _updateSubmissionStatus(content.academyContentId, user.id);
            }
            CommonSnackbar.success('text_published_successfully'.tr);
            loadContent();
          } else {
            CommonSnackbar.error('failed_to_publish_text'.tr);
          }
        },
      ),
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
        bucketName: 'assignments',
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
    loadMoreContent();
  }

  void _updateSubmissionStatus(String contentId, String userId) {
    final index = contentList.indexWhere(
      (content) => content.academyContentId == contentId,
    );
    if (index != -1) {
      final content = contentList[index];
      final currentSubmissionIds = List<String>.from(
        content.submissionUserIds ?? [],
      );
      if (!currentSubmissionIds.contains(userId)) {
        currentSubmissionIds.add(userId);
        final updatedContent = AcademyContentModel(
          academyContentId: content.academyContentId,
          title: content.title,
          description: content.description,
          fileType: content.fileType,
          mediaFileUrl: content.mediaFileUrl,
          pointsToEarn: content.pointsToEarn,
          isPublished: content.isPublished,
          createdAt: content.createdAt,
          updatedAt: content.updatedAt,
          createdBy: content.createdBy,
          creatorUserId: content.creatorUserId,
          creatorFullName: content.creatorFullName,
          creatorPhoneNumber: content.creatorPhoneNumber,
          creatorProfilePictureUrl: content.creatorProfilePictureUrl,
          creatorRole: content.creatorRole,
          creatorStatus: content.creatorStatus,
          eventId: content.eventId,
          eventDate: content.eventDate,
          durationMinutes: content.durationMinutes,
          zoomLink: content.zoomLink,
          imageUrl: content.imageUrl,
          assignmentId: content.assignmentId,
          taskName: content.taskName,
          taskType: content.taskType,
          assignmentDescription: content.assignmentDescription,
          taskStartDate: content.taskStartDate,
          taskEndDate: content.taskEndDate,
          taskEndTime: content.taskEndTime,
          totalPointsToWin: content.totalPointsToWin,
          answers: content.answers,
          assignmentCreatorUserId: content.assignmentCreatorUserId,
          assignmentCreatedAt: content.assignmentCreatedAt,
          assignmentUpdatedAt: content.assignmentUpdatedAt,
          submissionUserIds: currentSubmissionIds,
        );
        contentList[index] = updatedContent;
      }
    }
  }

  void clickOnMoreDetails({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    final event = content.eventId != null
        ? workshopEvents[content.eventId]
        : null;

    /// 🔒 Zoom link guard (checks both content and associated event)
    if (content.zoomLink == null && (event == null || event.zoomLink == null)) {
      CommonSnackbar.error('content_does_not_accept_submissions'.tr);
      return;
    }

    final user = SupabaseService.currentUser;
    final bool isRegistered =
        user != null &&
        ((content.submissionUserIds?.contains(user.id) ?? false) ||
            (content.eventId != null &&
                registeredEventIds.contains(content.eventId!)));

    // Format timing
    String timingString = '';
    if (event != null &&
        (event.zoomStartTime != null || event.zoomEndTime != null)) {
      timingString =
          "${event.zoomStartTime ?? ''}${event.zoomEndTime != null ? ' - ${event.zoomEndTime}' : ''}";
    } else {
      timingString = content.taskEndTime ?? '';
    }

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
      },
      content: EventBuyingBottomBarModal(
        text: isRegistered ? 'copyZoomLink'.tr : 'registration'.tr,
        title: event?.title ?? content.title,
        description: event?.description ?? content.description ?? '',
        points: "${event?.costPoints ?? content.pointsToEarn}",
        date: event?.eventDate != null
            ? DateFormat('dd.MM.yyyy').format(event!.eventDate)
            : (content.eventDate != null
                  ? DateFormat('dd.MM.yyyy').format(content.eventDate!)
                  : ''),
        timing: timingString,
        mediaUrl: event?.imageUrl ?? content.mediaFileUrl,
        isVideo: false,
        onButtonTap: () {
          if (isRegistered) {
            final link = event?.zoomLink ?? content.zoomLink ?? '';
            if (link.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: link));
              CommonSnackbar.success('Zoom link copied to clipboard');
            } else {
              CommonSnackbar.error('Zoom link not available');
            }
          } else {
            Get.back();
            clickOnRegistration(content: content);
          }
        },
      ),
    );
  }

  void clickOnRegistration({required AcademyContentModel content}) async {
    final context = Get.context;
    if (context == null) return;

    if (isPurchasing.value) return;

    final user = SupabaseService.currentUser;
    if (user == null) {
      CommonSnackbar.error('user_not_found'.tr);
      return;
    }

    final currentUser = _authRepo.currentUser.value;
    if (currentUser == null) return;

    final event = content.eventId != null
        ? workshopEvents[content.eventId]
        : null;
    final cost = event?.costPoints ?? content.pointsToEarn;

    if (currentUser.pointsBalance >= cost) {
      await registerWorkshopWithPoints(content);
    } else {
      // Close detail modal if open
      if (Get.isBottomSheetOpen ?? false) Get.back();

      clickOnInsufficientPoints(content: content);
    }
  }

  Future<void> registerWorkshopWithPoints(AcademyContentModel content) async {
    if (isPurchasing.value) return;

    final workshopEventId = content.eventId;
    if (workshopEventId == null) {
      CommonSnackbar.error(
        'This workshop does not have an associated event ID.',
      );
      return;
    }

    isPurchasing.value = true;

    try {
      final user = SupabaseService.currentUser;
      if (user == null) return;

      final currentUser = _authRepo.currentUser.value;
      if (currentUser == null) return;

      final event = content.eventId != null
          ? workshopEvents[content.eventId]
          : null;
      final cost = event?.costPoints ?? content.pointsToEarn;
      final balanceAfter = currentUser.pointsBalance - cost;

      // Check if already registered
      final existingRegistration = await SupabaseService.client
          .from('event_registrations')
          .select('id')
          .eq('event_id', workshopEventId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingRegistration != null) {
        _updateSubmissionStatus(content.academyContentId, user.id);
        CommonSnackbar.success('You are already registered for this workshop');
        if (Get.isBottomSheetOpen ?? false) Get.back();
        clickOnSuccess(content: content);
        return;
      }

      // 1. Create Event Registration
      final registrationResponse = await SupabaseService.client
          .from('event_registrations')
          .insert({
            'event_id': workshopEventId,
            'user_id': user.id,
            'payment_method': 'points',
            'points_paid': cost,
            'status': 'registered',
            'registered_at': DateTime.now().toUtc().toIso8601String(),
          })
          .select('id')
          .single();

      final registrationId = registrationResponse['id'] as String;

      // 2. Create Points Transaction
      await SupabaseService.client.from('points_transactions').insert({
        'user_id': user.id,
        'transaction_type': 'spent',
        'amount': -cost,
        'balance_after': balanceAfter,
        'description':
            'Workshop Registration: ${event?.title ?? content.title}',
        'related_entity_type': 'event_registration',
        'related_entity_id': registrationId,
      });

      // 3. Update User Balance
      await SupabaseService.client
          .from('users')
          .update({'points_balance': balanceAfter})
          .eq('id', user.id);

      // 4. Mark as registered (using existing submission status logic for local UI update)
      _updateSubmissionStatus(content.academyContentId, user.id);
      if (content.eventId != null) {
        registeredEventIds.add(content.eventId!);
      }

      // 5. Refresh Data
      await fetchRegisteredWorkshops();
      await _refreshUserData();
      // Reload content to ensure everything is in sync
      loadContent();

      // Show success
      if (Get.isBottomSheetOpen ?? false) Get.back();
      clickOnSuccess(content: content);
    } catch (e) {
      debugPrint('Error registering workshop: $e');
      CommonSnackbar.error('Error: $e');
      // Show unsuccessful
      if (Get.isBottomSheetOpen ?? false) Get.back();
      clickOnUnsuccessful(content: content);
    } finally {
      isPurchasing.value = false;
    }
  }

  void clickOnInsufficientPoints({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clickOnUnsuccessful(content: content);
      },
      content: RegistrationSuccessModal(
        icon: AppImages.notEnoughPointsIcon,
        title: "youDoNotHaveEnoughPoints".tr,
        text: "payByCreditCard".tr,
        description: 'yourBalanceIsTooLowToCompleteThisAction'.tr,
        onButtonTap: () {
          // Close insufficient modal
          Get.back();
          // Mock credit card success for now as per instructions (or direct to success)
          clickOnSuccess(content: content);
        },
      ),
    );
  }

  void clickOnUnsuccessful({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: RegistrationSuccessModal(
        icon: AppImages.icFailed,
        title: "Registration Unsuccessful",
        text: "close".tr,
        description: "The registration process was cancelled or failed.",
        onButtonTap: () {
          Get.back();
        },
      ),
    );
  }

  void clickOnSuccess({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      content: RegistrationSuccessModal(
        icon: AppImages.icVerify,
        title: "registrationSuccessful".tr,
        text: "close".tr,
        description: 'theZoomLinkWillBeUpdatedPriorToTheLiveSession'.tr,
        onButtonTap: () {
          Get.back();
          // Future: may show starting soon based on date
          // clickOnLiveVideo(content: content);
        },
      ),
    );
  }

  void clickOnLiveVideo({required AcademyContentModel content}) {
    final context = Get.context;
    if (context == null) return;

    /// 🔒 Assignment guard
    if (content.zoomLink == null) {
      CommonSnackbar.error('content_does_not_accept_submissions'.tr);
      return;
    }
    BottomSheetModal.show(
      context,
      buttonType: BottomSheetButtonType.close,
      onClose: () {
        clearFields();
        Get.back();
      },
      content: RegistrationSuccessModal(
        icon: AppImages.icLiveVideoStartingSoon,
        title: "liveVideoStartingSoon".tr,
        text: "joinLive".tr,
        description: 'anExclusiveLiveSessionIsAbout'.tr,
        onButtonTap: () {
          joinZoomMeeting(content.zoomLink ?? '');
          Get.back();
        },
      ),
    );
  }

  Future<void> joinZoomMeeting(String zoomUrl) async {
    if (zoomUrl.isEmpty) return;

    final Uri uri = Uri.parse(zoomUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Opens Zoom app if installed
      );
    } else {
      throw 'Could not launch Zoom link';
    }
  }

  /* Future<void> joinZoomMeetingSmart(String zoomUrl) async {
    final Uri zoomAppUri = Uri.parse("zoomus://zoom.us/join?confno=MEETING_ID");
    final Uri webUri = Uri.parse(zoomUrl);

    if (await canLaunchUrl(zoomAppUri)) {
      await launchUrl(zoomAppUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }*/
}
