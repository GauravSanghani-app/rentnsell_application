class UnreadCountResponseModel {
  final bool success;
  final int unreadCount;

  UnreadCountResponseModel({
    required this.success,
    required this.unreadCount,
  });

  factory UnreadCountResponseModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponseModel(
      success: true,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'unreadCount': unreadCount,
      };
}

