class ProfileSaveRequestModel {
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String address;
  final List<String> interestedCategoryIds;
  final List<String> interestedActions;
  final String fcmToken;
  final String? googleId;
  final String? displayName;
  final String? photoUrl;
  final String?
  profileImageBase64;
  final String? profileImageName;
  final String?
  profileImageType;

  ProfileSaveRequestModel({
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
    required this.interestedCategoryIds,
    required this.interestedActions,
    required this.fcmToken,
    this.googleId,
    this.displayName,
    this.photoUrl,
    this.profileImageBase64,
    this.profileImageName,
    this.profileImageType,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'address': address,
      'interestedCategoryIds': interestedCategoryIds,
      'interestedActions': interestedActions,
      'fcmToken': fcmToken,
      'googleId': googleId,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };

    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      json['profileImageBase64'] = profileImageBase64;
      json['profileImageName'] = profileImageName ?? 'profile_image.jpg';
      json['profileImageType'] = profileImageType ?? 'image/jpeg';
    }

    return json;
  }

  factory ProfileSaveRequestModel.fromJson(Map<String, dynamic> json) {
    return ProfileSaveRequestModel(
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      interestedCategoryIds: List<String>.from(
        json['interestedCategoryIds'] ?? [],
      ),
      interestedActions: List<String>.from(json['interestedActions'] ?? []),
      fcmToken: json['fcmToken'] ?? '',
      googleId: json['googleId'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      profileImageBase64: json['profileImageBase64'],
      profileImageName: json['profileImageName'],
      profileImageType: json['profileImageType'],
    );
  }

  factory ProfileSaveRequestModel.fromUserProfile(
    dynamic profile,
    String fcmToken, {
    String? profileImageBase64,
    String? profileImageName,
    String? profileImageType,
  }) {
    return ProfileSaveRequestModel(
      email: profile.email,
      phone: profile.phone,
      age: profile.age,
      gender: profile.gender,
      address: profile.address,
      interestedCategoryIds: profile.interestedCategoryIds,
      interestedActions: profile.interestedActions,
      fcmToken: fcmToken,
      googleId: profile.googleId,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl,
      profileImageBase64: profileImageBase64,
      profileImageName: profileImageName,
      profileImageType: profileImageType,
    );
  }
}
