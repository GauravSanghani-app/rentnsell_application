import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/routes/route_manager.dart';
import '../../../services/signup_api_service.dart';
import '../../../utils/shared_pref.dart';
import '../../auth/auth_controller.dart';

class SignupController extends GetxController {
  final SignupApiService _signupApiService = SignupApiService();
  final ImagePicker _imagePicker = ImagePicker();
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  File? _selectedImage;
  String? _selectedGender;

  bool get isLoading => _isLoading;
  File? get selectedImage => _selectedImage;
  String? get selectedGender => _selectedGender;

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    genderController.dispose();
    addressController.dispose();
    ageController.dispose();
    super.onClose();
  }

  Future<void> pickImage({required ImageSource source}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        update();
        _showToast('Profile image selected', isError: false);
      }
    } catch (e) {
      print('SignupController: Error picking image: $e');
      _showToast('Failed to select image. Please try again.', isError: true);
    }
  }

  void setGender(String gender) {
    _selectedGender = gender;
    genderController.text = gender;
    update();
  }

  Future<void> signup() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Validate gender selection
    if (_selectedGender == null || _selectedGender!.isEmpty) {
      _showToast('Please select your gender', isError: true);
      return;
    }

    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final email = emailController.text.trim();
    final gender = _selectedGender!;
    final address = addressController.text.trim();
    final age = ageController.text.trim();

    // Validate age
    final ageInt = int.tryParse(age);
    if (ageInt == null || ageInt < 1 || ageInt > 120) {
      _showToast('Please enter a valid age', isError: true);
      return;
    }

    _isLoading = true;
    update();

    try {
      final signupResponse = await _signupApiService.signup(
        name: name,
        mobile: mobile,
        email: email,
        gender: gender,
        address: address,
        age: age,
        profileImage: _selectedImage,
      );

      if (signupResponse.success && signupResponse.token != null) {
        final signupData = signupResponse.token!;
        
        // Save token and user data
        await preferences.putString(
          SharedPreference.jwtToken,
          signupData.token,
        );
        await preferences.putString(
          SharedPreference.userId,
          signupData.user.id,
        );
        await preferences.putString(
          SharedPreference.userEmail,
          signupData.user.email,
        );
        await preferences.putString(
          SharedPreference.userFirstName,
          signupData.user.name,
        );
        await preferences.putString(
          SharedPreference.profileImage,
          '', // Profile image URL will be available after upload
        );
        await preferences.putString(
          SharedPreference.userRole,
          signupData.user.role,
        );
        await preferences.putBool(SharedPreference.isLogIn, true);

        print('SignupController: Signup successful');
        print('SignupController: Token saved');
        print('SignupController: User ID: ${signupData.user.id}');
        print('SignupController: User Name: ${signupData.user.name}');

        // Show success toast
        _showToast(signupResponse.message.isNotEmpty 
            ? signupResponse.message 
            : 'Signup successful', 
            isError: false);

        // Update AuthController to reflect logged-in state
        if (Get.isRegistered<AuthController>()) {
          try {
            final authController = Get.find<AuthController>();
            authController.checkAuthStatus();
            print('SignupController: AuthController state updated');
          } catch (e) {
            print('SignupController: Error updating AuthController: $e');
          }
        }

        // Navigate to master screen (home)
        Get.offAllNamed(AppRoutes.master);
      } else {
        // User already exists or signup failed
        _showToast(signupResponse.message.isNotEmpty 
            ? signupResponse.message 
            : 'Signup failed. Please try again.', 
            isError: true);
      }
    } catch (e, stackTrace) {
      print('SignupController: Error during signup: $e');
      print('SignupController: Stack trace: $stackTrace');
      _showToast('Signup failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }

  void _showToast(String message, {required bool isError}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }
}

