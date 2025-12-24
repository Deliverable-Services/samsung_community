import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/store_controller.dart';
import 'store_tab_button.dart';

class StoreTabs extends GetView<StoreController> {
  const StoreTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedTabIndex.value;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          children: [
            Expanded(
              child: StoreTabButton(
                text: 'allProducts'.tr,
                isActive: index == 0,
                onTap: () => controller.setTab(0),
              ),
            ),
            Expanded(
              child: StoreTabButton(
                text: 'myPurchases'.tr,
                isActive: index == 1,
                onTap: () => controller.setTab(1),
              ),
            ),
          ],
        ),
      );
    });
  }
}

