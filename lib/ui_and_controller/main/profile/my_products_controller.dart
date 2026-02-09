import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  bool _isDeleting = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isDeleting => _isDeleting;

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

  /// Delete a product. Call only after user confirmation.
  /// Returns on completion; caller should close loading dialog and UI will update.
  Future<void> deleteProduct(String productId) async {
    if (_isDeleting) return;

    final jwtToken = preferences.getString(SharedPreference.jwtToken);
    if (jwtToken == null || jwtToken.isEmpty) {
      _showToast('Please login to delete product', isError: true);
      return;
    }

    _isDeleting = true;
    update();

    try {
      final result = await _productApiService.deleteProduct(
        productId: productId,
        jwtToken: jwtToken,
      );

      if (result.success) {
        _products.removeWhere((p) => p.id == productId);
        _showToast(
          result.message.isNotEmpty ? result.message : 'Product removed',
          isError: false,
        );
      } else {
        _showToast(result.message, isError: true);
      }
    } catch (e) {
      _showToast('Something went wrong. Please try again.', isError: true);
    } finally {
      _isDeleting = false;
      update();
    }
  }

  void _showToast(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      textColor: Colors.white,
    );
  }
}
