import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../services/profile_api_service.dart';
import '../../utils/shared_pref.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ProfileApiService _profileApiService = ProfileApiService();

  bool _isLoggedIn = false;
  bool _isProfileComplete = false;
  bool _isLoading = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isProfileComplete => _isProfileComplete;
  bool get isLoading => _isLoading;

  @override
  void onInit() {
    super.onInit();
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoggedIn = _authService.isLoggedIn();
    if (_isLoggedIn) {
      await _checkProfileCompletionFromAPI();
    } else {
      _isProfileComplete = false;
    }
    
    update();
  }

  Future<void> _checkProfileCompletionFromAPI() async {
    try {
      final jwtToken = preferences.getString(SharedPreference.jwtToken);
      if (jwtToken == null || jwtToken.isEmpty) {
        _isProfileComplete = false;
        return;
      }

      final response = await _profileApiService.getProfile(jwtToken: jwtToken);
      if (response.success && response.data != null) {
        _isProfileComplete = _profileApiService.isProfileComplete(response.data);
      } else {
        _isProfileComplete = false;
      }
    } catch (e) {
      print('AuthController: Error checking profile completion: $e');
      // Fallback to local check
      _isProfileComplete = _profileService.isProfileComplete();
    }
  }

  // Future<Map<String, dynamic>?> signInWithGoogle() async {
  //   _isLoading = true;
  //   update();
  //
  //   try {
  //     final userData = await _authService.signInWithGoogle();
  //     if (userData != null && userData.isNotEmpty) {
  //       _isLoggedIn = true;
  //       _isProfileComplete = _profileService.isProfileComplete();
  //       update();
  //       return userData;
  //     }
  //     return null;
  //   } catch (e) {
  //     print('AuthController signInWithGoogle error: $e');
  //     return null;
  //   } finally {
  //     _isLoading = false;
  //     update();
  //   }
  // }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _profileService.clearProfile();
      _isLoggedIn = false;
      _isProfileComplete = false;
      update();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> refreshProfileStatus() async {
    if (_isLoggedIn) {
      await _checkProfileCompletionFromAPI();
    } else {
      _isProfileComplete = false;
    }
    update();
  }
}

