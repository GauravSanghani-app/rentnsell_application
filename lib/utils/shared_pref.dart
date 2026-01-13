import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
final SharedPreference preferences = SharedPreference();

class SharedPreference {
  SharedPreferences? _preferences;

  static const String isLogIn = "isLogIn";
  static const String deviceType = "deviceType";
  static const String appStoreVersion = "App-Store-Version";
  static const String appDeviceName = "App-Device-Name";
  static const String appDeviceId = "App-Device-Id";
  static const String macAddress = "Mac-Address";
  static const String appOsVersion = "App-Os-Version";
  static const String appStoreBuildNumber = "App-Store-Build-Number";
  static const String isOnboarding = "isOnboarding";
  static const String userToken = "access_token";
  static const String userRole = "role";
  static const String userId = "id";
  static const String userFirstName = "first_name";
  static const String profileImage = "profile_image";
  static const String userEmail = "email";
  static const String className = "class_name";
  static const String degree = "degreee";
  static const String refreshToken = "refresh_token";
  static const String call = "phone_number";
  static const String googleId = "google_id";
  static const String profileCompleted = "profile_completed";
  static const String jwtToken = "jwt_token";
  static const String fcmToken = "fcm_token";
  static const String notificationPermissionAsked = "notification_permission_asked";

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  bool getBool(String key, {bool defValue = false}) {
    return _preferences == null
        ? defValue
        : _preferences!.getBool(key) ?? defValue;
  }

  Future<void> putAppDeviceInfo() async {
    bool isiOS = Platform.isIOS;
    putString(deviceType, isiOS ? "iOS" : "Android");
  }


  void clearUserItem() async {
    _preferences?.clear();
    _preferences = null;
    await init();
    await putAppDeviceInfo();
    putBool(isOnboarding, true);
  }

  Future<bool?> putString(String key, String value) async {
    return _preferences!.setString(key, value);
  }

  Future<bool?> putList(String key, List<String> value) async {
    return _preferences?.setStringList(key, value);
  }

  List<String>? getList(String key, {List<String> defValue = const []}) {
    return _preferences == null
        ? defValue
        : _preferences?.getStringList(key) ?? defValue;
  }

  String? getString(String key, {String defValue = ""}) {
    return _preferences == null
        ? defValue
        : _preferences?.getString(key) ?? defValue;
  }

  Future<bool?> putInt(String key, int value) async {
    return _preferences?.setInt(key, value);
  }

  int? getInt(String key, {int defValue = 0}) {
    return _preferences == null
        ? defValue
        : _preferences?.getInt(key) ?? defValue;
  }

  Future<bool?> putDouble(String key, double value) async {
    return _preferences?.setDouble(key, value);
  }

  double getDouble(String key, {double defValue = 0.0}) {
    return _preferences == null
        ? defValue
        : _preferences?.getDouble(key) ?? defValue;
  }

  Future<bool?> putBool(String key, bool value) async {
    return _preferences?.setBool(key, value);
  }
}