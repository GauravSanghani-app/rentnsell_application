/// Nominatim OpenStreetMap Search Response Model
/// 
/// This model represents a single location result from the Nominatim API.
/// API Endpoint: https://nominatim.openstreetmap.org/search
class NominatimSearchResult {
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
  final List<String>? boundingBox;

  NominatimSearchResult({
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
    this.boundingBox,
  });

  factory NominatimSearchResult.fromJson(Map<String, dynamic> json) {
    return NominatimSearchResult(
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
        'boundingbox': boundingBox,
      };

  /// Get latitude as double
  double get latitude => double.tryParse(lat) ?? 0.0;

  /// Get longitude as double
  double get longitude => double.tryParse(lon) ?? 0.0;

  /// Get the main text (name or first part of display_name)
  String get mainText {
    if (name != null && name!.isNotEmpty) {
      return name!;
    }
    // Extract first part before comma
    final parts = displayName.split(',');
    return parts.isNotEmpty ? parts.first.trim() : displayName;
  }

  /// Get the secondary text (remaining address after main text)
  String get secondaryText {
    if (name != null && name!.isNotEmpty) {
      // Remove the name from display_name to get the rest of the address
      String remaining = displayName;
      if (displayName.startsWith(name!)) {
        remaining = displayName.substring(name!.length);
        // Remove leading comma and whitespace
        remaining = remaining.replaceFirst(RegExp(r'^[,\s]+'), '');
      }
      return remaining;
    }
    // Skip first part and return the rest
    final parts = displayName.split(',');
    if (parts.length > 1) {
      return parts.sublist(1).join(',').trim();
    }
    return '';
  }

  /// Get a unique identifier string for this place
  String get uniqueId => placeId.toString();
}

/// Response wrapper for Nominatim search results
class NominatimSearchResponse {
  final List<NominatimSearchResult> results;
  final String status;
  final String? errorMessage;

  NominatimSearchResponse({
    required this.results,
    required this.status,
    this.errorMessage,
  });

  /// Create a successful response from JSON array
  factory NominatimSearchResponse.fromJsonList(List<dynamic> jsonList) {
    return NominatimSearchResponse(
      results: jsonList
          .map((item) =>
              NominatimSearchResult.fromJson(item as Map<String, dynamic>))
          .toList(),
      status: 'OK',
    );
  }

  /// Create an error response
  factory NominatimSearchResponse.error(String message) {
    return NominatimSearchResponse(
      results: [],
      status: 'ERROR',
      errorMessage: message,
    );
  }

  /// Create an empty response
  factory NominatimSearchResponse.empty() {
    return NominatimSearchResponse(
      results: [],
      status: 'OK',
    );
  }

  /// Check if the response is successful
  bool get isSuccess => status == 'OK';

  /// Check if the response has results
  bool get hasResults => results.isNotEmpty;
}
