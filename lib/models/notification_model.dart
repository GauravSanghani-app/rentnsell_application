import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? imageUrl;
  final String? actionUrl;
  final String? actionType;
  final String? actionId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    this.type = 'general',
    required this.title,
    required this.message,
    this.imageUrl,
    this.actionUrl,
    this.actionType,
    this.actionId,
    this.isRead = false,
    this.readAt,
    required this.createdAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final id = json["_id"]?.toString() ?? json["id"]?.toString() ?? '';
    final title = json["title"]?.toString() ?? '';
    final body = json["body"]?.toString() ?? json["message"]?.toString() ?? '';
    final isRead = json["isRead"] ?? false;

    DateTime? readAt;
    if (json["readAt"] != null) {
      try {
        readAt = DateTime.parse(json["readAt"]);
      } catch (e) {
        readAt = null;
      }
    }

    DateTime createdAt;
    try {
      createdAt = DateTime.parse(json["createdAt"]);
    } catch (e) {
      createdAt = DateTime.now();
    }

    return NotificationModel(
      id: id,
      type: json["type"]?.toString() ?? 'general',
      title: title,
      message: body,
      imageUrl: json["imageUrl"]?.toString(),
      actionUrl: json["actionUrl"]?.toString(),
      actionType: json["actionType"]?.toString(),
      actionId: json["actionId"]?.toString(),
      isRead: isRead,
      readAt: readAt,
      createdAt: createdAt,
      metadata: json["metadata"],
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "id": id,
    "type": type,
    "title": title,
    "body": message,
    "message": message,
    "imageUrl": imageUrl,
    "actionUrl": actionUrl,
    "actionType": actionType,
    "actionId": actionId,
    "isRead": isRead,
    "readAt": readAt?.toIso8601String(),
    "createdAt": createdAt.toIso8601String(),
    "metadata": metadata,
  };

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? message,
    String? imageUrl,
    String? actionUrl,
    String? actionType,
    String? actionId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actionType: actionType ?? this.actionType,
      actionId: actionId ?? this.actionId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
