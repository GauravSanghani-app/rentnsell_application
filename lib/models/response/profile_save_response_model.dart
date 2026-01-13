class ProfileSaveResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ProfileSaveResponseData? data;

  ProfileSaveResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProfileSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileSaveResponseModel(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProfileSaveResponseData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ProfileSaveResponseData {
  final String userId;
  final String email;
  final bool profileCompleted;
  final String jwtToken;
  final String refreshToken;
  final int expiresIn;

  ProfileSaveResponseData({
    required this.userId,
    required this.email,
    required this.profileCompleted,
    required this.jwtToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory ProfileSaveResponseData.fromJson(Map<String, dynamic> json) {
    return ProfileSaveResponseData(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      profileCompleted: json['profileCompleted'] ?? false,
      jwtToken: json['jwtToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'profileCompleted': profileCompleted,
      'jwtToken': jwtToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}

