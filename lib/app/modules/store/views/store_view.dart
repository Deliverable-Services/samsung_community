import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/constants/app_colors.dart';
import '../../../data/helper_widgets/navbar.dart';
import '../../../data/helper_widgets/bottom_nav_bar.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../controllers/store_controller.dart';
import '../local_widgets/store_header.dart';
import '../local_widgets/store_tabs.dart';
import '../local_widgets/store_search_bar.dart';
import '../local_widgets/store_products_list.dart';

class StoreView extends StatefulWidget {
  const StoreView({super.key});

  @override
  State<StoreView> createState() => _StoreViewState();
}

class _StoreViewState extends State<StoreView> {
  late final ScrollController _scrollController;
  late final StoreController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<StoreController>();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.positions.length != 1) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _controller.loadMoreProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = Get.find<AuthRepo>();
    return DefaultTextStyle(
      style: const TextStyle(
        decoration: TextDecoration.none,
        fontFamily: 'Samsung Sharp Sans',
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Obx(
                  () => Navbar(
                    totalPoints: authRepo.currentUser.value?.pointsBalance ?? 0,
                  ),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _controller.loadProducts,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: EdgeInsets.only(
                          left: 16.w,
                          right: 16.w,
                          top: 22.h,
                          bottom: 22.h,
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            const StoreHeader(),
                            SizedBox(height: 20.h),
                            const StoreTabs(),
                            SizedBox(height: 30.h),
                            const StoreSearchBar(),
                            SizedBox(height: 20.h),
                          ]),
                        ),
                      ),
                      const StoreProductsList(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 16.h),
                child: BottomNavBar(isBottomBar: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
