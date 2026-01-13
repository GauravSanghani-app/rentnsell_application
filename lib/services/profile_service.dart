import 'dart:convert';
import '../models/user_profile_model.dart';
import '../utils/shared_pref.dart';

class ProfileService {
  static const String _profileKey = 'user_profile';

  Future<bool> saveProfile(UserProfileModel profile) async {
    try {
      final jsonString = jsonEncode(profile.toJson());
      await preferences.putString(_profileKey, jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  UserProfileModel? getProfile() {
    try {
      final jsonString = preferences.getString(_profileKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        return UserProfileModel.fromJson(json);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  bool isProfileComplete() {
    final profile = getProfile();
    return profile != null && profile.isComplete;
  }

  Future<void> clearProfile() async {
    await preferences.putString(_profileKey, '');
  }
}

