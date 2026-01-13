import 'package:get/get.dart';
import '../../../models/product_model.dart';
import '../../../services/wishlist_api_service.dart';
import '../../../utils/shared_pref.dart';
import '../../../utils/extension.dart';

class WishlistController extends GetxController {
  final WishlistApiService _wishlistApiService = WishlistApiService();

  List<ProductModel> _allWishlistItems = [];
  List<ProductModel> _filteredItems = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String _selectedFilter = 'rent'; // 'rent' or 'sell' (default to 'rent')
  bool _hasInitialLoad = false;

  List<ProductModel> get wishlistItems => _filteredItems;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  // Separate lists for UI
  List<ProductModel> get rentItems =>
      _filteredItems.where((item) => item.type == 'rent').toList();
  List<ProductModel> get sellItems =>
      _filteredItems.where((item) => item.type == 'sell').toList();

  @override
  void onInit() {
    super.onInit();
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      await loadWishlist();
    }
  }

  // Call this when tab becomes visible
  void onTabVisible() {
    // Load data if not already loaded or if list is empty and not currently loading
    if (!_hasInitialLoad) {
      _hasInitialLoad = true;
      loadWishlist();
    } else if (_allWishlistItems.isEmpty && !_isLoading) {
      // Reload if list is empty and not loading
      loadWishlist();
    }
  }

  Future<void> loadWishlist() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        _hasError = true;
        _errorMessage = 'Please login to view wishlist';
        _isLoading = false;
        update();
        return;
      }

      // Use WishlistApiService to load wishlist items
      final response = await _wishlistApiService.getWishlist(
        jwtToken: jwtToken,
      );

      if (response.success && response.data != null) {
        final data = response.data!;
        final wishlistItems = data.wishlistItems;
        
        // Process wishlist items and extract products
        final products = wishlistItems.map((wishlistItem) {
          final product = wishlistItem.product;
          
          // IMPORTANT: 
          // - product.id = product.productId from WishlistProduct (actual product identifier)
          // - This productId is used for DELETE API: /api/user/wishlist/{productId}
          final productId = product.id; // This is product.productId from the API
          
          // Debug logging to verify product ID
          print('WishlistController: Loaded wishlist item');
          print('WishlistController:   Product ID (product.productId): $productId');
          print('WishlistController:   Product Title: ${product.title}');
          
          if (productId.isEmpty) {
            print('WishlistController: Warning - Empty product ID for product ${product.title}');
          }
          
          // Determine effective type and price based on product type and selected filter
          final productType = product.productType ?? product.type;
          String displayType;
          double displayPrice;
          
          if (productType == 'both') {
            // For 'both' type, use the currently selected filter to determine display type and price
            // This ensures the price shown matches the selected filter tab
            displayType = _selectedFilter;
            displayPrice = product.getPriceForType(_selectedFilter);
          } else {
            // Use the product's actual type
            displayType = productType;
            displayPrice = product.getPriceForType(productType);
          }
          
          // Create product model with wishlist info
          return ProductModel(
            id: product.id,
            type: displayType, // Display type for initial rendering
            title: product.title,
            description: product.description,
            price: displayPrice,
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
            isWishlisted: true, // All items in wishlist are wishlisted
            distance: product.distance,
            priceObject: product.priceObject,
            locationObject: product.locationObject,
            productType: product.productType,
            attributes: product.attributes,
            isReviewed: product.isReviewed,
          );
        }).toList();

        _allWishlistItems = products;
        _applyFilter();
      } else {
        _hasError = true;
        _errorMessage = response.message.isNotEmpty 
            ? response.message 
            : 'Failed to load wishlist';
        _allWishlistItems = [];
        _filteredItems = [];
      }
    } catch (e) {
      print('WishlistController: Error loading wishlist: $e');
      _hasError = true;
      _errorMessage = e.toString().contains('SocketException') || 
                      e.toString().contains('network')
          ? 'No internet connection. Please check your network and try again.'
          : 'Failed to load wishlist. Please try again.';
      _allWishlistItems = [];
      _filteredItems = [];
    } finally {
      _isLoading = false;
      update();
    }
  }


  void setFilter(String filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      // Re-apply filter without reloading (products support both types)
      _applyFilter();
      update(); // Notify GetX to rebuild UI immediately
    }
  }

  void _applyFilter() {
    // Filter products based on selected type
    // Products with productType 'both' should appear in both filters
    _filteredItems = _allWishlistItems.where((item) {
      final productType = item.productType ?? item.type;
      
      if (productType == 'both') {
        // For 'both' type products, show them based on selected filter
        // Check if the product has price for the selected type
        if (item.priceObject != null) {
          if (_selectedFilter == 'rent' && item.priceObject!.containsKey('rent')) {
            return true;
          } else if (_selectedFilter == 'sell' && item.priceObject!.containsKey('sell')) {
            return true;
          }
        }
        // If no price object, don't show (safety check)
        return false;
      } else {
        // For 'rent' or 'sell' only products, check if productType matches selected filter
        return productType == _selectedFilter;
      }
    }).toList();
  }

  Future<void> removeFromWishlist(ProductModel product) async {
    // IMPORTANT: Use product.id (which is product.productId from the API) for deletion
    // DELETE API: /api/user/wishlist/{productId}
    final productId = product.id;
    
    if (productId.isEmpty) {
      print('WishlistController: Error - Empty product ID');
      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to remove from wishlist: Invalid product ID');
      }
      return;
    }
    
    print('WishlistController: Removing wishlist item');
    print('WishlistController: Product ID (product.productId): $productId');
    print('WishlistController: Product Title: ${product.title}');

    // Optimistic UI update
    _allWishlistItems.removeWhere((item) => item.id == product.id);
    _applyFilter();
    update();

    // Call API in background
    // IMPORTANT: Using productId (product.productId from API) for DELETE API
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken) ?? '';
      final response = await _wishlistApiService.removeFromWishlist(
        jwtToken: jwtToken,
        productId: productId, // This is product.productId from the API
      );

      if (!response.success) {
        // Revert on error
        _allWishlistItems.add(product);
        _applyFilter();
        update();

        print('WishlistController: Failed to remove from wishlist');
        print('WishlistController: Status Code: ${response.statusCode}');
        print('WishlistController: Error Message: ${response.message}');
        print('WishlistController: Product ID used: $productId');
        print('WishlistController: If 404 error, verify:');
        print('WishlistController:   1. Product ID is correct (product.productId from GET /api/user/wishlist)');
        print('WishlistController:   2. API endpoint is DELETE /api/user/wishlist/{productId}');
        print('WishlistController:   3. Item still exists in wishlist');

        final context = Get.context;
        if (context != null) {
          String errorMsg = response.message.isNotEmpty 
              ? response.message 
              : 'Failed to remove from wishlist';
          
          // Add more context for 404 errors
          if (response.statusCode == 404) {
            errorMsg += ' (Item may have been removed or ID is incorrect)';
          }
          
          context.showErrorToast(message: errorMsg);
        }
      } else {
        // Success - show success message
        final context = Get.context;
        if (context != null) {
          context.showSuccessToast(message: 'Removed from wishlist');
        }
      }
    } catch (e) {
      print('WishlistController: Error removing from wishlist: $e');
      // Revert on error
      _allWishlistItems.add(product);
      _applyFilter();
      update();

      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to remove from wishlist');
      }
    }
  }

  Future<void> refreshWishlist() async {
    await loadWishlist();
  }
}
