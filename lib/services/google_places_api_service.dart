import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/response/google_places_autocomplete_response_model.dart';
import '../models/response/google_places_details_response_model.dart';
import '../models/response/google_geocoding_response_model.dart';

class GooglePlacesApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // Google Places API Key
  static const String _apiKey = 'AIzaSyCfGNMXCGyFZXqSGAIfYvk3psoiOGe5g-Q';
  static const String _autocompleteBaseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _placeDetailsBaseUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String _geocodingBaseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Get location autocomplete suggestions
  ///
  /// Parameters:
  /// - input: The search text entered by the user
  ///
  /// Returns: GooglePlacesAutocompleteResponseModel with predictions
  Future<GooglePlacesAutocompleteResponseModel> getAutocompleteSuggestions({
    required String input,
  }) async {
    try {
      if (input.trim().isEmpty) {
        return GooglePlacesAutocompleteResponseModel(
          predictions: [],
          status: 'OK',
        );
      }

      final uri = Uri.parse(_autocompleteBaseUrl).replace(
        queryParameters: {
          'input': input.trim(),
          'key': _apiKey,
        },
      );

      logger.t('GooglePlacesApiService: GET $uri');

      final httpResponse = await http.get(uri);

      logger.t(
          'GooglePlacesApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('GooglePlacesApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 &&
          httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();
        try {
          final responseData = json.decode(responseBody);
          return GooglePlacesAutocompleteResponseModel.fromJson(
              responseData as Map<String, dynamic>);
        } catch (e) {
          logger.e('GooglePlacesApiService: JSON decode error - $e');
          return GooglePlacesAutocompleteResponseModel(
            predictions: [],
            status: 'ERROR',
          );
        }
      } else {
        logger.e(
            'GooglePlacesApiService: Error - Status Code: ${httpResponse.statusCode}');
        logger.e('GooglePlacesApiService: Error - Response: ${httpResponse.body}');
        return GooglePlacesAutocompleteResponseModel(
          predictions: [],
          status: 'ERROR',
        );
      }
    } catch (e, stackTrace) {
      logger.e('GooglePlacesApiService: Exception - $e');
      logger.e('GooglePlacesApiService: Stack Trace - $stackTrace');

      return GooglePlacesAutocompleteResponseModel(
        predictions: [],
        status: 'ERROR',
      );
    }
  }

  /// Get place details (latitude and longitude)
  ///
  /// Parameters:
  /// - placeId: The place_id from the autocomplete prediction
  ///
  /// Returns: GooglePlacesDetailsResponseModel with location coordinates
  Future<GooglePlacesDetailsResponseModel> getPlaceDetails({
    required String placeId,
  }) async {
    try {
      final uri = Uri.parse(_placeDetailsBaseUrl).replace(
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
        },
      );

      logger.t('GooglePlacesApiService: GET $uri');

      final httpResponse = await http.get(uri);

      logger.t(
          'GooglePlacesApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('GooglePlacesApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 &&
          httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();
        try {
          final responseData = json.decode(responseBody);
          return GooglePlacesDetailsResponseModel.fromJson(
              responseData as Map<String, dynamic>);
        } catch (e) {
          logger.e('GooglePlacesApiService: JSON decode error - $e');
          return GooglePlacesDetailsResponseModel(
            result: null,
            status: 'ERROR',
          );
        }
      } else {
        logger.e(
            'GooglePlacesApiService: Error - Status Code: ${httpResponse.statusCode}');
        logger.e('GooglePlacesApiService: Error - Response: ${httpResponse.body}');
        return GooglePlacesDetailsResponseModel(
          result: null,
          status: 'ERROR',
        );
      }
    } catch (e, stackTrace) {
      logger.e('GooglePlacesApiService: Exception - $e');
      logger.e('GooglePlacesApiService: Stack Trace - $stackTrace');

      return GooglePlacesDetailsResponseModel(
        result: null,
        status: 'ERROR',
      );
    }
  }

  /// Reverse geocoding - Convert latitude and longitude to address
  ///
  /// Parameters:
  /// - latitude: GPS latitude coordinate
  /// - longitude: GPS longitude coordinate
  ///
  /// Returns: GoogleGeocodingResponseModel with address information
  Future<GoogleGeocodingResponseModel> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(_geocodingBaseUrl).replace(
        queryParameters: {
          'latlng': '$latitude,$longitude',
          'key': _apiKey,
        },
      );

      logger.t('GooglePlacesApiService: GET $uri');

      final httpResponse = await http.get(uri);

      logger.t(
          'GooglePlacesApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('GooglePlacesApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 &&
          httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();
        try {
          final responseData = json.decode(responseBody);
          return GoogleGeocodingResponseModel.fromJson(
              responseData as Map<String, dynamic>);
        } catch (e) {
          logger.e('GooglePlacesApiService: JSON decode error - $e');
          return GoogleGeocodingResponseModel(
            results: [],
            status: 'ERROR',
          );
        }
      } else {
        logger.e(
            'GooglePlacesApiService: Error - Status Code: ${httpResponse.statusCode}');
        logger.e('GooglePlacesApiService: Error - Response: ${httpResponse.body}');
        return GoogleGeocodingResponseModel(
          results: [],
          status: 'ERROR',
        );
      }
    } catch (e, stackTrace) {
      logger.e('GooglePlacesApiService: Exception - $e');
      logger.e('GooglePlacesApiService: Stack Trace - $stackTrace');

      return GoogleGeocodingResponseModel(
        results: [],
        status: 'ERROR',
      );
    }
  }
}
