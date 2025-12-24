import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/store_product_model.dart';

class StoreController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;
  final RxList<StoreProductModel> productsList = <StoreProductModel>[].obs;
  final RxList<StoreProductModel> myPurchasesList = <StoreProductModel>[].obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMoreData = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  Timer? _searchDebounceTimer;

  static const int _pageSize = 10;
  int _currentOffset = 0;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    loadProducts();
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

    await Future.delayed(const Duration(seconds: 1));

    final dummyProducts = _getDummyProducts();

    List<StoreProductModel> filteredProducts = dummyProducts;
    if (searchQuery.value.isNotEmpty) {
      filteredProducts = dummyProducts
          .where(
            (product) => product.name.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    if (loadMore) {
      final startIndex = _currentOffset;
      final endIndex = startIndex + _pageSize;
      if (startIndex < filteredProducts.length) {
        final newProducts = filteredProducts.sublist(
          startIndex,
          endIndex > filteredProducts.length
              ? filteredProducts.length
              : endIndex,
        );
        productsList.addAll(newProducts);
        _currentOffset = endIndex;
        if (endIndex >= filteredProducts.length) {
          hasMoreData.value = false;
        }
      } else {
        hasMoreData.value = false;
      }
    } else {
      final limitedProducts = filteredProducts.take(_pageSize).toList();
      productsList.value = limitedProducts;
      _currentOffset = limitedProducts.length;
      if (limitedProducts.length < _pageSize ||
          limitedProducts.length >= filteredProducts.length) {
        hasMoreData.value = false;
      }
    }

    isLoadingProducts.value = false;
    isLoadingMore.value = false;
  }

  List<StoreProductModel> _getDummyProducts() {
    final now = DateTime.now();
    return [
      StoreProductModel(
        id: '1',
        name: 'By Neta products',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 1000,
        quantityInStock: 23,
        imageUrl:
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      StoreProductModel(
        id: '2',
        name: 'Premium Skincare Set',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 2500,
        quantityInStock: 15,
        imageUrl:
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      StoreProductModel(
        id: '3',
        name: 'Luxury Perfume Collection',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 3500,
        quantityInStock: 8,
        imageUrl:
            'https://images.unsplash.com/photo-1541643600914-78b084683601?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      StoreProductModel(
        id: '4',
        name: 'Beauty Essentials Bundle',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 1800,
        quantityInStock: 30,
        imageUrl:
            'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      StoreProductModel(
        id: '5',
        name: 'Hair Care Premium Kit',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 2200,
        quantityInStock: 12,
        imageUrl:
            'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      StoreProductModel(
        id: '6',
        name: 'Facial Treatment Set',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 2800,
        quantityInStock: 18,
        imageUrl:
            'https://images.unsplash.com/photo-1571875257727-256c39da42af?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
    ];
  }

  Future<void> loadMyPurchases() async {
    isLoadingProducts.value = true;
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final dummyPurchases = [
      StoreProductModel(
        id: '1',
        name: 'By Neta products',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 1000,
        quantityInStock: 23,
        imageUrl:
            'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      StoreProductModel(
        id: '2',
        name: 'Premium Skincare Set',
        description:
            'Loram dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor....',
        costPoints: 2500,
        quantityInStock: 15,
        imageUrl:
            'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?w=400',
        isAvailable: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
    ];

    myPurchasesList.value = dummyPurchases;
    isLoadingProducts.value = false;
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
}
