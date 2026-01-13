import 'dart:convert';

ProfileGetResponseModel profileGetResponseModelFromJson(String str) =>
    ProfileGetResponseModel.fromJson(json.decode(str));

String profileGetResponseModelToJson(ProfileGetResponseModel data) =>
    json.encode(data.toJson());

class ProfileGetResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ProfileGetResponseData? data;

  ProfileGetResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProfileGetResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileGetResponseModel(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 0,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? null
            : ProfileGetResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class ProfileGetResponseData {
  final String id; // _id from API
  final String mobile; // mobile from API (read-only, comes from login)
  final String? name; // name from API (required for profile completion)
  final String? email; // email from API (required for profile completion)
  final String? profileImage; // profileImage from API (image URL or file path)
  final String? gender; // gender from API (male, female, other)
  final String? address; // address from API (required for profile completion)
  final int? age; // age from API
  final String? role; // role from API
  final String? createdAt; // createdAt from API
  final bool isProfileComplete; // Calculated field - true if all required fields are present

  ProfileGetResponseData({
    required this.id,
    required this.mobile,
    this.name,
    this.email,
    this.profileImage,
    this.gender,
    this.address,
    this.age,
    this.role,
    this.createdAt,
    this.isProfileComplete = false,
  });

  factory ProfileGetResponseData.fromJson(Map<String, dynamic> json) {
    // Calculate isProfileComplete based on required fields
    final hasName = json["name"] != null && json["name"].toString().isNotEmpty;
    final hasEmail = json["email"] != null && json["email"].toString().isNotEmpty;
    final hasAddress = json["address"] != null && json["address"].toString().isNotEmpty;
    final hasGender = json["gender"] != null && json["gender"].toString().isNotEmpty;
    
    // Profile is complete if all required fields are present
    final isComplete = hasName && hasEmail && hasAddress && hasGender;

    return ProfileGetResponseData(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? '',
      mobile: json["mobile"]?.toString() ?? '',
      name: json["name"]?.toString(),
      email: json["email"]?.toString(),
      profileImage: json["profileImage"]?.toString(),
      gender: json["gender"]?.toString(),
      address: json["address"]?.toString(),
      age: json["age"] != null ? (json["age"] is int ? json["age"] as int : int.tryParse(json["age"].toString())) : null,
      role: json["role"]?.toString(),
      createdAt: json["createdAt"]?.toString(),
      isProfileComplete: json["isProfileComplete"] as bool? ?? isComplete,
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "mobile": mobile,
        "name": name,
        "email": email,
        "profileImage": profileImage,
        "gender": gender,
        "address": address,
        "age": age,
        "role": role,
        "createdAt": createdAt,
        "isProfileComplete": isProfileComplete,
      };

  // Helper getters for backward compatibility
  String get phone => mobile;
  String? get displayName => name;
  String? get profileImageUrl => profileImage;
  String? get photoUrl => profileImage; // Alias for profileImage
  List<String> get interestedCategoryIds => []; // Not in API response (can be added if needed)
  List<String> get interestedActions => []; // Not in API response (can be added if needed)
  bool get showAddressToAll => false; // Not in API response (can be added if needed)
}

