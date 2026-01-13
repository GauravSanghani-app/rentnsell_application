import 'dart:convert';

OfferingCreateResponseModel offeringCreateResponseModelFromJson(String str) =>
    OfferingCreateResponseModel.fromJson(json.decode(str));

String offeringCreateResponseModelToJson(OfferingCreateResponseModel data) =>
    json.encode(data.toJson());

class OfferingCreateResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final OfferingCreateResponseData? data;

  OfferingCreateResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory OfferingCreateResponseModel.fromJson(Map<String, dynamic> json) =>
      OfferingCreateResponseModel(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 0,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? null
            : OfferingCreateResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class OfferingCreateResponseData {
  final String offeringId;
  final String type;
  final String title;
  final List<String> imageUrls; // Server URLs for uploaded images
  final DateTime createdAt;

  OfferingCreateResponseData({
    required this.offeringId,
    required this.type,
    required this.title,
    required this.imageUrls,
    required this.createdAt,
  });

  factory OfferingCreateResponseData.fromJson(Map<String, dynamic> json) =>
      OfferingCreateResponseData(
        offeringId: json["offeringId"] ?? '',
        type: json["type"] ?? '',
        title: json["title"] ?? '',
        imageUrls: List<String>.from(json["imageUrls"] ?? []),
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "offeringId": offeringId,
        "type": type,
        "title": title,
        "imageUrls": imageUrls,
        "createdAt": createdAt.toIso8601String(),
      };
}

