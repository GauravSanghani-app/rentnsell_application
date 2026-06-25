import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/response/profile_get_response_model.dart';
import '../../../services/profile_api_service.dart';
import '../../../services/fcm_api_service.dart';
import '../../../services/fcm_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/shared_pref.dart';
import '../../../config/routes/route_manager.dart';
import '../../auth/auth_controller.dart';
import '../../auth/profile_controller.dart' as auth_profile;
import 'profile_controller.dart' as profile_screen;

class ProfileSettingsController extends GetxController {
  final ProfileApiService _apiService =
      ProfileApiService(); // Use real API for getProfile and updateProfile
  final FcmApiService _fcmApiService = FcmApiService();

  ProfileGetResponseData? _profileData;
  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isLoggingOut = false;
  bool _isDeletingAccount = false;

  // Profile image
  String? _selectedImagePath;
  String? _serverImageUrl;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Settings
  String _phone = '';
  String _countryCode = '+1';
  String _address = '';
  String? _selectedGender;

  // Getters
  ProfileGetResponseData? get profileData => _profileData;
  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  bool get isLoggingOut => _isLoggingOut;
  bool get isDeletingAccount => _isDeletingAccount;
  String? get selectedImagePath => _selectedImagePath;
  String? get serverImageUrl => _serverImageUrl;
  String get phone => _phone;
  String get countryCode => _countryCode;
  String get address => _address;
  String? get selectedGender => _selectedGender;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.onClose();
  }

  bool _hasInitialized = false; // Guard to prevent multiple initializations

  @override
  void onInit() {
    super.onInit();
    // Only load profile once when controller is first initialized
    if (!_hasInitialized) {
      _hasInitialized = true;
      loadProfile();
    }
  }

  bool _isLoadingProfile =
      false; // Guard to prevent multiple simultaneous calls

  Future<void> loadProfile() async {
    // Prevent multiple simultaneous calls
    if (_isLoadingProfile) {
      return;
    }

    _isLoadingProfile = true;
    _isLoading = true;
    update(['profile_settings']);

    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        // No token - silently return without showing any message
        // Login is optional, so we don't force login prompts
        _isLoading = false;
        _isLoadingProfile = false;
        update([
          'profile_settings',
        ]); // Use specific ID to prevent unnecessary rebuilds
        return;
      }

      final response = await _apiService.getProfile(jwtToken: jwtToken);

      if (response.success && response.data != null) {
        _profileData = response.data!;
        // Extract phone number from mobile field
        _phone = _profileData!.mobile.replaceFirst(RegExp(r'^\+\d+'), '');
        final phoneWithCode = _profileData!.mobile;
        if (phoneWithCode.startsWith('+')) {
          final match = RegExp(r'^(\+\d{1,4})').firstMatch(phoneWithCode);
          if (match != null) {
            _countryCode = match.group(1)!;
          }
        }
        // Use address from API response
        _address = _profileData!.address ?? '';
        _selectedGender = _profileData!.gender;
        _serverImageUrl = _profileData!.profileImage;

        // Update form controllers
        nameController.text = _profileData!.name ?? '';
        emailController.text = _profileData!.email ?? '';
        phoneController.text = _phone;
        addressController.text = _address;
        ageController.text = _profileData!.age?.toString() ?? '0';

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
      print('ProfileSettingsController: Error loading profile: $e');
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
      update([
        'profile_settings',
      ]); // Use specific ID to prevent unnecessary rebuilds
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
        update(['profile_settings']);
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
    update(['profile_settings']);
  }

  void setPhone(String phone) {
    _phone = phone;
    update(['profile_settings']);
  }

  void setAddress(String address) {
    _address = address;
    addressController.text = address;
    update(['profile_settings']);
  }

  void setGender(String gender) {
    _selectedGender = gender;
    update(['profile_settings']);
  }

  Future<bool> updateProfile() async {
    _isUpdating = true;
    update(['profile_settings']);

    try {
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

      // Get form values
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final gender = _selectedGender;
      final address = addressController.text.trim();
      final age = ageController.text.trim();

      // Prepare profile image file if selected
      File? profileImageFile;
      if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
        profileImageFile = File(_selectedImagePath!);
        if (!await profileImageFile.exists()) {
          profileImageFile = null;
        }
      }

      // Call real API
      final response = await _apiService.updateProfile(
        jwtToken: jwtToken,
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        gender: gender,
        address: address.isNotEmpty ? address : null,
        age: age.isNotEmpty ? age : null,
        profileImage: profileImageFile,
      );

      if (response.success && response.data != null) {
        // Update local state from response
        _profileData = response.data!;
        _serverImageUrl = _profileData!.profileImage;
        _selectedImagePath =
            null; // Clear selected image after successful upload

        // Update form controllers with new data (no need to reload, we already have the response)
        nameController.text = _profileData!.name ?? '';
        emailController.text = _profileData!.email ?? '';
        addressController.text = _profileData!.address ?? '';
        ageController.text = _profileData!.age?.toString() ?? '0';
        _selectedGender = _profileData!.gender;

        // Update local profile
        await _updateLocalProfile();

        // Refresh ProfileScreenController if it exists
        if (Get.isRegistered<profile_screen.ProfileScreenController>()) {
          try {
            final profileScreenController =
                Get.find<profile_screen.ProfileScreenController>();
            await profileScreenController.refreshProfile();
          } catch (e) {
            print(
              'ProfileSettingsController: Error refreshing ProfileScreenController: $e',
            );
          }
        }

        Fluttertoast.showToast(
          msg: response.message.isNotEmpty
              ? response.message
              : 'Profile updated successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
        );

        // Navigate back after successful update
        Get.back();

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
      print('ProfileSettingsController: Error updating profile: $e');
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
      update(['profile_settings']);
    }
  }

  Future<void> _updateLocalProfile() async {
    if (_profileData == null) return;

    try {
      if (Get.isRegistered<auth_profile.ProfileController>()) {
        final profileController = Get.find<auth_profile.ProfileController>();
        profileController.email = _profileData!.email ?? '';
        profileController.phone = _phone;
        profileController.countryCode = _countryCode;
        profileController.age = _profileData!.age.toString();
        profileController.gender = _profileData!.gender ?? '';
        profileController.address = _profileData!.address ?? '';
        profileController.update();
      }
    } catch (e) {
      print('ProfileSettingsController: Error updating local profile: $e');
    }
  }

  Future<void> logout() async {
    _isLoggingOut = true;
    update();

    try {
      // Get JWT token before clearing it
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      
      // Remove FCM token from API before logout
      if (jwtToken != null && jwtToken.isNotEmpty) {
        await _removeFcmToken(jwtToken);
      }

      // Clear local storage - use SharedPreferences directly
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SharedPreference.jwtToken);
      await prefs.remove(SharedPreference.refreshToken);
      await prefs.remove(SharedPreference.fcmToken);
      await preferences.putBool(SharedPreference.isLogIn, false);

      // Clear AuthController
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.signOut();
      }

      Fluttertoast.showToast(
        msg: 'Logged out successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.mobileLogin);
    } catch (e) {
      print('ProfileSettingsController: Error logging out: $e');
      Fluttertoast.showToast(
        msg: 'Failed to logout: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      _isLoggingOut = false;
      update();
    }
  }

  Future<void> _removeFcmToken(String jwtToken) async {
    try {
      // Get FCM token from FCMService or shared preferences
      String? fcmToken;
      if (Get.isRegistered<FCMService>()) {
        final fcmService = Get.find<FCMService>();
        fcmToken = await fcmService.getToken();
      } else {
        // If FCMService is not registered, try to get token from shared preferences
        fcmToken = preferences.getString(SharedPreference.fcmToken);
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        // Remove FCM token from API
        final response = await _fcmApiService.removeFcmToken(
          jwtToken: jwtToken,
          token: fcmToken,
        );

        if (response.success) {
          print('ProfileSettingsController: FCM token removed successfully');
        } else {
          print('ProfileSettingsController: Failed to remove FCM token: ${response.message}');
        }
      } else {
        print('ProfileSettingsController: FCM token not available');
      }
    } catch (e) {
      print('ProfileSettingsController: Error removing FCM token: $e');
      // Don't show error to user - FCM token removal failure shouldn't block logout
    }
  }

  Future<void> deleteAccount() async {
    _isDeletingAccount = true;
    update();

    try {
      // Clear all local storage
      preferences.clearUserItem();

      // Clear AuthController
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        await authController.signOut();
      }

      Fluttertoast.showToast(
        msg: 'Account deleted successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green.shade700,
        textColor: Colors.white,
      );

      // Navigate to login screen
      Get.offAllNamed(AppRoutes.mobileLogin);
    } catch (e) {
      print('ProfileSettingsController: Error deleting account: $e');
      Fluttertoast.showToast(
        msg: 'Failed to delete account: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
    } finally {
      _isDeletingAccount = false;
      update();
    }
  }
}
