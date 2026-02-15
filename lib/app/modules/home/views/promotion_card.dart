import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PromotionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String interval;

  const PromotionCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.interval,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Background image
            Image.network(imageUrl, fit: BoxFit.cover),

            /// Soft gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            /// Content
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Samsung Sharp Sans',
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14.sp,
                      fontFamily: 'Samsung Sharp Sans',
                    ),
                  ),
                  // SizedBox(height: 10.h),
                  // Container(
                  //   padding:
                  //   EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  //   decoration: BoxDecoration(
                  //     color: Colors.black.withOpacity(0.4),
                  //     borderRadius: BorderRadius.circular(8.r),
                  //   ),
                  //   child: Text(
                  //     interval,
                  //     style: TextStyle(
                  //       color: const Color(0xFF4FC3F7),
                  //       fontSize: 12.sp,
                  //       fontWeight: FontWeight.w600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
