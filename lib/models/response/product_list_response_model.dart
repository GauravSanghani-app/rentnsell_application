import 'dart:convert';
import '../product_model.dart';

ProductListResponseModel productListResponseModelFromJson(String str) =>
    ProductListResponseModel.fromJson(json.decode(str));

String productListResponseModelToJson(ProductListResponseModel data) =>
    json.encode(data.toJson());

class ProductListResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final ProductListResponseData? data;

  ProductListResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductListResponseModel(
        success: json["success"] ?? false,
        statusCode: json["statusCode"] ?? 0,
        message: json["message"] ?? '',
        data: json["data"] == null
            ? null
            : ProductListResponseData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class ProductListResponseData {
  final List<ProductModel> products;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  ProductListResponseData({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory ProductListResponseData.fromJson(Map<String, dynamic> json) =>
      ProductListResponseData(
        products: (json["products"] as List<dynamic>?)
                ?.map((x) => ProductModel.fromJson(x))
                .toList() ??
            [],
        currentPage: json["currentPage"] ?? 1,
        totalPages: json["totalPages"] ?? 1,
        totalItems: json["totalItems"] ?? 0,
        perPage: json["perPage"] ?? 10,
        hasNextPage: json["hasNextPage"] ?? false,
        hasPreviousPage: json["hasPreviousPage"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "products": products.map((x) => x.toJson()).toList(),
        "currentPage": currentPage,
        "totalPages": totalPages,
        "totalItems": totalItems,
        "perPage": perPage,
        "hasNextPage": hasNextPage,
        "hasPreviousPage": hasPreviousPage,
      };
}


