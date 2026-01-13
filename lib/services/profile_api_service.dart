import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import '../api/request_const.dart';
import '../models/response/profile_get_response_model.dart';

class ProfileApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<ProfileGetResponseModel> getProfile({required String jwtToken}) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}${MethodNames.userProfile}');

      logger.t('ProfileApiService: GET $uri');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };

      final httpResponse = await http.get(uri, headers: headers);

      logger.t('ProfileApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('ProfileApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseBody = httpResponse.body.trim();
        if (responseBody.toLowerCase().contains('token is not valid') ||
            responseBody.toLowerCase().contains('token is invalid')) {
          logger.e('ProfileApiService: Invalid token response');
          return ProfileGetResponseModel(
            success: false,
            statusCode: 401,
            message: 'Token is not valid. Please login again.',
            data: null,
          );
        }

        try {
          final responseData = json.decode(responseBody);
          Map<String, dynamic>? profileData;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') &&
                responseData['data'] is Map) {
              profileData = responseData['data'] as Map<String, dynamic>;
            } else {
              profileData = responseData;
            }
          }

          if (profileData != null) {
            final responseModel = ProfileGetResponseModel(
              success: true,
              statusCode: 200,
              message:
                  (responseData is Map && responseData.containsKey('message'))
                  ? responseData['message'] as String
                  : 'Profile retrieved successfully',
              data: ProfileGetResponseData.fromJson(profileData),
            );

            logger.t('ProfileApiService: Success - Profile loaded');
            return responseModel;
          } else {
            return ProfileGetResponseModel(
              success: false,
              statusCode: httpResponse.statusCode,
              message: 'Invalid profile data',
              data: null,
            );
          }
        } catch (e) {
          logger.e('ProfileApiService: JSON parse error: $e');
          return ProfileGetResponseModel(
            success: false,
            statusCode: httpResponse.statusCode,
            message: responseBody.isNotEmpty
                ? responseBody
                : 'Invalid response format',
            data: null,
          );
        }
      } else {
        final responseBody = httpResponse.body.trim();
        String errorMessage =
            'Failed to load profile. Status: ${httpResponse.statusCode}';
        if (httpResponse.statusCode == 401 ||
            responseBody.toLowerCase().contains('token') ||
            responseBody.toLowerCase().contains('unauthorized') ||
            responseBody.toLowerCase().contains('invalid')) {
          errorMessage = 'Token is not valid. Please login again.';
        } else {
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
        }

        logger.e(
          'ProfileApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('ProfileApiService: Error - Response: $responseBody');
        return ProfileGetResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('ProfileApiService: Exception - $e');
      logger.e('ProfileApiService: Stack Trace - $stackTrace');

      return ProfileGetResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to load profile: $e',
        data: null,
      );
    }
  }

  Future<ProfileGetResponseModel> updateProfile({
    required String jwtToken,
    required String? name,
    required String? email,
    required String? gender,
    required String? address,
    required String? age,
    File? profileImage,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}${MethodNames.userProfile}');

      logger.t('ProfileApiService: PUT $uri');

      final multipartRequest = http.MultipartRequest('PUT', uri);
      multipartRequest.headers['Authorization'] = 'Bearer $jwtToken';
      if (name != null && name.isNotEmpty) {
        multipartRequest.fields['name'] = name;
      }
      if (email != null && email.isNotEmpty) {
        multipartRequest.fields['email'] = email;
      }
      if (gender != null && gender.isNotEmpty) {
        multipartRequest.fields['gender'] = gender;
      }
      if (address != null && address.isNotEmpty) {
        multipartRequest.fields['address'] = address;
      }
      if (age != null && age.isNotEmpty) {
        multipartRequest.fields['age'] = age;
      }

      logger.t('ProfileApiService: Form Fields:');
      multipartRequest.fields.forEach((key, value) {
        logger.t('  $key: $value');
      });

      if (profileImage != null && await profileImage.exists()) {
        final fileStream = http.ByteStream(profileImage.openRead());
        final fileLength = await profileImage.length();
        final fileName = path.basename(profileImage.path);
        final contentType = _getContentType(profileImage.path);

        final multipartFile = http.MultipartFile(
          'profileImage',
          fileStream,
          fileLength,
          filename: fileName,
          contentType: contentType,
        );

        multipartRequest.files.add(multipartFile);
        logger.t(
          'ProfileApiService: Added profile image: $fileName (${fileLength} bytes)',
        );
      }

      final streamedResponse = await multipartRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      logger.t('ProfileApiService: Status Code: ${response.statusCode}');
      logger.t('ProfileApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseBody = response.body.trim();

        try {
          final responseData = json.decode(responseBody);
          Map<String, dynamic>? profileData;
          if (responseData is Map<String, dynamic>) {
            if (responseData.containsKey('data') &&
                responseData['data'] is Map) {
              profileData = responseData['data'] as Map<String, dynamic>;
            } else {
              profileData = responseData;
            }
          }

          if (profileData != null) {
            return ProfileGetResponseModel(
              success: true,
              statusCode: 200,
              message:
                  (responseData is Map && responseData.containsKey('message'))
                  ? responseData['message'] as String
                  : 'Profile updated successfully',
              data: ProfileGetResponseData.fromJson(profileData),
            );
          } else {
            return ProfileGetResponseModel(
              success: false,
              statusCode: response.statusCode,
              message: 'Invalid profile data in response',
              data: null,
            );
          }
        } catch (e) {
          logger.e('ProfileApiService: JSON parse error: $e');
          return ProfileGetResponseModel(
            success: false,
            statusCode: response.statusCode,
            message: responseBody.isNotEmpty
                ? responseBody
                : 'Invalid response format',
            data: null,
          );
        }
      } else {
        final responseBody = response.body.trim();
        String errorMessage =
            'Failed to update profile. Status: ${response.statusCode}';

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
          'ProfileApiService: Error - Status Code: ${response.statusCode}',
        );
        logger.e('ProfileApiService: Error - Response: $responseBody');

        return ProfileGetResponseModel(
          success: false,
          statusCode: response.statusCode,
          message: errorMessage,
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('ProfileApiService: Exception - $e');
      logger.e('ProfileApiService: Stack Trace - $stackTrace');

      return ProfileGetResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to update profile: $e',
        data: null,
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

  bool isProfileComplete(ProfileGetResponseData? profileData) {
    if (profileData == null) return false;
    if (profileData.isProfileComplete) return true;
    final hasName = profileData.name != null && profileData.name!.isNotEmpty;
    final hasEmail = profileData.email != null && profileData.email!.isNotEmpty;
    final hasGender =
        profileData.gender != null && profileData.gender!.isNotEmpty;
    final hasAddress =
        profileData.address != null && profileData.address!.isNotEmpty;
    return hasName && hasEmail && hasGender && hasAddress;
  }
}
