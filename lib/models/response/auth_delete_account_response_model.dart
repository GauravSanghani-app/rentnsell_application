class AuthDeleteAccountResponseModel {
  final bool success;
  final int statusCode;
  final String message;

  AuthDeleteAccountResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory AuthDeleteAccountResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthDeleteAccountResponseModel(
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


