import 'google_places_prediction_model.dart';

class GooglePlacesAutocompleteResponseModel {
  final List<GooglePlacesPredictionModel> predictions;
  final String status;

  GooglePlacesAutocompleteResponseModel({
    required this.predictions,
    required this.status,
  });

  factory GooglePlacesAutocompleteResponseModel.fromJson(
      Map<String, dynamic> json) {
    return GooglePlacesAutocompleteResponseModel(
      predictions: (json['predictions'] as List<dynamic>?)
              ?.map((item) =>
                  GooglePlacesPredictionModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'predictions': predictions.map((p) => p.toJson()).toList(),
        'status': status,
      };
}
