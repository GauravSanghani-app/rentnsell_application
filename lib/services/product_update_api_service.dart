import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import '../api/request_const.dart';
import '../models/request/product_update_request_model.dart';
import '../models/response/offering_create_response_model.dart';

class ProductUpdateApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<OfferingCreateResponseModel> updateProduct({
    required String jwtToken,
    required String productId,
    required ProductUpdateRequestModel request,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiUrl.baseUrl}${MethodNames.productUpdate}/$productId',
      );

      logger.t('ProductUpdateApiService: PUT $uri');
      logger.t('ProductUpdateApiService: Product ID: $productId');
      logger.t('ProductUpdateApiService: Product Type: ${request.productType}');
      logger.t('ProductUpdateApiService: Category: ${request.categoryId}');
      logger.t(
        'ProductUpdateApiService: New Images: ${request.newImages.length}',
      );

      final multipartRequest = http.MultipartRequest('PUT', uri);
      multipartRequest.headers['Authorization'] = 'Bearer $jwtToken';
      final formFields = request.toFormFields();
      multipartRequest.fields.addAll(formFields);
      logger.t('ProductUpdateApiService: Form Fields:');
      formFields.forEach((key, value) {
        logger.t(
          '  $key: ${value.length > 100 ? "${value.substring(0, 100)}..." : value}',
        );
      });

      for (int i = 0; i < request.newImages.length; i++) {
        final imageFile = request.newImages[i];
        if (await imageFile.exists()) {
          final fileStream = http.ByteStream(imageFile.openRead());
          final fileLength = await imageFile.length();
          final fileName = path.basename(imageFile.path);
          final contentType = _getContentType(imageFile.path);

          final multipartFile = http.MultipartFile(
            'images',
            fileStream,
            fileLength,
            filename: fileName,
            contentType: contentType,
          );

          multipartRequest.files.add(multipartFile);
          logger.t(
            'ProductUpdateApiService: Added new image $i: $fileName (${fileLength} bytes)',
          );
        } else {
          logger.w(
            'ProductUpdateApiService: Image file does not exist: ${imageFile.path}',
          );
        }
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      logger.t('ProductUpdateApiService: Status Code: ${response.statusCode}');
      logger.t('ProductUpdateApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        final success = responseData['success'] as bool? ?? true;
        final message =
            responseData['message'] as String? ??
            'Product updated successfully';
        final statusCode =
            responseData['statusCode'] as int? ?? response.statusCode;

        return OfferingCreateResponseModel(
          success: success,
          message: message,
          statusCode: statusCode,
        );
      } else {
        try {
          final errorData = json.decode(response.body);
          final errorMessage =
              errorData['message'] as String? ?? 'Failed to update product';
          return OfferingCreateResponseModel(
            success: false,
            message: errorMessage,
            statusCode: response.statusCode,
          );
        } catch (e) {
          return OfferingCreateResponseModel(
            success: false,
            message: 'Failed to update product: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }
      }
    } catch (e) {
      logger.e('ProductUpdateApiService: Exception: $e');
      return OfferingCreateResponseModel(
        success: false,
        message: 'Error updating product: $e',
        statusCode: 0,
      );
    }
  }

  MediaType _getContentType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }
}
