import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/response/unread_count_response_model.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<UnreadCountResponseModel> getUnreadCount({
    required String jwtToken,
  }) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.unreadNotificationCount}';
      logger.t('NotificationApiService: GET $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      logger.t('NotificationApiService: Status Code: ${response.statusCode}');
      logger.t('NotificationApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        return UnreadCountResponseModel.fromJson(responseData);
      } else {
        logger.e('NotificationApiService: Failed to get unread count. Status: ${response.statusCode}');
        return UnreadCountResponseModel(
          success: false,
          unreadCount: 0,
        );
      }
    } catch (e, stackTrace) {
      logger.e('NotificationApiService: Exception - $e');
      logger.e('NotificationApiService: Stack Trace - $stackTrace');
      return UnreadCountResponseModel(
        success: false,
        unreadCount: 0,
      );
    }
  }

  Future<List<NotificationModel>> getAllNotifications({
    required String jwtToken,
  }) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.allNotifications}';
      logger.t('NotificationApiService: GET $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      logger.t('NotificationApiService: Status Code: ${response.statusCode}');
      logger.t('NotificationApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        
        if (responseData is List) {
          return responseData
              .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          logger.e('NotificationApiService: Unexpected response format');
          return [];
        }
      } else {
        logger.e('NotificationApiService: Failed to get notifications. Status: ${response.statusCode}');
        return [];
      }
    } catch (e, stackTrace) {
      logger.e('NotificationApiService: Exception - $e');
      logger.e('NotificationApiService: Stack Trace - $stackTrace');
      return [];
    }
  }
}

