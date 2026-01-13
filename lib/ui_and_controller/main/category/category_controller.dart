import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_api_service.dart';
import '../../../services/subcategory_api_service.dart';
import '../../../services/product_api_service.dart';
import '../../../services/wishlist_api_service.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/extension.dart';
import '../../../models/request/wishlist_add_request_model.dart';
import '../widgets/login_bottom_sheet.dart';
import '../../auth/auth_controller.dart';

class CategoryController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();
  final SubcategoryApiService _subcategoryService = SubcategoryApiService();
  final ProductApiService _productApiService = ProductApiService();
  final WishlistApiService _wishlistApiService = WishlistApiService();
  final AuthController _authController = Get.find<AuthController>();

  // Categories
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;

  // Selected category and subcategory
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  Map<String, List<SubcategoryModel>> _subcategoriesMap = {};
  Map<String, bool> _expandedCategories = {}; // Track which categories are expanded

  // Products
  List<ProductModel> _products = [];
  bool _isLoadingProducts = false;
  bool _isRefreshing = false;
  bool _hasError = false;
  String? _errorMessage;
  String _selectedType = 'rent'; // 'rent' or 'sell'

  // Pagination
  int _currentPage = 1;
  int _limit = 10; // Default limit per page
  bool _hasNextPage = false;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedSubcategoryId => _selectedSubcategoryId;
  List<ProductModel> get products => _products;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isRefreshing => _isRefreshing;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get selectedType => _selectedType;
  bool get hasNextPage => _hasNextPage;
  bool isCategoryExpanded(String categoryId) => _expandedCategories[categoryId] ?? false;
  List<SubcategoryModel> getSubcategories(String categoryId) => _subcategoriesMap[categoryId] ?? [];

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    _isLoadingCategories = true;
    update();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      print('CategoryController: Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      update();
    }
  }

  Future<void> loadCategories() async {
    await _loadCategories();
  }

  Future<void> toggleCategoryExpansion(String categoryId) async {
    final isExpanded = _expandedCategories[categoryId] ?? false;
    _expandedCategories[categoryId] = !isExpanded;

    // Load subcategories if expanding and not already loaded
    if (!isExpanded && !_subcategoriesMap.containsKey(categoryId)) {
      try {
        final subcategories = await _subcategoryService.getSubcategories(categoryId);
        _subcategoriesMap[categoryId] = subcategories;
      } catch (e) {
        print('CategoryController: Error loading subcategories: $e');
      }
    }

    update();
  }

  Future<void> selectCategory(String categoryId) async {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = null;
    _currentPage = 1;
    _products = [];
    update();

    // Load subcategories if not already loaded
    if (!_subcategoriesMap.containsKey(categoryId)) {
      try {
        final subcategories = await _subcategoryService.getSubcategories(categoryId);
        _subcategoriesMap[categoryId] = subcategories;
      } catch (e) {
        print('CategoryController: Error loading subcategories: $e');
      }
    }

    // Load products for this category
    await loadProducts();
  }

  Future<void> selectSubcategory(String subcategoryId) async {
    _selectedSubcategoryId = subcategoryId;
    _currentPage = 1;
    _products = [];
    update();

    // Load products for this subcategory
    await loadProducts();
  }

  void setType(String type) {
    if (_selectedType != type) {
      _selectedType = type;
      _currentPage = 1;
      _products = [];
      update();
      loadProducts();
    }
  }

  Future<void> loadProducts({bool isRefresh = false}) async {
    // Don't load if no category selected
    if (_selectedCategoryId == null) {
      return;
    }

    if (isRefresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _hasError = false;
      _errorMessage = null;
    } else if (_currentPage == 1) {
      _isLoadingProducts = true;
      _hasError = false;
      _errorMessage = null;
    }
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);

      // Use new ProductApiService for real API calls
      // Only send JWT token if user is logged in
      // For guests, don't send token - backend will return only 10 random products
      final response = await _productApiService.getProducts(
        jwtToken: jwtToken, // Will be null for guests
        type: _selectedType,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubcategoryId,
        page: _currentPage,
        limit: _limit,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final newProducts = data.products;

        // Set correct type and price based on selected type
        // Note: isWishlisted field comes from API response
        final updatedProducts = newProducts.map((product) {
          // Create product with correct type and price based on selected type
          final productType = product.productType ?? product.type;
          final effectiveType = (productType == 'both') ? _selectedType : productType;
          final effectivePrice = product.getPriceForType(_selectedType);

          return ProductModel(
            id: product.id,
            type: effectiveType,
            title: product.title,
            description: product.description,
            price: effectivePrice,
            deposit: product.deposit,
            categoryId: product.categoryId,
            subcategoryId: product.subcategoryId,
            imageUrls: product.imageUrls,
            location: product.getCity(),
            contactPhone: product.contactPhone,
            isContactShow: product.isContactShow,
            gender: product.gender,
            condition: product.condition,
            size: product.size,
            color: product.color,
            brand: product.brand,
            sellerId: product.sellerId,
            sellerName: product.sellerName,
            sellerImageUrl: product.sellerImageUrl,
            createdAt: product.createdAt,
            latitude: product.getLatitude(),
            longitude: product.getLongitude(),
            isWishlisted: product.isWishlisted, // From API response
            distance: product.distance,
            priceObject: product.priceObject,
            locationObject: product.locationObject,
            productType: product.productType,
            attributes: product.attributes,
            isReviewed: product.isReviewed,
          );
        }).toList();

        if (isRefresh || _currentPage == 1) {
          _products = updatedProducts;
        } else {
          _products.addAll(updatedProducts);
        }

        _currentPage = data.currentPage;
        _hasNextPage = data.hasNextPage;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        final context = Get.context;
        if (context != null) {
          context.showErrorToast(message: response.message);
        }
      }
    } catch (e) {
      print('CategoryController: Error loading products: $e');
      _hasError = true;
      _errorMessage = e.toString().contains('SocketException') ||
          e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again.'
          : 'Failed to load products. Please try again.';
    } finally {
      _isLoadingProducts = false;
      _isRefreshing = false;
      update();
    }
  }

  Future<void> refreshProducts() async {
    await loadProducts(isRefresh: true);
  }

  Future<void> loadMoreProducts() async {
    if (_hasNextPage && !_isLoadingProducts) {
      _currentPage++;
      await loadProducts();
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    // Check if user is logged in
    if (!_authController.isLoggedIn) {
      Get.bottomSheet(
        const LoginBottomSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      return;
    }

    final currentIndex = _products.indexWhere((p) => p.id == product.id);
    if (currentIndex == -1) return;

    // Optimistic UI update
    final newWishlistStatus = !product.isWishlisted;
    final updatedProduct = ProductModel(
      id: product.id,
      type: product.type,
      title: product.title,
      description: product.description,
      price: product.price,
      deposit: product.deposit,
      categoryId: product.categoryId,
      subcategoryId: product.subcategoryId,
      imageUrls: product.imageUrls,
      location: product.location,
      contactPhone: product.contactPhone,
      isContactShow: product.isContactShow,
      gender: product.gender,
      condition: product.condition,
      size: product.size,
      color: product.color,
      brand: product.brand,
      sellerId: product.sellerId,
      sellerName: product.sellerName,
      sellerImageUrl: product.sellerImageUrl,
      createdAt: product.createdAt,
      latitude: product.latitude,
      longitude: product.longitude,
      isWishlisted: newWishlistStatus,
      distance: product.distance,
    );

    _products[currentIndex] = updatedProduct;
    update();

    // Call API in background
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken) ?? '';
      
      if (newWishlistStatus) {
        // Add to wishlist
        await _wishlistApiService.addToWishlist(
          jwtToken: jwtToken,
          request: WishlistAddRequestModel(productId: product.id),
        );
        
        // Show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Added to wishlist');
        }
      } else {
        // Remove from wishlist - use product.id (which is product.productId from API)
        print('CategoryController: Removing wishlist item');
        print('CategoryController: Product ID (product.productId): ${product.id}');
        
        await _wishlistApiService.removeFromWishlist(
          jwtToken: jwtToken,
          productId: product.id, // Using product ID (product.productId from API)
        );
        
        // Show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Removed from wishlist');
        }
      }
    } catch (e) {
      print('CategoryController: Error toggling wishlist: $e');
      // Revert on error
      _products[currentIndex] = product;
      update();

      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to update wishlist');
      }
    }
  }

  void clearSelection() {
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    _products = [];
    _currentPage = 1;
    update();
  }
}
