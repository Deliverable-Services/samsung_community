import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/common_loader.dart';
import '../controllers/store_controller.dart';
import 'store_product_card.dart';

class StoreProductsList extends GetView<StoreController> {
  const StoreProductsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingProducts.value &&
          controller.filteredProducts.isEmpty) {
        return const CommonSliverFillLoader();
      }

      final products = controller.filteredProducts;

      if (products.isEmpty && !controller.isLoadingProducts.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20.h),
              child: Text(
                'noProducts'.tr,
                style: TextStyle(
                  fontFamily: 'Samsung Sharp Sans',
                  fontSize: 14.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index < products.length) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: StoreProductCard(
                    product: products[index],
                    onTap: () {
                      // TODO: Navigate to product details
                    },
                  ),
                );
              }
              if (index == products.length && controller.isLoadingMore.value) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: const CommonLoader(),
                );
              }
              return null;
            },
            childCount:
                products.length + (controller.isLoadingMore.value ? 1 : 0),
          ),
        ),
      );
    });
  }
}

