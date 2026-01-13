import 'package:get/get.dart';
import '../../../models/product_model.dart';
import '../../../services/product_api_service.dart';
import '../../../utils/shared_pref.dart';

class MyProductsController extends GetxController {
  final ProductApiService _productApiService = ProductApiService();

  List<ProductModel> _products = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  @override
  void onInit() {
    super.onInit();
    loadMyProducts();
  }

  Future<void> loadMyProducts() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        _hasError = true;
        _errorMessage = 'Please login to view your products';
        _isLoading = false;
        update();
        return;
      }

      final response = await _productApiService.getMyProducts(
        jwtToken: jwtToken,
      );

      if (response.success && response.data != null) {
        _products = response.data!.products;
        _isLoading = false;
        _hasError = false;
      } else {
        _hasError = true;
        _errorMessage = response.message;
        _products = [];
      }
      _isLoading = false;
      update();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Failed to load products. Please try again.';
      update();
    }
  }

  Future<void> refreshProducts() async {
    await loadMyProducts();
  }
}
