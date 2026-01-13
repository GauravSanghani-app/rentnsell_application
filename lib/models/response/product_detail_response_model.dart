import 'dart:convert';
import '../product_model.dart';

ProductDetailResponseModel productDetailResponseModelFromJson(String str) =>
    ProductDetailResponseModel.fromJson(json.decode(str));

String productDetailResponseModelToJson(ProductDetailResponseModel data) =>
    json.encode(data.toJson());

class ProductDetailResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ProductModel? data;

  ProductDetailResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProductDetailResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductDetailResponseModel(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 0,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? null
            : ProductModel.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}


