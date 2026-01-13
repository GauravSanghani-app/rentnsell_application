class UserProfileModel {
  final String? googleId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String phone;
  final int age;
  final String gender;
  final String address;
  final List<String> interestedCategoryIds;
  final List<String> interestedActions;

  UserProfileModel({
    this.googleId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
    required this.interestedCategoryIds,
    required this.interestedActions,
  });

  Map<String, dynamic> toJson() {
    return {
      'googleId': googleId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phone': phone,
      'age': age,
      'gender': gender,
      'address': address,
      'interestedCategoryIds': interestedCategoryIds,
      'interestedActions': interestedActions,
    };
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      googleId: json['googleId'],
      email: json['email'] ?? '',
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      phone: json['phone'] ?? '',
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      interestedCategoryIds: List<String>.from(
        json['interestedCategoryIds'] ?? [],
      ),
      interestedActions: List<String>.from(json['interestedActions'] ?? []),
    );
  }

  bool get isComplete {
    return email.isNotEmpty &&
        phone.isNotEmpty &&
        age > 0 &&
        gender.isNotEmpty &&
        address.isNotEmpty &&
        interestedCategoryIds.isNotEmpty &&
        interestedActions.isNotEmpty;
  }
}
