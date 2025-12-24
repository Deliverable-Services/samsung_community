import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final bool isFromCurrentUser;
  final String? avatarUrl;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    this.avatarUrl,
  });

  Widget _buildMessageTail({required bool isRight, required Color color}) {
    return Positioned(
      bottom: isRight ? 0 : -1,
      right: isRight ? -1 : null,
      left: isRight ? null : -1,
      child: Transform.rotate(
        angle: isRight ? 180.98 * math.pi / 94 : 42.98 * math.pi / 80,
        child: CustomPaint(
          size: Size(6.9282036245285035.w, 7.911932516109286.h),
          painter: _PolygonPainter(color: color),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isFromCurrentUser) {
      return Padding(
        padding: EdgeInsets.only(bottom: 20.h, left: 45.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(11.r),
                        topRight: Radius.circular(11.r),
                        bottomLeft: Radius.circular(11.r),
                        bottomRight: Radius.circular(11.r),
                      ),
                      color: const Color(0xFF2189FF),
                    ),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: 'Samsung Sharp Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  _buildMessageTail(
                    isRight: true,
                    color: const Color(0xFF2189FF),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h, right: 45.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.overlayContainerBackground,
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(AppImages.avatar, fit: BoxFit.cover);
                      },
                    )
                  : Image.asset(AppImages.avatar, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(11.r),
                      topRight: Radius.circular(11.r),
                      bottomLeft: Radius.circular(11.r),
                      bottomRight: Radius.circular(11.r),
                    ),
                    color: AppColors.overlayContainerBackground,
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      fontFamily: 'Samsung Sharp Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: AppColors.white,
                    ),
                  ),
                ),
                _buildMessageTail(
                  isRight: false,
                  color: AppColors.overlayContainerBackground,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolygonPainter extends CustomPainter {
  final Color color;

  _PolygonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(0, size.height * 0.4, 0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
