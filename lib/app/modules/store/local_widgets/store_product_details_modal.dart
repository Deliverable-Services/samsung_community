import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_button.dart';
import '../../../data/constants/app_colors.dart';
import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/helper_widgets/event_tablet.dart';
import '../../../data/helper_widgets/video_player/video_player_widget.dart';
import '../../../data/models/store_product_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/store_controller.dart';
import 'shipping_address_modal.dart';

class StoreProductDetailsModal extends StatelessWidget {
  final StoreProductModel product;
  final bool hideBuyButton;

  const StoreProductDetailsModal({
    super.key,
    required this.product,
    this.hideBuyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    return _StoreProductDetailsModalContent(
      product: product,
      hideBuyButton: hideBuyButton,
      controller: controller,
    );
  }
}

class _StoreProductDetailsModalContent extends StatelessWidget {
  final StoreProductModel product;
  final bool hideBuyButton;
  final StoreController controller;

  const _StoreProductDetailsModalContent({
    required this.product,
    required this.hideBuyButton,
    required this.controller,
  });

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _handlePurchase(BuildContext context) {
    try {
      final authRepo = Get.find<AuthRepo>();
      final currentPoints = authRepo.currentUser.value?.pointsBalance ?? 0;

      if (currentPoints < product.costPoints) {
        AlertModal.show(
          context,
          icon: SvgPicture.asset(
            AppImages.notEnoughPointsIcon,
            width: 50.w,
            height: 50.h,
            fit: BoxFit.contain,
          ),
          title: 'insufficientPoints'.tr,
          description: 'insufficientPointsMessage'.tr,
          buttonText: 'close'.tr,
          isScrollControlled: false,
        );
        return;
      }

      Get.back();
      ShippingAddressModal.show(
        context,
        product: product,
        onConfirm: () {
          // Order created successfully
        },
      );
    } catch (e) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MM/dd/yy');
    final dateStr = dateFormat.format(product.createdAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventTablet(text: dateStr),
              const SizedBox.shrink(),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            product.name,
            style: TextStyle(
              fontFamily: 'Samsung Sharp Sans',
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              height: 24 / 16,
              letterSpacing: 0,
              color: AppColors.white,
            ),
            textScaler: const TextScaler.linear(1.0),
          ),
          SizedBox(height: 8.h),
          if (product.description != null && product.description!.isNotEmpty)
            Text(
              product.description!,
              style: TextStyle(
                fontFamily: 'Samsung Sharp Sans',
                fontSize: 14.sp,
                height: 22 / 14,
                letterSpacing: 0,
                color: AppColors.white,
              ),
              textScaler: const TextScaler.linear(1.0),
            ),
          SizedBox(height: 16.h),
          IntrinsicWidth(
            child: EventTablet(
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
          ),
          SizedBox(height: 20.h),
          if (product.descriptionVideoUrl != null &&
              product.descriptionVideoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: VideoPlayerWidget(
                videoUrl: product.descriptionVideoUrl,
                tag: 'store_product_${product.id}',
              ),
            )
          else if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 200.h,
                  color: AppColors.backgroundDark,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    height: 200.h,
                    color: AppColors.backgroundDark,
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported,
                        color: AppColors.textWhiteOpacity60,
                        size: 48.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (!hideBuyButton) ...[
            SizedBox(height: 24.h),
            Obx(
              () => AppButton(
                onTap: controller.isCreatingOrder.value
                    ? null
                    : () {
                        _handlePurchase(context);
                      },
                text: controller.isCreatingOrder.value
                    ? 'Processing...'
                    : '${'buying'.tr} ${'homePoints'.tr}${_formatPoints(product.costPoints)}',
                width: double.infinity,
                isEnabled: !controller.isCreatingOrder.value,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
