import 'dart:convert';
import '../location_model.dart';

LocationListResponseModel locationListResponseModelFromJson(String str) =>
    LocationListResponseModel.fromJson(json.decode(str));

String locationListResponseModelToJson(LocationListResponseModel data) =>
    json.encode(data.toJson());

class LocationListResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final List<LocationModel>? data;

  LocationListResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory LocationListResponseModel.fromJson(Map<String, dynamic> json) =>
      LocationListResponseModel(
        success: json["success"],
        statusCode: json["statusCode"],
        message: json["message"],
        data: json["data"] == null
            ? null
            : List<LocationModel>.from(
                json["data"].map((x) => LocationModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data == null
            ? null
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}


