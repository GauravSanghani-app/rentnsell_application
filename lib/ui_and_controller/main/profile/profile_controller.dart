import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/category_model.dart';
import '../../../models/response/profile_get_response_model.dart';
import '../../../models/request/profile_update_request_model.dart';
import '../../../services/category_api_service.dart';
import '../../../services/profile_api_service.dart';
import '../../../utils/shared_pref.dart';
import '../../auth/profile_controller.dart' as auth_profile;

class ProfileScreenController extends GetxController {
  final ProfileApiService _apiService =
      ProfileApiService(); // Use live API for getProfile and updateProfile
  final CategoryApiService _categoryService = CategoryApiService();

  ProfileGetResponseData? _profileData;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isUpdating = false;

  // Profile image
  String? _selectedImagePath; // Local file path for selected image
  String? _serverImageUrl; // Server URL for profile image

  // Settings
  String _phone = '';
  String _countryCode = '+1';
  String _address = '';
  bool _showAddressToAll = false;
  List<String> _selectedCategoryIds = [];
  List<String> _selectedActions = [];

  // Getters
  ProfileGetResponseData? get profileData => _profileData;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String? get selectedImagePath => _selectedImagePath;
  String? get serverImageUrl => _serverImageUrl;
  String get phone => _phone;
  String get countryCode => _countryCode;
  String get address => _address;
  bool get showAddressToAll => _showAddressToAll;
  List<String> get selectedCategoryIds => _selectedCategoryIds;
  List<String> get selectedActions => _selectedActions;

  // Get display image - priority: selected image > server image > Google photo > null
  String? get displayImagePath {
    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      return _selectedImagePath;
    }
    if (_serverImageUrl != null && _serverImageUrl!.isNotEmpty) {
      return _serverImageUrl;
    }
    return _profileData?.photoUrl;
  }

  bool _hasInitialized = false; // Guard to prevent multiple initializations
  bool _isLoadingProfile =
      false; // Guard to prevent multiple simultaneous calls

  @override
  void onInit() {
    super.onInit();
    // Only load profile once when controller is first initialized
    if (!_hasInitialized) {
      _hasInitialized = true;
      loadProfile();
      loadCategories();
    }
  }

  Future<void> loadProfile() async {
    // Prevent multiple simultaneous calls
    if (_isLoadingProfile) {
      return;
    }

    _isLoadingProfile = true;
    _isLoading = true;
    update();

    try {
      // Get JWT token from local storage
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        // No token - silently return without showing any message
        // Login is optional, so we don't force login prompts
        _isLoading = false;
        _isLoadingProfile = false;
        update();
        return;
      }

      // Call GET Profile API
      final response = await _apiService.getProfile(jwtToken: jwtToken);

      if (response.success && response.data != null) {
        _profileData = response.data!;
        // Extract phone number from mobile field
        _phone = _profileData!.mobile.replaceFirst(RegExp(r'^\+\d+'), '');
        // Extract country code from mobile
        final phoneWithCode = _profileData!.mobile;
        if (phoneWithCode.startsWith('+')) {
          final match = RegExp(r'^(\+\d{1,4})').firstMatch(phoneWithCode);
          if (match != null) {
            _countryCode = match.group(1)!;
          }
        }
        // Use address from API response
        _address = _profileData!.address ?? '';
        _showAddressToAll =
            false; // Not in API response (can be added if needed)
        _selectedCategoryIds =
            []; // Not in API response (can be added if needed)
        _selectedActions = []; // Not in API response (can be added if needed)
        _serverImageUrl = _profileData!.profileImage;

        // Also update local profile
        await _updateLocalProfile();
      } else {
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('ProfileScreenController: Error loading profile: $e');
      Fluttertoast.showToast(
        msg: 'Failed to load profile: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      _isLoading = false;
      _isLoadingProfile = false;
      update();
    }
  }

  /// Refresh profile data - can be called externally to reload profile
  Future<void> refreshProfile() async {
    _hasInitialized = false; // Reset initialization flag to allow reload
    await loadProfile();
  }

  Future<void> loadCategories() async {
    try {
      _categories = await _categoryService.getCategories();
      update();
    } catch (e) {
      print('ProfileScreenController: Error loading categories: $e');
    }
  }

  Future<String?> pickImage({ImageSource? source}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source ?? ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        _selectedImagePath = image.path;
        update();
        return image.path;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(
        msg: 'Failed to pick image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return null;
    }
  }

  Future<String?> convertImageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      List<int> imageBytes = await imageFile.readAsBytes();
      return base64Encode(imageBytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  String? getImageMimeType(String imagePath) {
    final extension = imagePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return null;
    }
  }

  void setCountryCode(String code) {
    _countryCode = code;
    update();
  }

  void setPhone(String phone) {
    _phone = phone;
    update();
  }

  void setAddress(String address) {
    _address = address;
    update();
  }

  void toggleAddressVisibility(bool value) {
    _showAddressToAll = value;
    update();
  }

  void toggleCategory(String categoryId) {
    if (_selectedCategoryIds.contains(categoryId)) {
      _selectedCategoryIds.remove(categoryId);
    } else {
      _selectedCategoryIds.add(categoryId);
    }
    update();
  }

  void toggleAction(String action) {
    if (_selectedActions.contains(action)) {
      _selectedActions.remove(action);
    } else {
      _selectedActions.add(action);
    }
    update();
  }

  Future<bool> updateProfile({
    bool updateImage = false,
    bool updatePhone = false,
    bool updateAddress = false,
    bool updateAddressVisibility = false,
    bool updateCategories = false,
    bool updateInterests = false,
  }) async {
    _isUpdating = true;
    update();

    try {
      // Get JWT token from local storage
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please login to update profile',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
        _isUpdating = false;
        update();
        return false;
      }

      // Build update request
      final request = ProfileUpdateRequestModel(
        phone: updatePhone ? '$_countryCode$_phone' : null,
        address: updateAddress ? _address : null,
        showAddressToAll: updateAddressVisibility ? _showAddressToAll : null,
        interestedCategoryIds: updateCategories ? _selectedCategoryIds : null,
        interestedActions: updateInterests ? _selectedActions : null,
      );

      if (updateImage &&
          _selectedImagePath != null &&
          _selectedImagePath!.isNotEmpty) {
        final imageBase64 = await convertImageToBase64(_selectedImagePath!);
        if (imageBase64 != null) {
          request.profileImageBase64 = imageBase64;
          request.profileImageName = _selectedImagePath!.split('/').last;
          request.profileImageType = getImageMimeType(_selectedImagePath!);
        }
      }

      // Call UPDATE Profile API using real API service
      // Note: The real API expects name, email, gender, address, age, profileImage
      // This method is kept for backward compatibility but should use ProfileSettingsController for updates
      File? profileImageFile;
      if (updateImage &&
          _selectedImagePath != null &&
          _selectedImagePath!.isNotEmpty) {
        profileImageFile = File(_selectedImagePath!);
        if (!await profileImageFile.exists()) {
          profileImageFile = null;
        }
      }

      final response = await _apiService.updateProfile(
        jwtToken: jwtToken,
        name: _profileData?.name,
        email: _profileData?.email,
        gender: _profileData?.gender,
        address: updateAddress ? _address : _profileData?.address,
        age: _profileData?.age?.toString(),
        profileImage: profileImageFile,
      );

      if (response.success && response.data != null) {
        final data = response.data!;

        // Update local state from API response
        _profileData = data;
        if (data.profileImage != null && data.profileImage!.isNotEmpty) {
          _serverImageUrl = data.profileImage;
          _selectedImagePath =
              null; // Clear selected image after successful upload
        }
        if (data.address != null) {
          _address = data.address!;
        }
        // Extract phone number from mobile field
        if (data.mobile.isNotEmpty) {
          _phone = data.mobile.replaceFirst(RegExp(r'^\+\d+'), '');
          final phoneWithCode = data.mobile;
          if (phoneWithCode.startsWith('+')) {
            final match = RegExp(r'^(\+\d{1,4})').firstMatch(phoneWithCode);
            if (match != null) {
              _countryCode = match.group(1)!;
            }
          }
        }

        // Reload profile to get latest data
        await refreshProfile();

        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );

        return true;
      } else {
        Fluttertoast.showToast(
          msg: response.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red.shade700,
          textColor: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print('ProfileScreenController: Error updating profile: $e');
      Fluttertoast.showToast(
        msg: 'Failed to update profile: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return false;
    } finally {
      _isUpdating = false;
      update();
    }
  }

  Future<void> _updateLocalProfile() async {
    if (_profileData == null) return;

    try {
      // Update local profile using ProfileService
      if (Get.isRegistered<auth_profile.ProfileController>()) {
        final profileController = Get.find<auth_profile.ProfileController>();
        profileController.email = _profileData!.email ?? '';
        profileController.phone = _phone;
        profileController.countryCode = _countryCode;
        profileController.age =
            '0'; // Not in API response (can be added if needed)
        profileController.gender = _profileData!.gender ?? '';
        profileController.address = _address;
        profileController.selectedCategoryIds = List.from(_selectedCategoryIds);
        profileController.selectedActions = List.from(_selectedActions);
        profileController.update();
      }
    } catch (e) {
      print('ProfileScreenController: Error updating local profile: $e');
    }
  }
}
