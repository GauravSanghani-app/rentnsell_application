/// Nominatim OpenStreetMap Reverse Geocoding Response Model
/// 
/// This model represents the response from the Nominatim reverse geocoding API.
/// API Endpoint: https://nominatim.openstreetmap.org/reverse
class NominatimReverseGeocodeResult {
  final int placeId;
  final String? licence;
  final String? osmType;
  final int? osmId;
  final String lat;
  final String lon;
  final String? classType;
  final String? type;
  final int? placeRank;
  final double? importance;
  final String? addressType;
  final String? name;
  final String displayName;
  final NominatimAddress? address;
  final List<String>? boundingBox;

  NominatimReverseGeocodeResult({
    required this.placeId,
    this.licence,
    this.osmType,
    this.osmId,
    required this.lat,
    required this.lon,
    this.classType,
    this.type,
    this.placeRank,
    this.importance,
    this.addressType,
    this.name,
    required this.displayName,
    this.address,
    this.boundingBox,
  });

  factory NominatimReverseGeocodeResult.fromJson(Map<String, dynamic> json) {
    return NominatimReverseGeocodeResult(
      placeId: json['place_id'] as int? ?? 0,
      licence: json['licence'] as String?,
      osmType: json['osm_type'] as String?,
      osmId: json['osm_id'] as int?,
      lat: json['lat'] as String? ?? '0.0',
      lon: json['lon'] as String? ?? '0.0',
      classType: json['class'] as String?,
      type: json['type'] as String?,
      placeRank: json['place_rank'] as int?,
      importance: (json['importance'] as num?)?.toDouble(),
      addressType: json['addresstype'] as String?,
      name: json['name'] as String?,
      displayName: json['display_name'] as String? ?? '',
      address: json['address'] != null
          ? NominatimAddress.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      boundingBox: (json['boundingbox'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'place_id': placeId,
        'licence': licence,
        'osm_type': osmType,
        'osm_id': osmId,
        'lat': lat,
        'lon': lon,
        'class': classType,
        'type': type,
        'place_rank': placeRank,
        'importance': importance,
        'addresstype': addressType,
        'name': name,
        'display_name': displayName,
        'address': address?.toJson(),
        'boundingbox': boundingBox,
      };

  /// Get latitude as double
  double get latitude => double.tryParse(lat) ?? 0.0;

  /// Get longitude as double
  double get longitude => double.tryParse(lon) ?? 0.0;

  /// Get city name
  String? getCity() {
    return address?.city ??
        address?.town ??
        address?.village ??
        address?.municipality ??
        address?.county;
  }

  /// Get state/region name
  String? getState() {
    return address?.state ?? address?.stateDistrict;
  }

  /// Get country name
  String? getCountry() {
    return address?.country;
  }

  /// Get formatted short address (city, state)
  String getShortAddress() {
    final city = getCity();
    final state = getState();
    final country = getCountry();

    final parts = <String>[];
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (country != null && country.isNotEmpty && parts.length < 2) {
      parts.add(country);
    }

    return parts.isNotEmpty ? parts.join(', ') : displayName;
  }
}

/// Address details from Nominatim reverse geocoding
class NominatimAddress {
  final String? houseNumber;
  final String? road;
  final String? neighbourhood;
  final String? suburb;
  final String? village;
  final String? town;
  final String? city;
  final String? municipality;
  final String? county;
  final String? stateDistrict;
  final String? state;
  final String? postcode;
  final String? country;
  final String? countryCode;

  NominatimAddress({
    this.houseNumber,
    this.road,
    this.neighbourhood,
    this.suburb,
    this.village,
    this.town,
    this.city,
    this.municipality,
    this.county,
    this.stateDistrict,
    this.state,
    this.postcode,
    this.country,
    this.countryCode,
  });

  factory NominatimAddress.fromJson(Map<String, dynamic> json) {
    return NominatimAddress(
      houseNumber: json['house_number'] as String?,
      road: json['road'] as String?,
      neighbourhood: json['neighbourhood'] as String?,
      suburb: json['suburb'] as String?,
      village: json['village'] as String?,
      town: json['town'] as String?,
      city: json['city'] as String?,
      municipality: json['municipality'] as String?,
      county: json['county'] as String?,
      stateDistrict: json['state_district'] as String?,
      state: json['state'] as String?,
      postcode: json['postcode'] as String?,
      country: json['country'] as String?,
      countryCode: json['country_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'house_number': houseNumber,
        'road': road,
        'neighbourhood': neighbourhood,
        'suburb': suburb,
        'village': village,
        'town': town,
        'city': city,
        'municipality': municipality,
        'county': county,
        'state_district': stateDistrict,
        'state': state,
        'postcode': postcode,
        'country': country,
        'country_code': countryCode,
      };
}

/// Response wrapper for Nominatim reverse geocoding
class NominatimReverseGeocodeResponse {
  final NominatimReverseGeocodeResult? result;
  final String status;
  final String? errorMessage;

  NominatimReverseGeocodeResponse({
    this.result,
    required this.status,
    this.errorMessage,
  });

  /// Create a successful response from JSON
  factory NominatimReverseGeocodeResponse.fromJson(Map<String, dynamic> json) {
    // Check if response contains error
    if (json.containsKey('error')) {
      return NominatimReverseGeocodeResponse(
        result: null,
        status: 'ERROR',
        errorMessage: json['error'] as String?,
      );
    }

    return NominatimReverseGeocodeResponse(
      result: NominatimReverseGeocodeResult.fromJson(json),
      status: 'OK',
    );
  }

  /// Create an error response
  factory NominatimReverseGeocodeResponse.error(String message) {
    return NominatimReverseGeocodeResponse(
      result: null,
      status: 'ERROR',
      errorMessage: message,
    );
  }

  /// Check if the response is successful
  bool get isSuccess => status == 'OK' && result != null;

  /// Get formatted address
  String? get formattedAddress => result?.displayName;

  /// Get city
  String? get city => result?.getCity();

  /// Get state
  String? get state => result?.getState();

  /// Get country
  String? get country => result?.getCountry();

  /// Get short formatted address
  String get shortAddress => result?.getShortAddress() ?? 'Unknown Location';
}
