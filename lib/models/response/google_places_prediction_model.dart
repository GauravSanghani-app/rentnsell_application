class GooglePlacesPredictionModel {
  final String description;
  final String placeId;
  final GooglePlacesStructuredFormatting? structuredFormatting;

  GooglePlacesPredictionModel({
    required this.description,
    required this.placeId,
    this.structuredFormatting,
  });

  factory GooglePlacesPredictionModel.fromJson(Map<String, dynamic> json) {
    return GooglePlacesPredictionModel(
      description: json['description'] as String? ?? '',
      placeId: json['place_id'] as String? ?? '',
      structuredFormatting: json['structured_formatting'] != null
          ? GooglePlacesStructuredFormatting.fromJson(
              json['structured_formatting'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'place_id': placeId,
        'structured_formatting': structuredFormatting?.toJson(),
      };
}

class GooglePlacesStructuredFormatting {
  final String mainText;
  final String secondaryText;

  GooglePlacesStructuredFormatting({
    required this.mainText,
    required this.secondaryText,
  });

  factory GooglePlacesStructuredFormatting.fromJson(
      Map<String, dynamic> json) {
    return GooglePlacesStructuredFormatting(
      mainText: json['main_text'] as String? ?? '',
      secondaryText: json['secondary_text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'main_text': mainText,
        'secondary_text': secondaryText,
      };
}
