import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../data/constants/app_colors.dart';
import '../../../../data/constants/app_images.dart';
import '../../controllers/feed_controller.dart';

class FeedCardCommentInput extends StatefulWidget {
  final String contentId;
  final VoidCallback? onComment;

  const FeedCardCommentInput({
    super.key,
    required this.contentId,
    this.onComment,
  });

  @override
  State<FeedCardCommentInput> createState() => _FeedCardCommentInputState();
}

class _FeedCardCommentInputState extends State<FeedCardCommentInput> {
  final TextEditingController _commentController = TextEditingController();
  final FeedController _controller = Get.find<FeedController>();
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
      _controller.addComment(widget.contentId, _commentController.text.trim());
      _commentController.clear();
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
          child: Image.asset(
            AppImages.avatar,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fitHeight,
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
                constraints: BoxConstraints(
                  minWidth: 24.w,
                  minHeight: 24.h,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

