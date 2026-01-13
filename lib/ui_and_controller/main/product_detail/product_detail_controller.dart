import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/product_model.dart';
import '../../../models/request/wishlist_add_request_model.dart';
import '../../../services/product_api_service.dart';
import '../../../services/wishlist_api_service.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/extension.dart';
import '../widgets/login_bottom_sheet.dart';
import '../../auth/auth_controller.dart';
import '../../main/profile/profile_controller.dart';

class ProductDetailController extends GetxController {
  final String productId;
  final ProductModel? initialProductData;
  final ProductApiService _productApiService = ProductApiService();
  final WishlistApiService _wishlistApiService = WishlistApiService();

  ProductModel? _product;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  int _selectedImageIndex = 0;

  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  int get selectedImageIndex => _selectedImageIndex;

  /// Check if the product belongs to the logged-in user
  bool get isOwnProduct {
    if (_product == null) return false;

    // Try to get user ID from SharedPreferences (set during login)
    String? currentUserId = preferences.getString(SharedPreference.userId);

    // If not found in SharedPreferences, try to get from profile controller if available
    if ((currentUserId == null || currentUserId.isEmpty) &&
        Get.isRegistered<ProfileScreenController>()) {
      try {
        final profileController = Get.find<ProfileScreenController>();
        if (profileController.profileData != null) {
          currentUserId = profileController.profileData!.id;
        }
      } catch (e) {
        // Profile controller not available, ignore
      }
    }

    if (currentUserId == null || currentUserId.isEmpty) return false;
    return _product!.sellerId == currentUserId;
  }

  ProductDetailController({required this.productId, this.initialProductData});

  @override
  void onInit() {
    super.onInit();
    // If product data is provided, use it directly without API call
    if (initialProductData != null) {
      _product = initialProductData;
      update();
    } else {
      // Otherwise, load from API
      loadProductDetail();
    }
  }

  Future<void> loadProductDetail() async {
    // Only show loading if we don't have product data yet
    if (_product == null) {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      update();
    }

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      final response = await _productApiService.getProductDetail(
        jwtToken: jwtToken, // Optional - can be null for guest mode
        productId: productId,
      );

      if (response.success && response.data != null) {
        _product = response.data!;
        // isWishlisted field comes from API response
        _hasError = false;
        _errorMessage = null;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        final context = Get.context;
        if (context != null) {
          context.showErrorToast(message: response.message);
        }
      }
    } catch (e) {
      print('ProductDetailController: Error loading product: $e');
      _hasError = true;
      _errorMessage =
          e.toString().contains('SocketException') ||
              e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again.'
          : 'Failed to load product details. Please try again.';
    } finally {
      _isLoading = false;
      update();
    }
  }

  void setSelectedImageIndex(int index) {
    _selectedImageIndex = index;
    update();
  }

  Future<void> toggleWishlist() async {
    if (_product == null) return;

    // Check if user is logged in
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      // Show login bottom sheet
      Get.bottomSheet(
        const LoginBottomSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      return;
    }

    // Optimistic UI update
    final newWishlistStatus = !_product!.isWishlisted;
    _product = ProductModel(
      id: _product!.id,
      type: _product!.type,
      title: _product!.title,
      description: _product!.description,
      price: _product!.price,
      deposit: _product!.deposit,
      categoryId: _product!.categoryId,
      subcategoryId: _product!.subcategoryId,
      imageUrls: _product!.imageUrls,
      location: _product!.location,
      contactPhone: _product!.contactPhone,
      isContactShow: _product!.isContactShow,
      gender: _product!.gender,
      condition: _product!.condition,
      size: _product!.size,
      color: _product!.color,
      brand: _product!.brand,
      sellerId: _product!.sellerId,
      sellerName: _product!.sellerName,
      sellerImageUrl: _product!.sellerImageUrl,
      createdAt: _product!.createdAt,
      latitude: _product!.latitude,
      longitude: _product!.longitude,
      isWishlisted: newWishlistStatus,
      distance: _product!.distance,
      priceObject: _product!.priceObject,
      locationObject: _product!.locationObject,
      productType: _product!.productType,
      attributes: _product!.attributes,
      isReviewed: _product!.isReviewed,
    );
    update();

    // Call API in background
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken) ?? '';

      if (newWishlistStatus) {
        // Add to wishlist
        await _wishlistApiService.addToWishlist(
          jwtToken: jwtToken,
          request: WishlistAddRequestModel(productId: _product!.id),
        );

        // Show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Added to wishlist');
        }
      } else {
        // Remove from wishlist - use product.id (which is product.productId from API)
        print('ProductDetailController: Removing wishlist item');
        print(
          'ProductDetailController: Product ID (product.productId): ${_product!.id}',
        );

        await _wishlistApiService.removeFromWishlist(
          jwtToken: jwtToken,
          productId:
              _product!.id, // Using product ID (product.productId from API)
        );

        // Show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Removed from wishlist');
        }
      }
    } catch (e) {
      print('ProductDetailController: Error toggling wishlist: $e');
      // Revert on error
      _product = ProductModel(
        id: _product!.id,
        type: _product!.type,
        title: _product!.title,
        description: _product!.description,
        price: _product!.price,
        deposit: _product!.deposit,
        categoryId: _product!.categoryId,
        subcategoryId: _product!.subcategoryId,
        imageUrls: _product!.imageUrls,
        location: _product!.location,
        contactPhone: _product!.contactPhone,
        isContactShow: _product!.isContactShow,
        gender: _product!.gender,
        condition: _product!.condition,
        size: _product!.size,
        color: _product!.color,
        brand: _product!.brand,
        sellerId: _product!.sellerId,
        sellerName: _product!.sellerName,
        sellerImageUrl: _product!.sellerImageUrl,
        createdAt: _product!.createdAt,
        latitude: _product!.latitude,
        longitude: _product!.longitude,
        isWishlisted: !newWishlistStatus,
        distance: _product!.distance,
        priceObject: _product!.priceObject,
        locationObject: _product!.locationObject,
        productType: _product!.productType,
        attributes: _product!.attributes,
        isReviewed: _product!.isReviewed,
      );
      update();

      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to update wishlist');
      }
    }
  }
}
