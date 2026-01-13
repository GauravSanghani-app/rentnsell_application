class GoogleGeocodingResponseModel {
  final List<GoogleGeocodingResult> results;
  final String status;

  GoogleGeocodingResponseModel({
    required this.results,
    required this.status,
  });

  factory GoogleGeocodingResponseModel.fromJson(Map<String, dynamic> json) {
    return GoogleGeocodingResponseModel(
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => GoogleGeocodingResult.fromJson(
                  item as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'results': results.map((r) => r.toJson()).toList(),
        'status': status,
      };
}

class GoogleGeocodingResult {
  final String? formattedAddress;
  final List<GoogleAddressComponent> addressComponents;

  GoogleGeocodingResult({
    this.formattedAddress,
    required this.addressComponents,
  });

  factory GoogleGeocodingResult.fromJson(Map<String, dynamic> json) {
    return GoogleGeocodingResult(
      formattedAddress: json['formatted_address'] as String?,
      addressComponents: (json['address_components'] as List<dynamic>?)
              ?.map((item) => GoogleAddressComponent.fromJson(
                  item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'formatted_address': formattedAddress,
        'address_components':
            addressComponents.map((a) => a.toJson()).toList(),
      };

  // Helper methods to extract city, state, country
  String? getCity() {
    for (var component in addressComponents) {
      if (component.types.contains('locality') ||
          component.types.contains('administrative_area_level_2')) {
        return component.longName;
      }
    }
    return null;
  }

  String? getState() {
    for (var component in addressComponents) {
      if (component.types.contains('administrative_area_level_1')) {
        return component.longName;
      }
    }
    return null;
  }

  String? getCountry() {
    for (var component in addressComponents) {
      if (component.types.contains('country')) {
        return component.longName;
      }
    }
    return null;
  }
}

class GoogleAddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  GoogleAddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory GoogleAddressComponent.fromJson(Map<String, dynamic> json) {
    return GoogleAddressComponent(
      longName: json['long_name'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      types: (json['types'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'long_name': longName,
        'short_name': shortName,
        'types': types,
      };
}
