class AttributeTemplateModel {
  final String id;
  final String categoryId;
  final String subCategoryId;
  final List<AttributeField> fields;

  AttributeTemplateModel({
    required this.id,
    required this.categoryId,
    required this.subCategoryId,
    required this.fields,
  });

  factory AttributeTemplateModel.fromJson(Map<String, dynamic> json) {
    return AttributeTemplateModel(
      id: json['id'] ?? json['_id'] ?? '',
      categoryId: json['categoryId'] ?? json['category_id'] ?? '',
      subCategoryId:
          json['subCategoryId'] ??
          json['subCategory_id'] ??
          json['subcategoryId'] ??
          '',
      fields:
          (json['fields'] as List<dynamic>?)
              ?.map(
                (field) =>
                    AttributeField.fromJson(field as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }
}

class AttributeField {
  final String id;
  final String fieldName;
  final String fieldType;
  final bool required;

  AttributeField({
    required this.id,
    required this.fieldName,
    required this.fieldType,
    required this.required,
  });

  factory AttributeField.fromJson(Map<String, dynamic> json) {
    return AttributeField(
      id: json['_id'] ?? '',
      fieldName: json['fieldName'] ?? '',
      fieldType: json['fieldType'] ?? 'text',
      required: json['required'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fieldName': fieldName,
      'fieldType': fieldType,
      'required': required,
    };
  }
}
