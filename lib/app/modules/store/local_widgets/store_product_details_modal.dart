import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/constants/app_images.dart';
import '../../../data/helper_widgets/alert_modal.dart';
import '../../../data/models/store_product_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/store_controller.dart';
import 'product_detail.dart';
import 'shipping_address_modal.dart';

class StoreProductDetailsModal extends StatelessWidget {
  final StoreProductModel product;
  final bool hideBuyButton;

  const StoreProductDetailsModal({
    super.key,
    required this.product,
    this.hideBuyButton = false,
  });

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

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoreController>();
    final dateFormat = DateFormat('MM/dd/yy');
    final dateStr = dateFormat.format(product.createdAt);

    final List<String> middleTablets = [];
    if (product.costPoints > 0) {
      middleTablets.add('${'points'.tr} ${_formatPoints(product.costPoints)}');
    }

    final String? mediaUrl =
        product.descriptionVideoUrl != null &&
            product.descriptionVideoUrl!.isNotEmpty
        ? product.descriptionVideoUrl
        : product.imageUrl;

    final bool isVideo =
        product.descriptionVideoUrl != null &&
        product.descriptionVideoUrl!.isNotEmpty;

    String? buttonText;
    if (!hideBuyButton) {
      buttonText = controller.isCreatingOrder.value
          ? 'Processing...'
          : '${'buying'.tr} ${'homePoints'.tr}${_formatPoints(product.costPoints)}';
    }

    return Obx(
      () => ProductDetail(
        topTablets: [dateStr],
        title: product.name,
        description: product.description,
        middleTablets: middleTablets.isNotEmpty ? middleTablets : null,
        mediaUrl: mediaUrl,
        isVideo: isVideo,
        bottomButtonText: buttonText,
        bottomButtonIconPath: null,
        bottomButtonOnTap: hideBuyButton
            ? null
            : () => _handlePurchase(context),
        isButtonEnabled: !controller.isCreatingOrder.value,
        tag: 'store_product_${product.id}',
      ),
    );
  }
}
