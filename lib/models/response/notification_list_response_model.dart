import 'dart:convert';
import '../notification_model.dart';

NotificationListResponseModel notificationListResponseModelFromJson(String str) =>
    NotificationListResponseModel.fromJson(json.decode(str));

String notificationListResponseModelToJson(NotificationListResponseModel data) =>
    json.encode(data.toJson());

class NotificationListResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final NotificationListData? data;

  NotificationListResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory NotificationListResponseModel.fromJson(Map<String, dynamic> json) =>
      NotificationListResponseModel(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : NotificationListData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class NotificationListData {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  NotificationListData({
    required this.notifications,
    required this.unreadCount,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) =>
      NotificationListData(
        notifications: List<NotificationModel>.from(
            json["notifications"].map((x) => NotificationModel.fromJson(x))),
        unreadCount: json["unreadCount"],
        totalCount: json["totalCount"],
        currentPage: json["currentPage"],
        totalPages: json["totalPages"],
        hasNextPage: json["hasNextPage"],
      );

  Map<String, dynamic> toJson() => {
        "notifications":
            List<dynamic>.from(notifications.map((x) => x.toJson())),
        "unreadCount": unreadCount,
        "totalCount": totalCount,
        "currentPage": currentPage,
        "totalPages": totalPages,
        "hasNextPage": hasNextPage,
      };
}


