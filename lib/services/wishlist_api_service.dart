import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/request/wishlist_add_request_model.dart';
import '../models/response/wishlist_response_model.dart';

class WishlistApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<WishlistResponseModel> addToWishlist({
    required String jwtToken,
    required WishlistAddRequestModel request,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}user/wishlist');
      logger.t('WishlistApiService: POST $uri');
      logger.t('WishlistApiService: ProductId: ${request.productId}');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };
      final requestBody = jsonEncode(request.toJson());
      final httpResponse = await http.post(
        uri,
        headers: headers,
        body: requestBody,
      );

      logger.t('WishlistApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('WishlistApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseData =
            json.decode(httpResponse.body) as Map<String, dynamic>;
        return WishlistResponseModel.fromJson(responseData);
      } else {
        final responseBody = httpResponse.body.trim();
        String errorMessage =
            'Failed to add to wishlist. Status: ${httpResponse.statusCode}';

        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          }
        } catch (_) {
          if (responseBody.isNotEmpty) {
            errorMessage = responseBody;
          }
        }

        logger.e(
          'WishlistApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('WishlistApiService: Error - Response: $responseBody');

        return WishlistResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: errorMessage,
          wishlistItem: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('WishlistApiService: Exception - $e');
      logger.e('WishlistApiService: Stack Trace - $stackTrace');

      return WishlistResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to add to wishlist: $e',
        wishlistItem: null,
      );
    }
  }

  Future<WishlistResponseModel> removeFromWishlist({
    required String jwtToken,
    required String productId,
  }) async {
    try {
      // IMPORTANT: productId must be the product ID (product.productId) from the GET /api/user/wishlist response
      // This is the product.productId field, NOT the wishlist item _id
      if (productId.isEmpty) {
        throw Exception('Product ID cannot be empty');
      }
      
      final uri = Uri.parse('${ApiUrl.baseUrl}user/wishlist/$productId');

      logger.t('WishlistApiService: DELETE $uri');
      logger.t('WishlistApiService: Product ID: $productId');
      logger.t('WishlistApiService: Using product ID (product.productId) for deletion');
      logger.t('WishlistApiService: Expected format: DELETE /api/user/wishlist/{productId}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final httpResponse = await http.delete(uri, headers: headers);

      logger.t('WishlistApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('WishlistApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseData =
            json.decode(httpResponse.body) as Map<String, dynamic>;
        return WishlistResponseModel.fromJson(responseData);
      } else {
        final responseBody = httpResponse.body.trim();
        String errorMessage =
            'Failed to remove from wishlist. Status: ${httpResponse.statusCode}';

        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          }
        } catch (_) {
          if (responseBody.isNotEmpty) {
            errorMessage = responseBody;
          }
        }

        logger.e(
          'WishlistApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('WishlistApiService: Error - Response: $responseBody');

        return WishlistResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: errorMessage,
          wishlistItem: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('WishlistApiService: Exception - $e');
      logger.e('WishlistApiService: Stack Trace - $stackTrace');

      return WishlistResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to remove from wishlist: $e',
        wishlistItem: null,
      );
    }
  }

  Future<WishlistListResponseModel> getWishlist({
    required String jwtToken,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}user/wishlist');
      logger.t('WishlistApiService: GET $uri');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final httpResponse = await http.get(uri, headers: headers);
      logger.t('WishlistApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('WishlistApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseData =
            json.decode(httpResponse.body) as Map<String, dynamic>;
        // API returns direct WishlistResponse structure with count and wishlist array
        // Wrap it in WishlistListResponseModel for backward compatibility
        return WishlistListResponseModel.fromJson(responseData);
      } else {
        final responseBody = httpResponse.body.trim();
        String errorMessage =
            'Failed to get wishlist. Status: ${httpResponse.statusCode}';

        try {
          final errorData = json.decode(responseBody);
          if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = errorData['message'] as String;
          } else if (errorData is Map && errorData.containsKey('error')) {
            errorMessage = errorData['error'] as String;
          }
        } catch (_) {
          if (responseBody.isNotEmpty) {
            errorMessage = responseBody;
          }
        }

        logger.e(
          'WishlistApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('WishlistApiService: Error - Response: $responseBody');

        return WishlistListResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('WishlistApiService: Exception - $e');
      logger.e('WishlistApiService: Stack Trace - $stackTrace');

      return WishlistListResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to get wishlist: $e',
        data: null,
      );
    }
  }
}
