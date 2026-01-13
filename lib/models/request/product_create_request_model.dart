import 'dart:convert';
import 'dart:io';

class ProductCreateRequestModel {
  final String productType;
  final Map<String, int> price;
  final Map<String, dynamic> location;
  final String title;
  final List<File> images;
  final String categoryId;
  final String subCategoryId;
  final String description;
  final Map<String, dynamic> attributes;

  ProductCreateRequestModel({
    required this.productType,
    required this.price,
    required this.location,
    required this.title,
    required this.images,
    required this.categoryId,
    required this.subCategoryId,
    required this.description,
    required this.attributes,
  });

  Map<String, String> toFormFields() {
    return {
      'productType': productType,
      'price': _mapToJsonString(price),
      'location': _mapToJsonString(location),
      'title': title,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'description': description,
      'attributes': _mapToJsonString(attributes),
    };
  }

  String _mapToJsonString(Map<String, dynamic> map) {
    return json.encode(map);
  }
}
