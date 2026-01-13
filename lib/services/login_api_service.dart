import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/response/login_user_model.dart';

class LoginApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<LoginResponse> loginWithMobile(String mobile) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.login}';
      final requestBody = {'mobile': mobile};
      logger.t('LoginApiService: POST $url');
      logger.t('LoginApiService: Request Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      logger.t('LoginApiService: Status Code: ${response.statusCode}');
      logger.t('LoginApiService: Response Body: ${response.body}');
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final message = responseData['message'] as String? ?? '';

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (message.contains('not found') || message.contains('signup')) {
          return LoginResponse(
            success: false,
            message: message,
            token: null,
            user: null,
          );
        }

        if (responseData.containsKey('token') &&
            responseData.containsKey('user')) {
          return LoginResponse(
            success: true,
            message: message,
            token: LoginUserModel.fromJson(responseData),
            user: null,
          );
        }
      }

      return LoginResponse(
        success: false,
        message: message.isNotEmpty
            ? message
            : 'Login failed. Please try again.',
        token: null,
        user: null,
      );
    } catch (e, stackTrace) {
      logger.e('LoginApiService: Exception - $e');
      logger.e('LoginApiService: Stack Trace - $stackTrace');
      return LoginResponse(
        success: false,
        message: 'Network error. Please check your connection and try again.',
        token: null,
        user: null,
      );
    }
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginUserModel? token;
  final LoginUserModel? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}
