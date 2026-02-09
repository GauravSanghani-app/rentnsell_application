import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/response/nominatim_search_response_model.dart';
import '../models/response/nominatim_reverse_geocode_response_model.dart';

/// Nominatim OpenStreetMap API Service
/// 
/// This service provides location search and reverse geocoding functionality
/// using the free Nominatim OpenStreetMap API.
/// 
/// API Documentation: https://nominatim.org/release-docs/develop/api/Overview/
class NominatimApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // Nominatim API Base URLs
  static const String _searchBaseUrl =
      'https://nominatim.openstreetmap.org/search';
  static const String _reverseBaseUrl =
      'https://nominatim.openstreetmap.org/reverse';

  // Default country code for India
  static const String _defaultCountryCode = 'in';

  // User-Agent header (required by Nominatim usage policy)
  static const Map<String, String> _headers = {
    'User-Agent': 'RentNSell/1.0 (Flutter App)',
    'Accept': 'application/json',
  };

  /// Search for locations by query text
  ///
  /// Parameters:
  /// - query: The search text entered by the user
  /// - countryCode: Optional country code to filter results (default: 'in' for India)
  ///
  /// Returns: NominatimSearchResponse with location results
  Future<NominatimSearchResponse> searchLocations({
    required String query,
    String? countryCode,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return NominatimSearchResponse.empty();
      }

      final uri = Uri.parse(_searchBaseUrl).replace(
        queryParameters: {
          'q': query.trim(),
          'format': 'json',
          'countrycodes': countryCode ?? _defaultCountryCode,
        },
      );

      logger.t('NominatimApiService: GET $uri');

      final httpResponse = await http.get(uri, headers: _headers);

      logger.t(
          'NominatimApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('NominatimApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();
        
        if (responseBody.isEmpty || responseBody == '[]') {
          logger.t('NominatimApiService: Empty response received');
          return NominatimSearchResponse.empty();
        }

        try {
          final responseData = json.decode(responseBody);
          
          if (responseData is List) {
            return NominatimSearchResponse.fromJsonList(responseData);
          } else {
            logger.e('NominatimApiService: Unexpected response format');
            return NominatimSearchResponse.error('Unexpected response format');
          }
        } catch (e) {
          logger.e('NominatimApiService: JSON decode error - $e');
          return NominatimSearchResponse.error('Failed to parse response');
        }
      } else {
        logger.e(
            'NominatimApiService: Error - Status Code: ${httpResponse.statusCode}');
        logger.e('NominatimApiService: Error - Response: ${httpResponse.body}');
        return NominatimSearchResponse.error(
            'Request failed with status ${httpResponse.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('NominatimApiService: Exception - $e');
      logger.e('NominatimApiService: Stack Trace - $stackTrace');

      // Check for network errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        return NominatimSearchResponse.error('No internet connection');
      }

      return NominatimSearchResponse.error('An error occurred: $e');
    }
  }

  /// Reverse geocoding - Convert latitude and longitude to address
  ///
  /// Parameters:
  /// - latitude: GPS latitude coordinate
  /// - longitude: GPS longitude coordinate
  ///
  /// Returns: NominatimReverseGeocodeResponse with address information
  Future<NominatimReverseGeocodeResponse> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_reverseBaseUrl).replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
          'format': 'json',
        },
      );

      logger.t('NominatimApiService: GET $uri');

      final httpResponse = await http.get(uri, headers: _headers);

      logger.t(
          'NominatimApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('NominatimApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();

        if (responseBody.isEmpty) {
          logger.t('NominatimApiService: Empty response received');
          return NominatimReverseGeocodeResponse.error('No address found');
        }

        try {
          final responseData = json.decode(responseBody);
          
          if (responseData is Map<String, dynamic>) {
            // Check for error in response
            if (responseData.containsKey('error')) {
              final errorMessage = responseData['error'] as String? ?? 'Unknown error';
              logger.e('NominatimApiService: API Error - $errorMessage');
              return NominatimReverseGeocodeResponse.error(errorMessage);
            }
            
            return NominatimReverseGeocodeResponse.fromJson(responseData);
          } else {
            logger.e('NominatimApiService: Unexpected response format');
            return NominatimReverseGeocodeResponse.error('Unexpected response format');
          }
        } catch (e) {
          logger.e('NominatimApiService: JSON decode error - $e');
          return NominatimReverseGeocodeResponse.error('Failed to parse response');
        }
      } else {
        logger.e(
            'NominatimApiService: Error - Status Code: ${httpResponse.statusCode}');
        logger.e('NominatimApiService: Error - Response: ${httpResponse.body}');
        return NominatimReverseGeocodeResponse.error(
            'Request failed with status ${httpResponse.statusCode}');
      }
    } catch (e, stackTrace) {
      logger.e('NominatimApiService: Exception - $e');
      logger.e('NominatimApiService: Stack Trace - $stackTrace');

      // Check for network errors
      if (e.toString().contains('SocketException') ||
          e.toString().contains('network')) {
        return NominatimReverseGeocodeResponse.error('No internet connection');
      }

      return NominatimReverseGeocodeResponse.error('An error occurred: $e');
    }
  }
}
