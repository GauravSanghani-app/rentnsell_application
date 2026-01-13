import 'dart:convert';

ProfileUpdateResponseModel profileUpdateResponseModelFromJson(String str) =>
    ProfileUpdateResponseModel.fromJson(json.decode(str));

String profileUpdateResponseModelToJson(ProfileUpdateResponseModel data) =>
    json.encode(data.toJson());

class ProfileUpdateResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ProfileUpdateResponseData? data;

  ProfileUpdateResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProfileUpdateResponseModel.fromJson(Map<String, dynamic> json) =>
      ProfileUpdateResponseModel(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 0,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? null
            : ProfileUpdateResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class ProfileUpdateResponseData {
  final String? profileImageUrl; // Updated profile image URL if image was uploaded
  final String? phone; // Updated phone if changed
  final bool? showAddressToAll; // Updated address visibility toggle
  final List<String>? interestedCategoryIds; // Updated categories
  final List<String>? interestedActions; // Updated interests

  ProfileUpdateResponseData({
    this.profileImageUrl,
    this.phone,
    this.showAddressToAll,
    this.interestedCategoryIds,
    this.interestedActions,
  });

  factory ProfileUpdateResponseData.fromJson(Map<String, dynamic> json) =>
      ProfileUpdateResponseData(
        profileImageUrl: json["profileImageUrl"],
        phone: json["phone"],
        showAddressToAll: json["showAddressToAll"],
        interestedCategoryIds: json["interestedCategoryIds"] != null
            ? List<String>.from(json["interestedCategoryIds"])
            : null,
        interestedActions: json["interestedActions"] != null
            ? List<String>.from(json["interestedActions"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "profileImageUrl": profileImageUrl,
        "phone": phone,
        "showAddressToAll": showAddressToAll,
        "interestedCategoryIds": interestedCategoryIds,
        "interestedActions": interestedActions,
      };
}

