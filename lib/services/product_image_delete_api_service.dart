import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';

class ProductImageDeleteApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<Map<String, dynamic>> deleteProductImage({
    required String jwtToken,
    required String productId,
    required String imageUrl,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiUrl.baseUrl}${MethodNames.productImageDelete}',
      );
      logger.t('ProductImageDeleteApiService: POST $uri');
      logger.t('ProductImageDeleteApiService: Product ID: $productId');
      logger.t('ProductImageDeleteApiService: Image URL: $imageUrl');

      final requestBody = json.encode({
        'imageUrl': imageUrl,
        'productId': productId,
      });

      logger.t('ProductImageDeleteApiService: Request Body: $requestBody');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: requestBody,
      );

      logger.t(
        'ProductImageDeleteApiService: Status Code: ${response.statusCode}',
      );
      logger.t('ProductImageDeleteApiService: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] as String? ??
              'Image deleted successfully',
          'statusCode': response.statusCode,
        };
      } else {
        String errorMessage = 'Failed to delete image';
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] as String? ?? errorMessage;
        } catch (e) {
          switch (response.statusCode) {
            case 400:
              errorMessage = 'Bad request - imageUrl missing';
              break;
            case 401:
              errorMessage = 'Unauthorized';
              break;
            case 500:
              errorMessage = 'Server error during image deletion';
              break;
            default:
              errorMessage = 'Failed to delete image';
          }
        }
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      logger.e('ProductImageDeleteApiService: Exception: $e');
      return {
        'success': false,
        'message': 'Error deleting image: $e',
        'statusCode': 0,
      };
    }
  }
}
