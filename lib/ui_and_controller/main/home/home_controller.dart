import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../models/product_model.dart';
import '../../../models/request/wishlist_add_request_model.dart';
import '../../../services/product_api_service.dart';
import '../../../services/wishlist_api_service.dart';
import '../../../services/nominatim_api_service.dart';
import '../../../services/fcm_service.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/extension.dart';
import '../widgets/login_bottom_sheet.dart';
import '../widgets/location_selection_bottom_sheet.dart';
import '../../auth/auth_controller.dart';
import '../notification/notification_controller.dart';
import '../wishlist/wishlist_controller.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeController extends GetxController {
  final ProductApiService _productApiService = ProductApiService();
  final WishlistApiService _wishlistApiService = WishlistApiService();
  final NominatimApiService _nominatimApiService = NominatimApiService();

  // Tab selection
  String _selectedTab = 'rent'; // 'rent' or 'sell'

  // Search
  TextEditingController? _searchController;
  String _searchQuery = '';
  bool _isDisposed = false;
  Timer? _searchDebounceTimer; // Debounce timer for search

  TextEditingController get searchController {
    if (_searchController == null || _isDisposed) {
      _searchController = TextEditingController();
      _isDisposed = false;
    }
    return _searchController!;
  }

  // Location
  String _currentLocation = 'Loading location...';
  double? _latitude;
  double? _longitude;

  // Products
  List<ProductModel> _productList = [];
  bool _isLoadingProducts = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _hasInitialLoad = false;

  // Pagination
  int _currentPage = 1;
  final int _limit = 10; // Default limit per page
  bool _hasNextPage = false;

  // Filters
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;

  // Getters
  String get selectedTab => _selectedTab;

  String get currentLocation => _currentLocation;

  bool get hasLocationPermission => _latitude != null && _longitude != null;

  List<ProductModel> get productList => _productList;

  bool get isLoadingProducts => _isLoadingProducts;

  bool get isRefreshing => _isRefreshing;

  bool get isLoadingMore => _isLoadingMore;

  bool get hasNextPage => _hasNextPage;

  bool get hasError => _hasError;

  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    // Initialize searchController in onInit to ensure it's created fresh
    _searchController = TextEditingController();
    _getCurrentLocation();
  }

  @override
  void onReady() {
    super.onReady();
    _requestNotificationPermission();
    _initializeFCM();
    _loadUserProfile();
    _initialLoad();
    _refreshNotificationUnreadCount();
  }

  Future<void> _refreshNotificationUnreadCount() async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        final notificationController = Get.find<NotificationController>();
        await notificationController.refreshUnreadCount();
      }
    } catch (e) {
      print('HomeController: Error refreshing notification unread count: $e');
    }
  }

  Future<void> _initialLoad() async {
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      await loadProducts();
    }
  }

  // Call this when tab becomes visible
  void onTabVisible() {
    // Load data if not already loaded or if list is empty and not currently loading
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      loadProducts();
    } else if (_productList.isEmpty && !_isLoadingProducts && !_isRefreshing) {
      // Reload if list is empty and not loading
      loadProducts();
    }
  }

  Future<void> _loadUserProfile() async {
    // Profile loading removed - not needed in home controller
    // Profile is managed by ProfileApiService in other controllers
  }

  @override
  @override
  void onClose() {
    try {
      _isDisposed = true;
      // Cancel any pending search debounce timer
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = null;
      _searchController?.dispose();
      _searchController = null;
    } catch (e) {
      // Controller already disposed, ignore
    }
    super.onClose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('HomeController: Location service disabled');
        _handleLocationError();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('HomeController: Location permission denied');
          _handleLocationError();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('HomeController: Location permission permanently denied');
        _handleLocationError();
        return;
      }

      // Try to get current position with timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        ).timeout(const Duration(seconds: 10));
      } on TimeoutException {
        print('HomeController: Location timeout, using default location');
        position = null;
      } catch (e) {
        print('HomeController: Error getting position: $e');
        position = null;
      }

      if (position != null) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        print(
          'HomeController: Got position - Lat: ${_latitude}, Long: ${_longitude}',
        );
        // Convert coordinates to readable address using reverse geocoding
        await _getAddressFromCoordinates(position.latitude, position.longitude);
      } else {
        print('HomeController: No position available');
        _handleLocationError();
      }
      update();
    } catch (e) {
      print('HomeController: Error getting location: $e');
      _handleLocationError();
    }
  }

  /// Convert latitude and longitude to readable address using Nominatim API
  Future<void> _getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      print(
        'HomeController: Reverse geocoding for Lat: $latitude, Long: $longitude',
      );

      final geocodingResponse = await _nominatimApiService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      if (geocodingResponse.isSuccess && geocodingResponse.result != null) {
        // Use the short address for better display
        _currentLocation = geocodingResponse.shortAddress;

        print('HomeController: Address resolved - $_currentLocation');
      } else {
        print(
          'HomeController: Reverse geocoding failed - ${geocodingResponse.errorMessage ?? 'No results'}',
        );
        _currentLocation = 'Current Location';
      }
    } catch (e) {
      print('HomeController: Error in reverse geocoding: $e');
      _currentLocation = 'Current Location';
    }
  }

  /// Handle location error - prompt user to select location manually
  void _handleLocationError() {
    _currentLocation = 'Tap to select location';
    _latitude = null;
    _longitude = null;
    print('HomeController: Location not available - user can select manually');
  }

  void showLocationSelection() {
    Get.bottomSheet(
      LocationSelectionBottomSheet(
        onLocationSelected: (String placeId, String description, double latitude, double longitude) {
          // Nominatim API already provides coordinates directly
          // No need for additional API call
          _latitude = latitude;
          _longitude = longitude;
          _currentLocation = description;
          print(
            'HomeController: Location selected - Lat: $latitude, Long: $longitude, Description: $description',
          );

          update();
          _currentPage = 1;
          _productList = [];
          loadProducts();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _requestNotificationPermission() async {
    final hasAsked = preferences.getBool(
      SharedPreference.notificationPermissionAsked,
      defValue: false,
    );

    if (!hasAsked) {
      final status = await Permission.notification.request();
      await preferences.putBool(
        SharedPreference.notificationPermissionAsked,
        true,
      );

      if (status.isGranted) {
        print('HomeController: Notification permission granted');
      }
    }
  }

  Future<void> _initializeFCM() async {
    try {
      if (!Get.isRegistered<FCMService>()) {
        Get.put(FCMService());
      }
    } catch (e) {
      print('HomeController: Error initializing FCM: $e');
    }
  }

  void setTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      _currentPage = 1;
      _productList = [];
      update();
      loadProducts();
    }
  }

  void onSearchChanged(String value) {
    _searchQuery = value;
    _searchDebounceTimer?.cancel();
    if (value.trim().isEmpty) {
      _searchQuery = '';
      _currentPage = 1;
      _productList = [];
      update();
      loadProducts(isSearch: true);
      return;
    }
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!_isDisposed) {
        _performSearch();
      }
    });
  }

  void _performSearch() {
    _currentPage = 1;
    _productList = [];
    update();
    loadProducts(isSearch: true);
  }

  void performSearch() {
    _searchDebounceTimer?.cancel();
    _performSearch();
  }

  Future<void> loadProducts({
    bool isRefresh = false,
    bool isSearch = false,
  }) async {
    if (isSearch) {
      _hasError = false;
      _errorMessage = null;
    } else if (isRefresh) {
      _isRefreshing = true;
      _currentPage = 1;
      _hasError = false;
      _errorMessage = null;
    } else if (_currentPage == 1) {
      _isLoadingProducts = true;
      _hasError = false;
      _errorMessage = null;
    } else {
      _isLoadingMore = true;
    }

    if (!isSearch) {
      update();
    }

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      final response = await _productApiService.getProducts(
        jwtToken: jwtToken,
        type: _selectedTab,
        categoryId: _selectedCategoryId,
        subCategoryId: _selectedSubcategoryId,
        search: _searchQuery.trim().isNotEmpty ? _searchQuery.trim() : null,
        lat: _latitude,
        lng: _longitude,
        page: _currentPage,
        limit: _limit,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final newProducts = data.products;
        final updatedProducts = newProducts.map((product) {
          final productType = product.productType ?? product.type;
          final effectiveType = (productType == 'both')
              ? _selectedTab
              : productType;
          final effectivePrice = product.getPriceForType(_selectedTab);

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
            isWishlisted: product.isWishlisted,
            distance: product.distance,
            priceObject: product.priceObject,
            locationObject: product.locationObject,
            productType: product.productType,
            attributes: product.attributes,
            isReviewed: product.isReviewed,
          );
        }).toList();

        if (isSearch || isRefresh || _currentPage == 1) {
          _productList = updatedProducts;
        } else {
          _productList.addAll(updatedProducts);
        }

        _currentPage = data.currentPage;
        _hasNextPage = data.hasNextPage;
      }
    } catch (e) {
      print('HomeController: Error loading products: $e');
      _hasError = true;
      _errorMessage =
          e.toString().contains('SocketException') ||
              e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again.'
          : 'Failed to load products. Please try again.';

      if (isSearch || isRefresh || _currentPage == 1) {
        _productList = [];
      }
    } finally {
      if (isSearch) {
        update();
      } else {
        _isLoadingProducts = false;
        _isRefreshing = false;
        _isLoadingMore = false;
        update();
      }
    }
  }

  Future<void> loadMoreProducts() async {
    if (_hasNextPage && !_isLoadingMore) {
      _currentPage++;
      await loadProducts();
    }
  }

  Future<void> refreshProducts() async {
    await _loadUserProfile();
    await loadProducts(isRefresh: true);
  }

  Future<void> toggleWishlist(ProductModel product) async {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      Get.bottomSheet(
        const LoginBottomSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );
      return;
    }
    final currentIndex = _productList.indexWhere((p) => p.id == product.id);
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

    if (currentIndex != -1) {
      _productList[currentIndex] = updatedProduct;
    }
    update();

    // Sync wishlist state with Wishlist screen (optimistic)
    if (Get.isRegistered<WishlistController>()) {
      try {
        final wishlistController = Get.find<WishlistController>();
        wishlistController.handleExternalWishlistChange(
          product.id,
          newWishlistStatus,
        );
      } catch (_) {
        // Ignore sync errors
      }
    }

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken) ?? '';

      if (newWishlistStatus) {
        await _wishlistApiService.addToWishlist(
          jwtToken: jwtToken,
          request: WishlistAddRequestModel(productId: product.id),
        );
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Added to wishlist');
        }
      } else {
        print('HomeController: Removing wishlist item');
        print('HomeController: Product ID (product.productId): ${product.id}');

        await _wishlistApiService.removeFromWishlist(
          jwtToken: jwtToken,
          productId: product.id,
        );

        // Show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Removed from wishlist');
        }
      }
    } catch (e) {
      print('HomeController: Error toggling wishlist: $e');
      final revertedProduct = ProductModel(
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
        isWishlisted: product.isWishlisted,
        distance: product.distance,
      );
      if (currentIndex != -1) {
        _productList[currentIndex] = revertedProduct;
      }
      update();
      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to update wishlist');
      }
    }
  }

  /// Update wishlist status for a product from other screens (e.g., detail/wishlist).
  void updateWishlistStatus(String productId, bool isWishlisted) {
    final index = _productList.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = _productList[index];
    _productList[index] = ProductModel(
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
      isWishlisted: isWishlisted,
      distance: product.distance,
      priceObject: product.priceObject,
      locationObject: product.locationObject,
      productType: product.productType,
      attributes: product.attributes,
      isReviewed: product.isReviewed,
    );
    update();
  }

  void setFilter({
    String? categoryId,
    String? subcategoryId,
    String? gender,
    double? minPrice,
    double? maxPrice,
  }) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = subcategoryId;
    _currentPage = 1;
    _productList = [];
    update();
    loadProducts();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedSubcategoryId = null;
    _currentPage = 1;
    _productList = [];
    update();
    loadProducts();
  }
}
