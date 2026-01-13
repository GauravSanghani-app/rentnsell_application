import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../config/routes/route_manager.dart';
import '../../../services/login_api_service.dart';
import '../../../services/fcm_api_service.dart';
import '../../../services/fcm_service.dart';
import '../../../utils/shared_pref.dart';
import '../../auth/auth_controller.dart';

class MobileLoginController extends GetxController {
  final LoginApiService _loginApiService = LoginApiService();
  final FcmApiService _fcmApiService = FcmApiService();
  final TextEditingController mobileController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final mobile = mobileController.text.trim();

    _isLoading = true;
    update();

    try {
      final loginResponse = await _loginApiService.loginWithMobile(mobile);

      if (loginResponse.success && loginResponse.token != null) {
        final loginData = loginResponse.token!;
        await preferences.putString(SharedPreference.jwtToken, loginData.token);
        await preferences.putString(SharedPreference.userId, loginData.user.id);
        await preferences.putString(
          SharedPreference.userEmail,
          loginData.user.mobile,
        );
        await preferences.putString(
          SharedPreference.userFirstName,
          loginData.user.name,
        );
        await preferences.putString(
          SharedPreference.profileImage,
          loginData.user.profileImage,
        );
        await preferences.putString(
          SharedPreference.userRole,
          loginData.user.role,
        );
        await preferences.putBool(SharedPreference.isLogIn, true);

        print('MobileLoginController: Login successful');
        print('MobileLoginController: Token saved');
        print('MobileLoginController: User ID: ${loginData.user.id}');
        print('MobileLoginController: User Name: ${loginData.user.name}');

        // Save FCM token after successful login
        await _saveFcmToken(loginData.token);

        _showToast(
          loginResponse.message.isNotEmpty
              ? loginResponse.message
              : 'Login successful',
          isError: false,
        );

        if (Get.isRegistered<AuthController>()) {
          try {
            final authController = Get.find<AuthController>();
            authController.checkAuthStatus();
            print('MobileLoginController: AuthController state updated');
          } catch (e) {
            print('MobileLoginController: Error updating AuthController: $e');
          }
        }

        // Refresh notification unread count after login
        // The notification controller will refresh when the home screen loads

        Get.offAllNamed(AppRoutes.master);
      } else {
        _showToast(
          loginResponse.message.isNotEmpty
              ? loginResponse.message
              : 'Login failed. Please try again.',
          isError: true,
        );
      }
    } catch (e, stackTrace) {
      print('MobileLoginController: Error during login: $e');
      print('MobileLoginController: Stack trace: $stackTrace');
      _showToast('Login failed: ${e.toString()}', isError: true);
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> _saveFcmToken(String jwtToken) async {
    try {
      // Get FCM token from FCMService
      String? fcmToken;
      if (Get.isRegistered<FCMService>()) {
        final fcmService = Get.find<FCMService>();
        fcmToken = await fcmService.getToken();
      } else {
        // If FCMService is not registered, try to get token from shared preferences
        fcmToken = preferences.getString(SharedPreference.fcmToken);
      }

      if (fcmToken != null && fcmToken.isNotEmpty) {
        // Determine platform
        final platform = Platform.isAndroid ? 'android' : 'ios';
        
        // Save FCM token to API
        final response = await _fcmApiService.saveFcmToken(
          jwtToken: jwtToken,
          token: fcmToken,
          platform: platform,
        );

        if (response.success) {
          print('MobileLoginController: FCM token saved successfully');
          // Save FCM token to local storage
          await preferences.putString(SharedPreference.fcmToken, fcmToken);
        } else {
          print('MobileLoginController: Failed to save FCM token: ${response.message}');
        }
      } else {
        print('MobileLoginController: FCM token not available');
      }
    } catch (e) {
      print('MobileLoginController: Error saving FCM token: $e');
      // Don't show error to user - FCM token save failure shouldn't block login
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
