import 'dart:io';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category_model.dart';
import '../../models/user_profile_model.dart';
import '../../services/category_api_service.dart';
import '../../services/profile_api_service.dart';
import '../../services/profile_service.dart';
import '../../services/fcm_service.dart';
import '../../utils/shared_pref.dart';
import '../../utils/extension.dart';
import 'auth_controller.dart';

class ProfileController extends GetxController {
  final ProfileService _profileService = ProfileService();
  final CategoryApiService _categoryService = CategoryApiService();
  final ProfileApiService _apiService = ProfileApiService();

  UserProfileModel? _profile;
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // Form fields
  String email = '';
  String phone = '';
  String countryCode = '+1';
  String age = '';
  String gender = '';
  String address = '';
  List<String> selectedCategoryIds = [];
  List<String> selectedActions = [];

  // Profile image
  String? _selectedImagePath; // Local file path for selected image
  String? get selectedImagePath => _selectedImagePath;

  // Available options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> actionOptions = [
    'Sell',
    'Rent',
    'Buy',
    'Not decided yet',
    'Want rental things',
  ];

  UserProfileModel? get profile => _profile;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  void loadCategories() async {
    _isLoading = true;
    update();

    try {
      _categories = await _categoryService.getCategories();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      update();
    }
  }

  void loadProfile() {
    _profile = _profileService.getProfile();
    if (_profile != null) {
      email = _profile!.email;
      phone = _profile!.phone;
      age = _profile!.age.toString();
      gender = _profile!.gender;
      address = _profile!.address;
      selectedCategoryIds = List.from(_profile!.interestedCategoryIds);
      selectedActions = List.from(_profile!.interestedActions);
    }
    update();
  }

  void prefillFromGoogle(Map<String, dynamic> googleData) {
    email = googleData['email'] ?? '';

    // Store Google data for access in UI
    String? googleId = googleData['id'];
    String? displayName = googleData['displayName'];
    String? photoUrl = googleData['photoUrl'];

    if (_profile == null) {
      _profile = UserProfileModel(
        googleId: googleId,
        email: email,
        displayName: displayName,
        photoUrl: photoUrl,
        phone: '',
        age: 0,
        gender: '',
        address: '',
        interestedCategoryIds: [],
        interestedActions: [],
      );
    } else {
      _profile = UserProfileModel(
        googleId: googleId ?? _profile!.googleId,
        email: email,
        displayName: displayName ?? _profile!.displayName,
        photoUrl: photoUrl ?? _profile!.photoUrl,
        phone: _profile!.phone,
        age: _profile!.age,
        gender: _profile!.gender,
        address: _profile!.address,
        interestedCategoryIds: _profile!.interestedCategoryIds,
        interestedActions: _profile!.interestedActions,
      );
    }
    update();
  }

  // Getters for Google data
  String? get googleId => _profile?.googleId;
  String? get displayName => _profile?.displayName;
  String? get photoUrl => _profile?.photoUrl;

  // Profile image getter - returns selected image path, or Google photo, or null
  String? get profileImagePath => _selectedImagePath;

  // Get display image - priority: selected image > Google photo > null
  String? get displayImagePath {
    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      return _selectedImagePath;
    }
    return _profile?.photoUrl;
  }

  void setSelectedImagePath(String? imagePath) {
    _selectedImagePath = imagePath;
    update();
  }

  void setCountryCode(String code) {
    countryCode = code;
    update();
  }

  void setGender(String value) {
    gender = value;
    update();
  }

  void toggleCategory(String categoryId) {
    if (selectedCategoryIds.contains(categoryId)) {
      selectedCategoryIds.remove(categoryId);
    } else {
      selectedCategoryIds.add(categoryId);
    }
    update();
  }

  void toggleAction(String action) {
    if (selectedActions.contains(action)) {
      selectedActions.remove(action);
    } else {
      selectedActions.add(action);
    }
    update();
  }

  Future<String?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
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
      print('ProfileController: Error picking image: $e');
      return null;
    }
  }

  Future<String?> convertImageToBase64(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      final List<int> imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);
      return base64Image;
    } catch (e) {
      print('ProfileController: Error converting image to base64: $e');
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
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  bool get isFormValid {
    return email.isNotEmpty &&
        phone.isNotEmpty &&
        age.isNotEmpty &&
        int.tryParse(age) != null &&
        int.parse(age) >= 13 &&
        int.parse(age) <= 120 &&
        gender.isNotEmpty &&
        address.isNotEmpty &&
        selectedCategoryIds.isNotEmpty &&
        selectedActions.isNotEmpty;
  }

  Future<bool> saveProfile() async {
    if (!isFormValid) {
      return false;
    }

    _isSaving = true;
    update();

    try {
      final profile = UserProfileModel(
        googleId: _profile?.googleId,
        email: email,
        displayName: _profile?.displayName,
        photoUrl: _profile?.photoUrl,
        phone: '$countryCode$phone',
        age: int.parse(age),
        gender: gender,
        address: address,
        interestedCategoryIds: selectedCategoryIds,
        interestedActions: selectedActions,
      );

      // Get FCM token
      String? fcmToken;
      try {
        final fcmService = Get.find<FCMService>();
        fcmToken = await fcmService.getToken();
        if (fcmToken != null) {
          await preferences.putString(SharedPreference.fcmToken, fcmToken);
        }
      } catch (e) {
        print(
          'ProfileController: FCM Service not found, continuing without FCM token',
        );
        // Try to get from local storage
        fcmToken = preferences.getString(SharedPreference.fcmToken);
      }

      // Get JWT token - required for API call
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        final context = Get.context;
        if (context != null) {
          context.showErrorToast(
            message: 'Please login first to save profile',
          );
        }
        return false;
      }

      // Convert selected image to File if user selected a new image
      File? profileImageFile;
      if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
        profileImageFile = File(_selectedImagePath!);
        if (!await profileImageFile.exists()) {
          profileImageFile = null;
        }
      }

      // Call real API to update profile
      final response = await _apiService.updateProfile(
        jwtToken: jwtToken,
        name: profile.displayName,
        email: profile.email,
        gender: profile.gender,
        address: profile.address,
        age: profile.age.toString(),
        profileImage: profileImageFile,
      );

      // Check if API call was successful
      if (response.success && response.data != null) {
        // Save profile locally
        final saved = await _profileService.saveProfile(profile);
        if (saved) {
          _profile = profile;
          try {
            Get.find<AuthController>().refreshProfileStatus();
          } catch (e) {
            // AuthController might not be initialized
          }
          // Don't show toast here - let the calling controller handle it
          return true;
        }
      } else {
        // Show error message
        final context = Get.context;
        if (context != null) {
          context.showErrorToast(message: response.message);
        }
        return false;
      }

      return false;
    } catch (e) {
      print('ProfileController: Error saving profile: $e');
      final context = Get.context;
      if (context != null) {
        context.showErrorToast(
          message: 'Error saving profile: ${e.toString()}',
        );
      }
      return false;
    } finally {
      _isSaving = false;
      update();
    }
  }
}
