class SubcategoryModel {
  final String id;
  final String name;
  final String categoryId;
  final String? icon;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    this.icon,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    final subcategoryId = json['id'] ?? json['_id'] ?? '';
    final catId =
        json['categoryId'] ?? json['category_id'] ?? json['category'] ?? '';

    return SubcategoryModel(
      id: subcategoryId,
      name: json['name'] ?? json['subcategoryName'] ?? '',
      categoryId: catId,
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'categoryId': categoryId, 'icon': icon};
  }
}
