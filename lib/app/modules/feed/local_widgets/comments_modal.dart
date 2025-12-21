import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../common/services/content_interaction_service.dart';
import '../../../common/services/supabase_service.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/core/utils/result.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model copy.dart';

class CommentsModal extends StatefulWidget {
  final String contentId;
  final Function(String) onAddComment;

  const CommentsModal({
    super.key,
    required this.contentId,
    required this.onAddComment,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final ContentInteractionService _interactionService =
      ContentInteractionService();
  final TextEditingController _commentController = TextEditingController();
  final RxList<CommentModel> _comments = <CommentModel>[].obs;
  final RxMap<String, UserModel> _userMap = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    _isLoading.value = true;
    try {
      final result = await _interactionService.getComments(
        contentId: widget.contentId,
      );

      if (result.isSuccess) {
        _comments.value = result.dataOrNull ?? [];
        await _loadUsers();
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUsers() async {
    for (final comment in _comments) {
      if (!_userMap.containsKey(comment.userId)) {
        final userResult = await _getUserDetail(comment.userId);
        if (userResult.isSuccess && userResult.dataOrNull != null) {
          _userMap[comment.userId] = userResult.dataOrNull!;
        }
      }
    }
  }

  Future<Result<UserModel?>> _getUserDetail(String userId) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        return Success(UserModel.fromJson(response));
      } else {
        return const Success(null);
      }
    } catch (e) {
      return Failure(e.toString());
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      return;
    }

    _isSubmitting.value = true;
    try {
      widget.onAddComment(_commentController.text.trim());
      _commentController.clear();
      await _loadComments();
    } finally {
      _isSubmitting.value = false;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'viewAllComments'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textWhite,
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: Obx(() {
              if (_isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_comments.isEmpty) {
                return Center(
                  child: Text(
                    'No comments yet',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textWhiteOpacity60,
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  final user = _userMap[comment.userId];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32.w,
                          height: 32.h,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: user?.profilePictureUrl?.isNotEmpty == true
                                ? CachedNetworkImage(
                                    imageUrl: user!.profilePictureUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        Image.asset(AppImages.avatar),
                                  )
                                : Image.asset(AppImages.avatar),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user?.fullName ?? 'Unknown',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    DateFormat(
                                      'dd/MM/yy',
                                    ).format(comment.createdAt),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textWhiteOpacity60,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                comment.content,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textWhiteOpacity70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              SizedBox(
                width: 32.w,
                height: 32.h,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: SupabaseService.currentUser != null
                      ? Image.asset(AppImages.avatar)
                      : Image.asset(AppImages.avatar),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  style: TextStyle(
                    fontFamily: 'Samsung Sharp Sans',
                    fontSize: 14.sp,
                    color: AppColors.textWhiteOpacity60,
                  ),
                  decoration: InputDecoration(
                    hintText: 'addComment'.tr,
                    hintStyle: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontSize: 14.sp,
                      color: AppColors.textWhiteOpacity40,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _submitComment(),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() {
                return IconButton(
                  onPressed: _isSubmitting.value ? null : _submitComment,
                  icon: _isSubmitting.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send,
                          color: AppColors.accentBlue,
                          size: 20.sp,
                        ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
