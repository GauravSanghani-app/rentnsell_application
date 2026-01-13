class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? icon;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final categoryId = json['id'] ?? json['_id'] ?? '';
    final iconValue =
        json['icon'] ?? json['imageUrl'] ?? json['image'] ?? json['image_url'];
    String? imageUrl;
    if (iconValue != null && iconValue.isNotEmpty) {
      if (iconValue.startsWith('http://') || iconValue.startsWith('https://')) {
        imageUrl = iconValue;
      } else {
        imageUrl = 'https://api-oms.softclues.in/images/$iconValue';
      }
    }

    return CategoryModel(
      id: categoryId,
      name: json['name'] ?? json['categoryName'] ?? '',
      icon: iconValue,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon ?? imageUrl,
      'imageUrl': imageUrl ?? icon,
    };
  }
}
