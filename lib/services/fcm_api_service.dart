import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/response/fcm_token_response_model.dart';

class FcmApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<FcmTokenResponseModel> saveFcmToken({
    required String jwtToken,
    required String token,
    required String platform,
  }) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.saveFcmToken}';
      final requestBody = {'token': token, 'platform': platform};
      logger.t('FcmApiService: POST $url');
      logger.t('FcmApiService: Request Body: ${json.encode(requestBody)}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      logger.t('FcmApiService: Status Code: ${response.statusCode}');
      logger.t('FcmApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return FcmTokenResponseModel.fromJson(responseData);
      } else {
        logger.e(
          'FcmApiService: Failed to save FCM token. Status: ${response.statusCode}',
        );
        return FcmTokenResponseModel(
          success: false,
          message: 'Failed to save FCM token',
        );
      }
    } catch (e, stackTrace) {
      logger.e('FcmApiService: Exception - $e');
      logger.e('FcmApiService: Stack Trace - $stackTrace');
      return FcmTokenResponseModel(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }

  Future<FcmTokenResponseModel> removeFcmToken({
    required String jwtToken,
    required String token,
  }) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.removeFcmToken}';
      final requestBody = {'token': token};
      logger.t('FcmApiService: POST $url');
      logger.t('FcmApiService: Request Body: ${json.encode(requestBody)}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestBody),
      );

      logger.t('FcmApiService: Status Code: ${response.statusCode}');
      logger.t('FcmApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return FcmTokenResponseModel.fromJson(responseData);
      } else {
        logger.e(
          'FcmApiService: Failed to remove FCM token. Status: ${response.statusCode}',
        );
        return FcmTokenResponseModel(
          success: false,
          message: 'Failed to remove FCM token',
        );
      }
    } catch (e, stackTrace) {
      logger.e('FcmApiService: Exception - $e');
      logger.e('FcmApiService: Stack Trace - $stackTrace');
      return FcmTokenResponseModel(
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }
}
