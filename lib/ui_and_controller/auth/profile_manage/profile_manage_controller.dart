import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/route_manager.dart';
import '../../../utils/extension.dart';
import '../auth_controller.dart';
import '../profile_controller.dart';

class ProfileManageController extends GetxController {
  final ProfileController _profileController = Get.put(ProfileController());
  final formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController ageController;
  late TextEditingController addressController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    ageController = TextEditingController();
    addressController = TextEditingController();

    final arguments = Get.arguments;
    print('ProfileManageController: Received arguments: $arguments');
    if (arguments != null && arguments is Map<String, dynamic>) {
      print('ProfileManageController: Prefilling from Google data');
      _profileController.prefillFromGoogle(arguments);
      emailController.text = arguments['email'] ?? '';
      _profileController.email = emailController.text;
      _profileController.update();
    } else {
      _profileController.loadProfile();
      if (_profileController.profile != null) {
        final profile = _profileController.profile!;
        emailController.text = profile.email;
        phoneController.text = profile.phone.replaceFirst(
          RegExp(r'^\+\d+'),
          '',
        );
        ageController.text = profile.age.toString();
        addressController.text = profile.address;
        _profileController.gender = profile.gender;
        _profileController.selectedCategoryIds = List.from(
          profile.interestedCategoryIds,
        );
        _profileController.selectedActions = List.from(
          profile.interestedActions,
        );
      }
    }

    _profileController.email = emailController.text;
    _profileController.phone = phoneController.text;
    _profileController.age = ageController.text;
    _profileController.address = addressController.text;
    _profileController.update();
  }

  @override
  void onClose() {
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    addressController.dispose();
    super.onClose();
  }

  void onEmailChanged(String value) {
    _profileController.email = value;
    _profileController.update();
  }

  void onPhoneChanged(String value) {
    _profileController.phone = value;
    _profileController.update();
  }

  void onAgeChanged(String value) {
    _profileController.age = value;
    _profileController.update();
  }

  void onAddressChanged(String value) {
    _profileController.address = value;
    _profileController.update();
  }

  void onGenderSelected(String gender) {
    _profileController.setGender(gender);
  }

  void onCategoryToggled(String categoryId) {
    _profileController.toggleCategory(categoryId);
  }

  void onActionToggled(String action) {
    _profileController.toggleAction(action);
  }

  Future<void> pickProfileImage() async {
    final imagePath = await _profileController.pickImage();
    if (imagePath != null) {
      final context = Get.context;
      if (context != null) {
        context.showSuccessToast(message: 'Image selected successfully');
      }
    } else {
      final context = Get.context;
      if (context != null) {
        context.showErrorToast(message: 'Failed to select image');
      }
    }
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _profileController.email = emailController.text;
    _profileController.phone = phoneController.text;
    _profileController.age = ageController.text;
    _profileController.address = addressController.text;

    if (!_profileController.isFormValid) {
      _showError('Please fill all required fields correctly');
      return;
    }

    final saved = await _profileController.saveProfile();
    if (saved) {
      _showSuccess('Profile saved successfully');
      try {
        Get.find<AuthController>().refreshProfileStatus();
      } catch (e) {}
      Get.offAllNamed(AppRoutes.master);
    } else {
      _showError('Failed to save profile');
    }
  }

  void _showError(String message) {
    final context = Get.context;
    if (context != null) {
      context.showErrorToast(message: message);
    } else {
      // If context is not available, just log the message
      debugPrint('Error (no context): $message');
    }
  }

  void _showSuccess(String message) {
    final context = Get.context;
    if (context != null) {
      context.showSuccessToast(message: message);
    } else {
      // If context is not available, just log the message
      debugPrint('Success (no context): $message');
    }
  }
}
