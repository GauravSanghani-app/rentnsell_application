import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/category_model.dart';
import '../../../models/subcategory_model.dart';
import '../../../models/attribute_template_model.dart';
import '../../../services/category_api_service.dart';
import '../../../services/subcategory_api_service.dart';
import '../../../services/attribute_template_api_service.dart';
import '../../../services/product_create_api_service.dart';
import '../../../models/request/product_create_request_model.dart';
import '../../../utils/shared_pref.dart';
import '../widgets/location_selection_bottom_sheet.dart';

/// Add Product Controller
///
/// Manages the state and logic for the Add Product screen
class AddProductController extends GetxController {
  final CategoryApiService _categoryService = CategoryApiService();
  final SubcategoryApiService _subcategoryService = SubcategoryApiService();
  final AttributeTemplateApiService _attributeTemplateService =
      AttributeTemplateApiService();
  final ProductCreateApiService _productCreateApiService =
      ProductCreateApiService();

  // Product Type: 'rent', 'sell', or 'both'
  String _productType;
  final String _initialProductType; // Store original type for checkbox logic
  bool _isBothRentSell = false; // Checkbox state

  // Callback for scrolling to error field
  Function(String)? onErrorFieldScroll;

  AddProductController({
    String initialProductType = 'rent',
    this.onErrorFieldScroll,
  }) : _productType = initialProductType,
       _initialProductType = initialProductType;

  // Fixed Form Fields
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final rentPriceController = TextEditingController();
  final sellPriceController = TextEditingController();

  // Location (stored internally, not shown to user)
  String? _selectedLocationName;
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Category & Subcategory
  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  List<SubcategoryModel> _subcategories = [];
  String? _selectedSubcategoryId;

  // Attribute Template & Dynamic Fields
  AttributeTemplateModel? _attributeTemplate;
  Map<String, TextEditingController> _dynamicFieldControllers = {};
  final Map<String, String> _dynamicFieldValues = {};

  // Images
  List<File> _selectedImages = [];

  // Error States - Map of field name to error message
  final Map<String, String> _fieldErrors = {};

  // Loading States
  bool _isLoadingCategories = false;
  bool _isLoadingSubcategories = false;
  bool _isLoadingAttributeTemplate = false;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;

  // Getters
  String get productType => _productType;
  bool get isBothRentSell => _isBothRentSell;
  String get initialProductType => _initialProductType;
  Map<String, String> get fieldErrors => _fieldErrors;

  /// Get error message for a field
  String? getFieldError(String fieldName) => _fieldErrors[fieldName];

  /// Clear error for a field
  void clearFieldError(String fieldName) {
    _fieldErrors.remove(fieldName);
    update();
  }

  /// Clear all errors
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
  List<File> get selectedImages => _selectedImages;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingSubcategories => _isLoadingSubcategories;
  bool get isLoadingAttributeTemplate => _isLoadingAttributeTemplate;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingLocation => _isLoadingLocation;
  String? get selectedLocationName => _selectedLocationName;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    rentPriceController.dispose();
    sellPriceController.dispose();

    // Dispose dynamic field controllers
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
      _productType = _initialProductType; // Revert to original type
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
      print('AddProductController: Error loading categories: $e');
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
      print('AddProductController: Error loading subcategories: $e');
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
      } else {
        _attributeTemplate = null;
      }
    } catch (e) {
      print('AddProductController: Error loading attribute template: $e');
      _attributeTemplate = null;
    } finally {
      _isLoadingAttributeTemplate = false;
      update();
    }
  }

  /// Initialize Dynamic Fields
  void _initializeDynamicFields() {
    // Dispose existing controllers
    for (var controller in _dynamicFieldControllers.values) {
      controller.dispose();
    }
    _dynamicFieldControllers.clear();
    _dynamicFieldValues.clear();

    // Create controllers for each field (except gender which uses selection)
    if (_attributeTemplate != null) {
      for (var field in _attributeTemplate!.fields) {
        // Gender field doesn't need a TextEditingController, it uses selection
        if (field.fieldName.toLowerCase() != 'gender') {
          _dynamicFieldControllers[field.fieldName] = TextEditingController();
        }
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
    update();
  }

  /// Set Gender Selection
  void setGenderSelection(String gender) {
    _dynamicFieldValues['gender'] = gender;
    clearFieldError('gender');
    update();
  }

  /// Get Selected Gender
  String? getSelectedGender() {
    return _dynamicFieldValues['gender'];
  }

  /// Get Dynamic Field Value
  String? getDynamicFieldValue(String fieldName) {
    return _dynamicFieldValues[fieldName] ??
        _dynamicFieldControllers[fieldName]?.text;
  }

  /// Pick Images from Gallery
  Future<void> pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images.isNotEmpty) {
        _selectedImages.addAll(images.map((e) => File(e.path)).toList());
        update();
      }
    } catch (e) {
      print('AddProductController: Error picking images: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pick images',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  /// Take Image from Camera
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
        _selectedImages.add(File(image.path));
        update();
      }
    } catch (e) {
      print('AddProductController: Error taking image: $e');
      Fluttertoast.showToast(
        msg: 'Failed to take image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }

  /// Remove Image
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      update();
    }
  }

  /// Show Location Selection Bottom Sheet
  void showLocationSelection() {
    Get.bottomSheet(
      LocationSelectionBottomSheet(
        onLocationSelected:
            (
              String placeId,
              String description,
              double latitude,
              double longitude,
            ) {
              // Nominatim API already provides coordinates directly
              // No need for additional API call
              _selectedLatitude = latitude;
              _selectedLongitude = longitude;
              _selectedLocationName = description;
              clearFieldError('location');
              print(
                'AddProductController: Location selected - Lat: $latitude, Long: $longitude, Description: $description',
              );
              update();
            },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Validate Form
  /// Returns the first error field name if validation fails, null if valid
  String? validateForm() {
    _fieldErrors.clear();
    String? firstErrorField;

    // Validate title
    if (titleController.text.trim().isEmpty) {
      _fieldErrors['title'] = 'Please enter product title';
      if (firstErrorField == null) firstErrorField = 'title';
    }

    // Validate category
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _fieldErrors['category'] = 'Please select a category';
      if (firstErrorField == null) firstErrorField = 'category';
    }

    // Validate subcategory
    if (_selectedSubcategoryId == null || _selectedSubcategoryId!.isEmpty) {
      _fieldErrors['subcategory'] = 'Please select a subcategory';
      if (firstErrorField == null) firstErrorField = 'subcategory';
    }

    // Validate price based on product type
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

    // Validate location
    if (_selectedLocationName == null ||
        _selectedLocationName!.trim().isEmpty ||
        _selectedLatitude == null ||
        _selectedLongitude == null) {
      _fieldErrors['location'] = 'Please select a location';
      if (firstErrorField == null) firstErrorField = 'location';
    }

    // Validate images
    if (_selectedImages.isEmpty) {
      _fieldErrors['images'] = 'Please select at least one image';
      if (firstErrorField == null) firstErrorField = 'images';
    }

    // Validate dynamic attributes
    if (_attributeTemplate != null) {
      for (var field in _attributeTemplate!.fields) {
        if (field.required) {
          final value = getDynamicFieldValue(field.fieldName);
          if (value == null || value.trim().isEmpty) {
            final fieldLabel =
                field.fieldName[0].toUpperCase() +
                field.fieldName.substring(1).replaceAll('_', ' ');
            // Special message for gender field
            if (field.fieldName.toLowerCase() == 'gender') {
              _fieldErrors[field.fieldName] = 'Please select $fieldLabel';
            } else {
              _fieldErrors[field.fieldName] = 'Please enter $fieldLabel';
            }
            if (firstErrorField == null) firstErrorField = field.fieldName;
          } else {
            // Validate number fields
            if (field.fieldType == 'number') {
              final numValue = num.tryParse(value.trim());
              if (numValue == null) {
                final fieldLabel =
                    field.fieldName[0].toUpperCase() +
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

  /// Submit Product
  Future<void> submitProduct() async {
    final firstErrorField = validateForm();
    if (firstErrorField != null) {
      // Show toast for first error
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
      // Notify screen to scroll to error field via callback
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
          msg: 'Please login to add product',
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
        'city': _selectedLocationName ?? '',
        'lat': _selectedLatitude!,
        'lng': _selectedLongitude!,
      };

      // Build attributes map
      final attributesMap = <String, dynamic>{};
      if (_attributeTemplate != null) {
        for (var field in _attributeTemplate!.fields) {
          final value = getDynamicFieldValue(field.fieldName);
          if (value != null && value.trim().isNotEmpty) {
            if (field.fieldType == 'number') {
              attributesMap[field.fieldName] =
                  num.tryParse(value.trim()) ?? value.trim();
            } else {
              attributesMap[field.fieldName] = value.trim();
            }
          }
        }
      }

      // Create request model
      final request = ProductCreateRequestModel(
        productType: _productType,
        price: priceMap,
        location: locationMap,
        title: titleController.text.trim(),
        images: _selectedImages,
        categoryId: _selectedCategoryId!,
        subCategoryId: _selectedSubcategoryId!,
        description: descriptionController.text.trim(),
        attributes: attributesMap,
      );

      // Call API
      final response = await _productCreateApiService.createProduct(
        jwtToken: jwtToken,
        request: request,
      );

      _isSubmitting = false;
      update();

      if (response.success) {
        Fluttertoast.showToast(
          msg: 'Product added successfully!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );
        // Navigate back
        Get.back();
        // Optionally refresh product list
      } else {
        Fluttertoast.showToast(
          msg: response.message.isNotEmpty
              ? response.message
              : 'Failed to add product',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      _isSubmitting = false;
      update();
      print('AddProductController: Error submitting product: $e');
      Fluttertoast.showToast(
        msg: 'An error occurred while adding product',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    }
  }
}
