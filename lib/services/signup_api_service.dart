import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import '../api/request_const.dart';
import '../models/response/signup_user_model.dart';

class SignupApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<SignupResponse> signup({
    required String name,
    required String mobile,
    required String email,
    required String gender,
    required String address,
    required String age,
    File? profileImage,
  }) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.signup}';
      logger.t('SignupApiService: POST $url');
      logger.t('SignupApiService: Name: $name, Mobile: $mobile, Email: $email');
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['name'] = name;
      request.fields['mobile'] = mobile;
      request.fields['email'] = email;
      request.fields['gender'] = gender;
      request.fields['address'] = address;
      request.fields['age'] = age;

      if (profileImage != null && await profileImage.exists()) {
        final fileStream = profileImage.openRead();
        final fileLength = await profileImage.length();
        final fileName = path.basename(profileImage.path);
        final contentType = _getContentType(fileName);
        final multipartFile = http.MultipartFile(
          'profileImage',
          fileStream,
          fileLength,
          filename: fileName,
          contentType: contentType,
        );
        request.files.add(multipartFile);
        logger.t('SignupApiService: Added profile image: $fileName');
      }

      logger.t('SignupApiService: Sending multipart request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      logger.t('SignupApiService: Status Code: ${response.statusCode}');
      logger.t('SignupApiService: Response Body: ${response.body}');
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final message = responseData['message'] as String? ?? '';

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (message.contains('already exists') || message.contains('login')) {
          return SignupResponse(
            success: false,
            message: message,
            token: null,
            user: null,
          );
        }

        if (responseData.containsKey('token') &&
            responseData.containsKey('user')) {
          return SignupResponse(
            success: true,
            message: message,
            token: SignupUserModel.fromJson(responseData),
            user: null,
          );
        }
      }

      return SignupResponse(
        success: false,
        message: message.isNotEmpty
            ? message
            : 'Signup failed. Please try again.',
        token: null,
        user: null,
      );
    } catch (e, stackTrace) {
      logger.e('SignupApiService: Exception - $e');
      logger.e('SignupApiService: Stack Trace - $stackTrace');
      return SignupResponse(
        success: false,
        message: 'Network error. Please check your connection and try again.',
        token: null,
        user: null,
      );
    }
  }

  http.MediaType? _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return http.MediaType('image', 'jpeg');
      case '.png':
        return http.MediaType('image', 'png');
      case '.gif':
        return http.MediaType('image', 'gif');
      case '.webp':
        return http.MediaType('image', 'webp');
      default:
        return http.MediaType('image', 'jpeg');
    }
  }
}

class SignupResponse {
  final bool success;
  final String message;
  final SignupUserModel? token;
  final SignupUserModel? user;

  SignupResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}
