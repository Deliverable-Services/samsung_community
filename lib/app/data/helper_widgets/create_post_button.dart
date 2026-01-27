import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/services/create_post_service.dart';
import '../constants/app_images.dart';

class CreatePostButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onFailure;
  final double? bottomOffset;
  final double? rightOffset;

  const CreatePostButton({
    super.key,
    this.onSuccess,
    this.onFailure,
    this.bottomOffset,
    this.rightOffset,
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
      bottom: widget.bottomOffset ?? 10.h,
      right: widget.rightOffset ?? 0.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // BIG IMAGE (visual only)
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 50,
                  color: const Color(0xFF57BBEB).withOpacity(0.45),
                ),
              ],
            ),
            child: Image.asset(AppImages.createPostIcon),
          ),

          // SMALL TAP AREA 66x50)
          GestureDetector(
            onTap: _handleTap,
            child: Container(
              width: 66.w,
              height: 66.h,
              color: Colors.transparent, // important
            ),
          ),
        ],
      ),
    );
  }
}
