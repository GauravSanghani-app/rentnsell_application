class GooglePlacesDetailsResponseModel {
  final GooglePlacesResult? result;
  final String status;

  GooglePlacesDetailsResponseModel({
    this.result,
    required this.status,
  });

  factory GooglePlacesDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return GooglePlacesDetailsResponseModel(
      result: json['result'] != null
          ? GooglePlacesResult.fromJson(json['result'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'result': result?.toJson(),
        'status': status,
      };
}

class GooglePlacesResult {
  final GooglePlacesGeometry? geometry;
  final String? formattedAddress;

  GooglePlacesResult({
    this.geometry,
    this.formattedAddress,
  });

  factory GooglePlacesResult.fromJson(Map<String, dynamic> json) {
    return GooglePlacesResult(
      geometry: json['geometry'] != null
          ? GooglePlacesGeometry.fromJson(
              json['geometry'] as Map<String, dynamic>)
          : null,
      formattedAddress: json['formatted_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'geometry': geometry?.toJson(),
        'formatted_address': formattedAddress,
      };
}

class GooglePlacesGeometry {
  final GooglePlacesLocation? location;

  GooglePlacesGeometry({
    this.location,
  });

  factory GooglePlacesGeometry.fromJson(Map<String, dynamic> json) {
    return GooglePlacesGeometry(
      location: json['location'] != null
          ? GooglePlacesLocation.fromJson(
              json['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'location': location?.toJson(),
      };
}

class GooglePlacesLocation {
  final double lat;
  final double lng;

  GooglePlacesLocation({
    required this.lat,
    required this.lng,
  });

  factory GooglePlacesLocation.fromJson(Map<String, dynamic> json) {
    return GooglePlacesLocation(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}
