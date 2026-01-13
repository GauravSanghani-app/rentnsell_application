import 'dart:convert';
import 'dart:io';

class ProductUpdateRequestModel {
  final String productType;
  final Map<String, int> price;
  final Map<String, dynamic> location;
  final String title;
  final List<File> newImages;
  final String categoryId;
  final String subCategoryId;
  final String description;
  final Map<String, dynamic> attributes;

  ProductUpdateRequestModel({
    required this.productType,
    required this.price,
    required this.location,
    required this.title,
    required this.newImages,
    required this.categoryId,
    required this.subCategoryId,
    required this.description,
    required this.attributes,
  });

  Map<String, String> toFormFields() {
    return {
      'productType': productType,
      'price': json.encode(price),
      'location': json.encode(location),
      'title': title,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'description': description,
      'attributes': json.encode(attributes),
    };
  }
}
