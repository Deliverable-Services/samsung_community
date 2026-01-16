import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/services/supabase_service.dart';
import '../../../data/core/utils/common_snackbar.dart';
import '../../../data/helper_widgets/bottom_sheet_modal.dart';
import '../../../data/models/store_product_model.dart';
import '../../../repository/auth_repo/auth_repo.dart';
import '../local_widgets/store_product_details_modal.dart';

class StoreController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<StoreProductModel> productsList = <StoreProductModel>[].obs;
  final RxList<StoreProductModel> myPurchasesList = <StoreProductModel>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isCreatingOrder = false.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounceTimer;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  final AuthRepo _authRepo = Get.find<AuthRepo>();

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadProducts();
  }

  @override
  void onReady() {
    super.onReady();
    _refreshUserData();
  }

  Future<void> _refreshUserData() async {
    await _authRepo.loadCurrentUser();
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      final query = searchController.text.trim();
      if (searchQuery.value != query) {
        searchQuery.value = query;
        _currentOffset = 0;
        productsList.clear();
        hasMoreData.value = true;
        loadProducts();
      }
    });
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
    if (index == 1) {
      loadMyPurchases();
    } else {
      loadProducts();
    }
  }

  Future<void> loadProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore.value || !hasMoreData.value) return;
      isLoadingMore.value = true;
    } else {
      _currentOffset = 0;
      productsList.clear();
      hasMoreData.value = true;
      isLoadingProducts.value = true;
    }

    try {
      var query = SupabaseService.client
          .from('store_products')
          .select()
          .eq('is_available', true)
          .isFilter('deleted_at', null);

      if (searchQuery.value.isNotEmpty) {
        final searchTerm = '%${searchQuery.value.trim()}%';
        query = query.ilike('name', searchTerm);
      }

      var transformQuery = query.order('created_at', ascending: false);

      if (loadMore) {
        transformQuery = transformQuery.range(
          _currentOffset,
          _currentOffset + _pageSize - 1,
        );
      } else {
        transformQuery = transformQuery.range(0, _pageSize - 1);
      }

      final response = await transformQuery;
      final productsData = response as List<dynamic>;

      final newProducts = productsData
          .map(
            (json) => StoreProductModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      if (loadMore) {
        productsList.addAll(newProducts);
        _currentOffset += newProducts.length;
      } else {
        productsList.value = newProducts;
        _currentOffset = newProducts.length;
      }

      if (newProducts.length < _pageSize) {
        hasMoreData.value = false;
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
      CommonSnackbar.error('somethingWentWrong'.tr);
    } finally {
      isLoadingProducts.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMyPurchases() async {
    isLoadingProducts.value = true;

    try {
      final currentUserId = SupabaseService.currentUser?.id;
      if (currentUserId == null) {
        myPurchasesList.clear();
        isLoadingProducts.value = false;
        return;
      }

      final response = await SupabaseService.client
          .from('store_orders')
          .select('''
            store_products (
              id,
              name,
              description,
              description_video_url,
              cost_points,
              quantity_in_stock,
              image_url,
              is_available,
              created_by,
              created_at,
              updated_at
            )
          ''')
          .eq('user_id', currentUserId)
          .isFilter('deleted_at', null)
          .order('ordered_at', ascending: false);

      final ordersData = response as List<dynamic>;
      final purchases = <StoreProductModel>[];

      for (final order in ordersData) {
        final productData = order['store_products'];
        if (productData != null) {
          purchases.add(
            StoreProductModel.fromJson(productData as Map<String, dynamic>),
          );
        }
      }

      myPurchasesList.value = purchases;
    } catch (e) {
      debugPrint('Error loading purchases: $e');
      CommonSnackbar.error('somethingWentWrong'.tr);
      myPurchasesList.clear();
    } finally {
      isLoadingProducts.value = false;
    }
  }

  void loadMoreProducts() {
    if (selectedTabIndex.value == 0) {
      loadProducts(loadMore: true);
    }
  }

  List<StoreProductModel> get filteredProducts {
    if (selectedTabIndex.value == 1) {
      return myPurchasesList;
    }
    return productsList;
  }

  void showProductDetails(StoreProductModel product) {
    if (Get.context == null) return;

    final isMyPurchasesTab = selectedTabIndex.value == 1;

    BottomSheetModal.show(
      Get.context!,
      buttonType: BottomSheetButtonType.close,
      content: StoreProductDetailsModal(
        product: product,
        hideBuyButton: isMyPurchasesTab,
      ),
    );
  }

  Future<bool> createOrder({
    required StoreProductModel product,
    required String city,
    required String address,
    required String zipCode,
    required String phone,
  }) async {
    if (isCreatingOrder.value) return false;

    try {
      isCreatingOrder.value = true;

      final currentUserId = SupabaseService.currentUser?.id;
      if (currentUserId == null) {
        CommonSnackbar.error('User not authenticated');
        return false;
      }

      final authRepo = Get.find<AuthRepo>();
      final currentUser = authRepo.currentUser.value;
      if (currentUser == null) {
        CommonSnackbar.error('user_not_found'.tr);
        return false;
      }

      final currentPoints = currentUser.pointsBalance;
      if (currentPoints < product.costPoints) {
        CommonSnackbar.error('insufficientPoints'.tr);
        return false;
      }

      final shippingAddress = address.trim();
      final balanceAfter = currentPoints - product.costPoints;

      final orderResponse = await SupabaseService.client
          .from('store_orders')
          .insert({
            'user_id': currentUserId,
            'product_id': product.id,
            'quantity': 1,
            'points_paid': product.costPoints,
            'shipping_address': shippingAddress,
            'shipping_zip': zipCode.trim(),
            'shipping_phone': phone.trim(),
            'status': 'pending',
          })
          .select('id')
          .single();

      final orderId = orderResponse['id'] as String;

      await SupabaseService.client.from('points_transactions').insert({
        'user_id': currentUserId,
        'transaction_type': 'spent',
        'amount': -product.costPoints,
        'balance_after': balanceAfter,
        'description': 'Purchase: ${product.name}',
        'related_entity_type': 'store_order',
        'related_entity_id': orderId,
      });

      await SupabaseService.client
          .from('users')
          .update({'points_balance': balanceAfter})
          .eq('id', currentUserId);

      final newQuantity = product.quantityInStock - 1;
      if (newQuantity >= 0) {
        await SupabaseService.client
            .from('store_products')
            .update({
              'quantity_in_stock': newQuantity,
              'is_available': newQuantity > 0,
            })
            .eq('id', product.id);
      }

      await authRepo.loadCurrentUser();

      return true;
    } catch (e) {
      debugPrint('Error creating order: $e');
      CommonSnackbar.error('somethingWentWrong'.tr);
      return false;
    } finally {
      isCreatingOrder.value = false;
    }
  }
}
