import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/services/create_post_service.dart';
import '../constants/app_images.dart';

class CreatePostButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;
  final double? bottomOffset;

  const CreatePostButton({
    super.key,
    this.onSuccess,
    this.onFailure,
    this.bottomOffset,
  });

  @override
  State<CreatePostButton> createState() => _CreatePostButtonState();
}

class _CreatePostButtonState extends State<CreatePostButton> {
  late final CreatePostService _createPostService;

  @override
  void initState() {
    super.initState();
    _createPostService = CreatePostService();
  }

  @override
  void dispose() {
    _createPostService.dispose();
    super.dispose();
  }

  void _handleTap() {
    _createPostService.showCreatePostModal(
      onSuccess: widget.onSuccess ?? () {},
      onFailure: widget.onFailure ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.bottomOffset ?? -70.h,
      right: -50.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BIG IMAGE (visual only)
          SizedBox(
            width: 250.w,
            height: 250.h,
            child: Image.asset(AppImages.createPostIcon),
          ),

          // SMALL TAP AREA (50x50)
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 34.w,
              height: 34.h,
              color: Colors.transparent, // important
            ),
          ),
        ],
      ),
    );
  }
}
