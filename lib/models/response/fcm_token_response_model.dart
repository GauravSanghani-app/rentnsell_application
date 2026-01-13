class FcmTokenResponseModel {
  final bool success;
  final String message;

  FcmTokenResponseModel({
    required this.success,
    required this.message,
  });

  factory FcmTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponseModel(
      success: true,
      message: json['msg'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'msg': message,
      };
}

