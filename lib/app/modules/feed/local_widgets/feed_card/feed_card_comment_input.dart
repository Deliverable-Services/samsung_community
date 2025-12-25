import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:cached_network_image/cached_network_image.dart';

import '../../../../repository/auth_repo/auth_repo.dart';
import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';

class FeedCardCommentInput extends StatefulWidget {
  final String contentId;
  final VoidCallback? onComment;
  final Function(String, String)? onAddComment;

  const FeedCardCommentInput({
    super.key,
    required this.contentId,
    this.onComment,
    this.onAddComment,
  });

  @override
  State<FeedCardCommentInput> createState() => _FeedCardCommentInputState();
}

class _FeedCardCommentInputState extends State<FeedCardCommentInput> {
  final TextEditingController _commentController = TextEditingController();
  final RxBool _hasText = false.obs;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    _hasText.value = _commentController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _commentController.removeListener(_onTextChanged);
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    if (_commentController.text.trim().isNotEmpty) {
      final commentText = _commentController.text.trim();
      _commentController.clear();
      widget.onAddComment?.call(widget.contentId, commentText);
      widget.onComment?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Obx(() {
              final authRepo = Get.find<AuthRepo>();
              final currentUser = authRepo.currentUser.value;
              final profilePictureUrl = currentUser?.profilePictureUrl;

              if (profilePictureUrl != null && profilePictureUrl.isNotEmpty) {
                return CachedNetworkImage(
                  imageUrl: profilePictureUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Image.asset(
                    AppImages.avatar,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }
              return Image.asset(
                AppImages.avatar,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              );
            }),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextField(
            controller: _commentController,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontSize: 12.sp,
              color: AppColors.textWhiteOpacity60,
            ),
            decoration: InputDecoration(
              hintText: 'addComment'.tr,
              hintStyle: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 12.sp,
                color: AppColors.textWhiteOpacity40,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onSubmitted: (_) => _submitComment(),
          ),
        ),
        SizedBox(width: 8.w),
        Obx(() {
          return Opacity(
            opacity: _hasText.value ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !_hasText.value,
              child: IconButton(
                onPressed: _submitComment,
                icon: Icon(
                  Icons.send,
                  color: AppColors.accentBlue,
                  size: 16.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
              ),
            ),
          );
        }),
      ],
    );
  }
}
