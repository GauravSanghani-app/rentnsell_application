import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import '../api/request_const.dart';
import '../models/request/product_create_request_model.dart';
import '../models/response/offering_create_response_model.dart';

class ProductCreateApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<OfferingCreateResponseModel> createProduct({
    required String jwtToken,
    required ProductCreateRequestModel request,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}${MethodNames.productCreate}');

      logger.t('ProductCreateApiService: POST $uri');
      logger.t('ProductCreateApiService: Product Type: ${request.productType}');
      logger.t('ProductCreateApiService: Category: ${request.categoryId}');
      logger.t(
        'ProductCreateApiService: Subcategory: ${request.subCategoryId}',
      );
      logger.t('ProductCreateApiService: Images: ${request.images.length}');

      final multipartRequest = http.MultipartRequest('POST', uri);
      multipartRequest.headers['Authorization'] = 'Bearer $jwtToken';
      final formFields = request.toFormFields();
      multipartRequest.fields.addAll(formFields);

      logger.t('ProductCreateApiService: Form Fields:');
      formFields.forEach((key, value) {
        logger.t(
          '  $key: ${value.length > 100 ? "${value.substring(0, 100)}..." : value}',
        );
      });

      for (int i = 0; i < request.images.length; i++) {
        final imageFile = request.images[i];
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
            'ProductCreateApiService: Added image $i: $fileName (${fileLength} bytes)',
          );
        } else {
          logger.w(
            'ProductCreateApiService: Image file does not exist: ${imageFile.path}',
          );
        }
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      logger.t('ProductCreateApiService: Status Code: ${response.statusCode}');
      logger.t('ProductCreateApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        Map<String, dynamic> responseMap;
        if (responseData is Map<String, dynamic>) {
          responseMap = responseData;
        } else {
          responseMap = {
            'success': true,
            'statusCode': response.statusCode,
            'message': 'Product created successfully',
            'data': responseData,
          };
        }

        if (!responseMap.containsKey('success')) {
          responseMap['success'] = true;
        }
        if (!responseMap.containsKey('statusCode')) {
          responseMap['statusCode'] = response.statusCode;
        }
        if (!responseMap.containsKey('message')) {
          responseMap['message'] = 'Product created successfully';
        }

        final responseModel = OfferingCreateResponseModel.fromJson(responseMap);
        logger.t('ProductCreateApiService: Success - Product created');
        return responseModel;
      } else {
        logger.e(
          'ProductCreateApiService: Error - Status Code: ${response.statusCode}',
        );
        logger.e('ProductCreateApiService: Error - Response: ${response.body}');

        Map<String, dynamic> errorResponse;
        try {
          errorResponse = json.decode(response.body);
        } catch (e) {
          errorResponse = {
            'success': false,
            'statusCode': response.statusCode,
            'message':
                'Failed to create product. Status: ${response.statusCode}',
            'data': null,
          };
        }

        return OfferingCreateResponseModel.fromJson(errorResponse);
      }
    } catch (e, stackTrace) {
      logger.e('ProductCreateApiService: Exception - $e');
      logger.e('ProductCreateApiService: Stack Trace - $stackTrace');

      return OfferingCreateResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to create product: $e',
        data: null,
      );
    }
  }

  MediaType? _getContentType(String filePath) {
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
