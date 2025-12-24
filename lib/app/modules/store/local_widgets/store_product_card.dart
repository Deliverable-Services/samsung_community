import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/event_launch_card.dart';
import '../../../data/models/store_product_model.dart';

class StoreProductCard extends StatelessWidget {
  final StoreProductModel product;
  final VoidCallback? onTap;

  const StoreProductCard({super.key, required this.product, this.onTap});

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yy');
    final dateStr = dateFormat.format(product.createdAt);

    return GestureDetector(
      onTap: onTap,
      child: EventLaunchCard(
        imagePath: AppImages.eventRegisteration,
        imagePathNetwork: product.imageUrl,
        title: product.name,
        description: product.description ?? '',
        buttonText: 'detailsPurchase'.tr,
        showButton: true,
        exclusiveEvent: true,
        text: dateStr,
        onButtonTap: onTap,
        labels: [
          EventLabel(
            widget: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  AppImages.pointsIcon,
                  width: 18.w,
                  height: 18.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(width: 3.w),
                Text(
                  '${'homePoints'.tr}${_formatPoints(product.costPoints)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    letterSpacing: 0,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            extraPadding: EdgeInsets.symmetric(vertical: -2.5.w),
          ),
          if (product.quantityInStock > 0)
            EventLabel(text: '${product.quantityInStock} ${'remaining'.tr}'),
        ],
      ),
    );
  }
}
