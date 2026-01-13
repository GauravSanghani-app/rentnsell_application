import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/product_model.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/attribute_template_model.dart';
import '../../../services/category_api_service.dart';
import '../../../services/subcategory_api_service.dart';
import '../../../services/attribute_template_api_service.dart';
import '../../../services/product_update_api_service.dart';
import '../../../services/product_image_delete_api_service.dart';
import '../../../models/request/product_update_request_model.dart';
import '../../../utils/shared_pref.dart';

/// Edit Product Controller
///
/// Manages the state and logic for the Edit Product screen
class EditProductController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();
  final SubcategoryApiService _subcategoryService = SubcategoryApiService();
  final AttributeTemplateApiService _attributeTemplateService =
      AttributeTemplateApiService();
  final ProductUpdateApiService _productUpdateApiService =
      ProductUpdateApiService();
  final ProductImageDeleteApiService _imageDeleteApiService =
      ProductImageDeleteApiService();

  // Product being edited
  final ProductModel product;
  final String productId;

  // Product Type: 'rent', 'sell', or 'both'
  String _productType;
  bool _isBothRentSell = false;

  // Callback for scrolling to error field
  Function(String)? onErrorFieldScroll;

  EditProductController({
    required this.product,
    this.onErrorFieldScroll,
  })  : productId = product.id,
        _productType = product.productType ?? product.type;

  // Fixed Form Fields
  late final TextEditingController titleController;
  late final TextEditingController descriptionController;
  late final TextEditingController rentPriceController;
  late final TextEditingController sellPriceController;
  late final TextEditingController cityController;
  late final TextEditingController latitudeController;
  late final TextEditingController longitudeController;

  // Category & Subcategory
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<SubcategoryModel> _subcategories = [];
  String? _selectedSubcategoryId;

  // Attribute Template & Dynamic Fields
  AttributeTemplateModel? _attributeTemplate;
  Map<String, TextEditingController> _dynamicFieldControllers = {};
  final Map<String, String> _dynamicFieldValues = {};

  // Images - Separate existing (URLs) from new (Files)
  List<String> _existingImageUrls = []; // Existing images from server
  List<File> _newImages = []; // Newly added images

  // Error States
  final Map<String, String> _fieldErrors = {};

  // Loading States
  bool _isLoadingCategories = false;
  bool _isLoadingSubcategories = false;
  bool _isLoadingAttributeTemplate = false;
  bool _isSubmitting = false;
  bool _isGettingLocation = false;
  bool _isDeletingImage = false;

  // Getters
  String get productType => _productType;
  bool get isBothRentSell => _isBothRentSell;
  Map<String, String> get fieldErrors => _fieldErrors;
  String? getFieldError(String fieldName) => _fieldErrors[fieldName];
  void clearFieldError(String fieldName) {
    _fieldErrors.remove(fieldName);
    update();
  }
  void clearAllErrors() {
    _fieldErrors.clear();
    update();
  }

  List<CategoryModel> get categories => _categories;
  String? get selectedCategoryId => _selectedCategoryId;
  List<SubcategoryModel> get subcategories => _subcategories;
  String? get selectedSubcategoryId => _selectedSubcategoryId;
  AttributeTemplateModel? get attributeTemplate => _attributeTemplate;
  List<AttributeField> get dynamicFields => _attributeTemplate?.fields ?? [];
  Map<String, TextEditingController> get dynamicFieldControllers =>
      _dynamicFieldControllers;
  List<String> get existingImageUrls => _existingImageUrls;
  List<File> get newImages => _newImages;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingSubcategories => _isLoadingSubcategories;
  bool get isLoadingAttributeTemplate => _isLoadingAttributeTemplate;
  bool get isSubmitting => _isSubmitting;
  bool get isGettingLocation => _isGettingLocation;
  bool get isDeletingImage => _isDeletingImage;

  @override
  void onInit() {
    super.onInit();
    _initializeFields();
    loadCategories();
  }

  /// Initialize all fields with product data
  void _initializeFields() {
    // Initialize controllers
    titleController = TextEditingController(text: product.title);
    descriptionController = TextEditingController(text: product.description);
    
    // Initialize prices
    if (product.priceObject != null) {
      final rentPrice = product.priceObject!['rent'] as int? ?? 0;
      final sellPrice = product.priceObject!['sell'] as int? ?? 0;
      rentPriceController = TextEditingController(
        text: rentPrice > 0 ? rentPrice.toString() : '',
      );
      sellPriceController = TextEditingController(
        text: sellPrice > 0 ? sellPrice.toString() : '',
      );
    } else {
      rentPriceController = TextEditingController();
      sellPriceController = TextEditingController();
    }

    // Initialize location
    if (product.locationObject != null) {
      cityController = TextEditingController(
        text: product.locationObject!['city']?.toString() ?? '',
      );
      latitudeController = TextEditingController(
        text: product.getLatitude()?.toString() ?? '',
      );
      longitudeController = TextEditingController(
        text: product.getLongitude()?.toString() ?? '',
      );
    } else {
      cityController = TextEditingController(text: product.location);
      latitudeController = TextEditingController(
        text: product.latitude?.toString() ?? '',
      );
      longitudeController = TextEditingController(
        text: product.longitude?.toString() ?? '',
      );
    }

    // Initialize category and subcategory
    _selectedCategoryId = product.categoryId;
    _selectedSubcategoryId = product.subcategoryId;

    // Initialize existing images
    _existingImageUrls = List<String>.from(product.imageUrls);

    // Set product type
    if (product.productType == 'both') {
      _isBothRentSell = true;
    }

    // Load subcategories and attribute template after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_selectedCategoryId != null) {
        loadSubcategories(_selectedCategoryId!);
      }
      if (_selectedSubcategoryId != null) {
        loadAttributeTemplate(_selectedSubcategoryId!);
        _populateDynamicFields();
      }
    });
  }

  /// Populate dynamic fields with existing attribute values
  void _populateDynamicFields() {
    if (product.attributes != null && _attributeTemplate != null) {
      for (var field in _attributeTemplate!.fields) {
        final value = product.attributes![field.fieldName]?.toString() ?? '';
        if (_dynamicFieldControllers.containsKey(field.fieldName)) {
          _dynamicFieldControllers[field.fieldName]!.text = value;
        }
        _dynamicFieldValues[field.fieldName] = value;
      }
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    rentPriceController.dispose();
    sellPriceController.dispose();
    cityController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

    for (var controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    _dynamicFieldControllers.clear();
    super.onClose();
  }

  /// Set Product Type
  void setProductType(String type) {
    if (type == 'rent' || type == 'sell' || type == 'both') {
      _productType = type;
      update();
    }
  }

  /// Toggle Both Rent & Sell checkbox
  void setBothRentSell(bool value) {
    _isBothRentSell = value;
    if (value) {
      _productType = 'both';
    } else {
      _productType = product.productType ?? product.type;
    }
    update();
  }

  /// Load Categories
  Future<void> loadCategories() async {
    _isLoadingCategories = true;
    update();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      print('EditProductController: Error loading categories: $e');
    } finally {
      _isLoadingCategories = false;
      update();
    }
  }

  /// Select Category
  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    _selectedSubcategoryId = null;
    _subcategories = [];
    _clearDynamicFields();

    if (categoryId != null) {
      loadSubcategories(categoryId);
    }
    update();
  }

  /// Load Subcategories
  Future<void> loadSubcategories(String categoryId) async {
    _isLoadingSubcategories = true;
    update();

    try {
      _subcategories = await _subcategoryService.getSubcategories(categoryId);
    } catch (e) {
      print('EditProductController: Error loading subcategories: $e');
    } finally {
      _isLoadingSubcategories = false;
      update();
    }
  }

  /// Select Subcategory
  void selectSubcategory(String? subcategoryId) {
    _selectedSubcategoryId = subcategoryId;
    _clearDynamicFields();

    if (subcategoryId != null) {
      loadAttributeTemplate(subcategoryId);
    }
    update();
  }

  /// Load Attribute Template
  Future<void> loadAttributeTemplate(String subcategoryId) async {
    _isLoadingAttributeTemplate = true;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      final templates = await _attributeTemplateService.getAttributeTemplate(
        subcategoryId,
        jwtToken: jwtToken,
      );
      if (templates.isNotEmpty) {
        _attributeTemplate = templates.first;
        _initializeDynamicFields();
        _populateDynamicFields();
      } else {
        _attributeTemplate = null;
      }
    } catch (e) {
      print('EditProductController: Error loading attribute template: $e');
      _attributeTemplate = null;
    } finally {
      _isLoadingAttributeTemplate = false;
      update();
    }
  }

  /// Initialize Dynamic Fields
  void _initializeDynamicFields() {
    for (var controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    _dynamicFieldControllers.clear();
    _dynamicFieldValues.clear();

    if (_attributeTemplate != null) {
      for (var field in _attributeTemplate!.fields) {
        _dynamicFieldControllers[field.fieldName] = TextEditingController();
      }
    }
  }

  /// Clear Dynamic Fields
  void _clearDynamicFields() {
    for (var controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    _dynamicFieldControllers.clear();
    _dynamicFieldValues.clear();
    _attributeTemplate = null;
  }

  /// Update Dynamic Field Value
  void updateDynamicFieldValue(String fieldName, String value) {
    _dynamicFieldValues[fieldName] = value;
  }

  /// Get Dynamic Field Value
  String? getDynamicFieldValue(String fieldName) {
    return _dynamicFieldValues[fieldName] ??
        _dynamicFieldControllers[fieldName]?.text;
  }

  /// Pick Images from Gallery (for new images)
  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images.isNotEmpty) {
        _newImages.addAll(images.map((e) => File(e.path)).toList());
        update();
      }
    } catch (e) {
      print('EditProductController: Error picking images: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pick images',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  /// Take Image from Camera (for new images)
  Future<void> takeImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        _newImages.add(File(image.path));
        update();
      }
    } catch (e) {
      print('EditProductController: Error taking image: $e');
      Fluttertoast.showToast(
        msg: 'Failed to take image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  /// Remove New Image (not yet uploaded)
  void removeNewImage(int index) {
    if (index >= 0 && index < _newImages.length) {
      _newImages.removeAt(index);
      update();
    }
  }

  /// Delete Existing Image from Server
  Future<void> deleteExistingImage(int index) async {
    if (index < 0 || index >= _existingImageUrls.length) return;

    final imageUrl = _existingImageUrls[index];
    _isDeletingImage = true;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please login to delete image',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
        _isDeletingImage = false;
        update();
        return;
      }

      final result = await _imageDeleteApiService.deleteProductImage(
        jwtToken: jwtToken,
        productId: productId,
        imageUrl: imageUrl,
      );

      if (result['success'] == true) {
        // Remove from UI
        if (index >= 0 && index < _existingImageUrls.length) {
          _existingImageUrls.removeAt(index);
        }
        Fluttertoast.showToast(
          msg: result['message'] as String? ?? 'Image deleted successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: result['message'] as String? ?? 'Failed to delete image',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('EditProductController: Error deleting image: $e');
      Fluttertoast.showToast(
        msg: 'Error deleting image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      _isDeletingImage = false;
      update();
    }
  }

  /// Get Current Location
  Future<void> getCurrentLocation() async {
    _isGettingLocation = true;
    update();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitudeController.text = position.latitude.toStringAsFixed(6);
      longitudeController.text = position.longitude.toStringAsFixed(6);
    } catch (e) {
      print('EditProductController: Error getting location: $e');
      _setDefaultLocation();
    } finally {
      _isGettingLocation = false;
      update();
    }
  }

  /// Set Default Location
  void _setDefaultLocation() {
    if (latitudeController.text.isEmpty) {
      latitudeController.text = '19.0760';
    }
    if (longitudeController.text.isEmpty) {
      longitudeController.text = '72.8777';
    }
    if (cityController.text.isEmpty) {
      cityController.text = 'Mumbai';
    }
  }

  /// Validate Form
  String? validateForm() {
    _fieldErrors.clear();
    String? firstErrorField;

    if (titleController.text.trim().isEmpty) {
      _fieldErrors['title'] = 'Please enter product title';
      if (firstErrorField == null) firstErrorField = 'title';
    }

    if (_selectedCategoryId == null || _selectedCategoryId?.isEmpty != false) {
      _fieldErrors['category'] = 'Please select a category';
      if (firstErrorField == null) firstErrorField = 'category';
    }

    if (_selectedSubcategoryId == null || _selectedSubcategoryId!.isEmpty) {
      _fieldErrors['subcategory'] = 'Please select a subcategory';
      if (firstErrorField == null) firstErrorField = 'subcategory';
    }

    if (_productType == 'rent' || _productType == 'both') {
      if (rentPriceController.text.trim().isEmpty) {
        _fieldErrors['rentPrice'] = 'Please enter rent price';
        if (firstErrorField == null) firstErrorField = 'rentPrice';
      } else {
        final rentPrice = int.tryParse(rentPriceController.text.trim());
        if (rentPrice == null || rentPrice <= 0) {
          _fieldErrors['rentPrice'] = 'Please enter a valid rent price';
          if (firstErrorField == null) firstErrorField = 'rentPrice';
        }
      }
    }

    if (_productType == 'sell' || _productType == 'both') {
      if (sellPriceController.text.trim().isEmpty) {
        _fieldErrors['sellPrice'] = 'Please enter sell price';
        if (firstErrorField == null) firstErrorField = 'sellPrice';
      } else {
        final sellPrice = int.tryParse(sellPriceController.text.trim());
        if (sellPrice == null || sellPrice <= 0) {
          _fieldErrors['sellPrice'] = 'Please enter a valid sell price';
          if (firstErrorField == null) firstErrorField = 'sellPrice';
        }
      }
    }

    if (cityController.text.trim().isEmpty) {
      _fieldErrors['city'] = 'Please enter city';
      if (firstErrorField == null) firstErrorField = 'city';
    }

    final lat = double.tryParse(latitudeController.text.trim());
    final lng = double.tryParse(longitudeController.text.trim());
    if (lat == null || lng == null) {
      _fieldErrors['coordinates'] = 'Please enter valid coordinates';
      if (firstErrorField == null) firstErrorField = 'coordinates';
    }

    // Validate at least one image exists (existing or new)
    if (_existingImageUrls.isEmpty && _newImages.isEmpty) {
      _fieldErrors['images'] = 'Please select at least one image';
      if (firstErrorField == null) firstErrorField = 'images';
    }

    // Validate dynamic attributes
    if (_attributeTemplate != null) {
      for (var field in _attributeTemplate!.fields) {
        if (field.required) {
          final value = getDynamicFieldValue(field.fieldName);
          if (value == null || value.trim().isEmpty) {
            final fieldLabel = field.fieldName[0].toUpperCase() +
                field.fieldName.substring(1).replaceAll('_', ' ');
            _fieldErrors[field.fieldName] = 'Please enter $fieldLabel';
            if (firstErrorField == null) firstErrorField = field.fieldName;
          } else {
            if (field.fieldType == 'number') {
              final numValue = num.tryParse(value.trim());
              if (numValue == null) {
                final fieldLabel = field.fieldName[0].toUpperCase() +
                    field.fieldName.substring(1).replaceAll('_', ' ');
                _fieldErrors[field.fieldName] =
                    'Please enter a valid number for $fieldLabel';
                if (firstErrorField == null) firstErrorField = field.fieldName;
              }
            }
          }
        }
      }
    }

    update();
    return firstErrorField;
  }

  /// Update Product
  Future<void> updateProduct() async {
    final firstErrorField = validateForm();
    if (firstErrorField != null) {
      final errorMessage = _fieldErrors[firstErrorField];
      if (errorMessage != null) {
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
      if (onErrorFieldScroll != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          onErrorFieldScroll!(firstErrorField);
        });
      }
      return;
    }

    _isSubmitting = true;
    update();

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please login to update product',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
        _isSubmitting = false;
        update();
        return;
      }

      // Build price map
      final priceMap = <String, int>{
        'rent': _productType == 'rent' || _productType == 'both'
            ? int.parse(rentPriceController.text.trim())
            : 0,
        'sell': _productType == 'sell' || _productType == 'both'
            ? int.parse(sellPriceController.text.trim())
            : 0,
      };

      // Build location map
      final locationMap = <String, dynamic>{
        'city': cityController.text.trim(),
        'lat': double.parse(latitudeController.text.trim()),
        'lng': double.parse(longitudeController.text.trim()),
      };

      // Build attributes map
      final attributesMap = <String, dynamic>{};
      if (_attributeTemplate != null) {
        for (var field in _attributeTemplate!.fields) {
          final value = getDynamicFieldValue(field.fieldName);
          if (value != null && value.trim().isNotEmpty) {
            if (field.fieldType == 'number') {
              attributesMap[field.fieldName] = num.tryParse(value.trim()) ?? value.trim();
            } else {
              attributesMap[field.fieldName] = value.trim();
            }
          }
        }
      }

      // Create update request - only new images, not existing ones
      final request = ProductUpdateRequestModel(
        productType: _productType,
        price: priceMap,
        location: locationMap,
        title: titleController.text.trim(),
        newImages: _newImages, // Only new images
        categoryId: _selectedCategoryId!,
        subCategoryId: _selectedSubcategoryId!,
        description: descriptionController.text.trim(),
        attributes: attributesMap,
      );

      final response = await _productUpdateApiService.updateProduct(
        jwtToken: jwtToken,
        productId: productId,
        request: request,
      );

      _isSubmitting = false;
      update();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Product updated successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
        // Navigate back
        Get.back();
      } else {
        Fluttertoast.showToast(
          msg: response.message.isNotEmpty
              ? response.message
              : 'Failed to update product',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      _isSubmitting = false;
      update();
      print('EditProductController: Error updating product: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred while updating product',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }
}

