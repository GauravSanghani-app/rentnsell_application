import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/profile_api_service.dart';
import '../models/response/profile_get_response_model.dart';
import '../utils/shared_pref.dart';
import '../config/routes/route_manager.dart';

class ProfileCompletionHelper {
  static final ProfileApiService _profileApiService = ProfileApiService();

  static bool isLoggedIn() {
    final jwtToken = preferences.getString(SharedPreference.jwtToken);
    return jwtToken != null && jwtToken.isNotEmpty;
  }

  static Future<bool> checkProfileCompletion() async {
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        return false;
      }

      final response = await _profileApiService.getProfile(jwtToken: jwtToken);

      if (response.success && response.data != null) {
        return _profileApiService.isProfileComplete(response.data);
      }

      return false;
    } catch (e) {
      print('ProfileCompletionHelper: Error checking profile: $e');
      return false;
    }
  }

  static Future<bool> requireLoginAndProfile({
    required String actionName,
    String? incompleteMessage,
  }) async {
    if (!isLoggedIn()) {
      Get.toNamed(AppRoutes.mobileLogin);
      return false;
    }

    final isComplete = await checkProfileCompletion();
    if (!isComplete) {
      _showCompleteProfileDialog(
        actionName: actionName,
        message:
            incompleteMessage ??
            'Please complete your profile to $actionName. This helps us provide a better experience for all users.',
      );
      return false;
    }

    return true;
  }

  static void _showCompleteProfileDialog({
    required String actionName,
    required String message,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Color.fromRGBO(51, 11, 54, 1),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Complete Your Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(51, 11, 54, 1),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.profileManage);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromRGBO(51, 11, 54, 1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Complete Profile'),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  static Future<ProfileGetResponseData?> getProfileData() async {
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        return null;
      }
      final response = await _profileApiService.getProfile(jwtToken: jwtToken);
      if (response.success && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('ProfileCompletionHelper: Error getting profile data: $e');
      return null;
    }
  }
}
