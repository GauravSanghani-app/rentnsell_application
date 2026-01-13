class AuthLogoutResponseModel {
  final bool success;
  final int statusCode;
  final String message;

  AuthLogoutResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory AuthLogoutResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthLogoutResponseModel(
      success: json['success'] ?? false,
      statusCode: json['statusCode'] ?? 200,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'message': message,
    };
  }
}


