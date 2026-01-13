import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/response/contact_seller_response_model.dart';

class ContactSellerApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<ContactSellerResponseModel?> getSellerContact({
    required String ownerId,
    required String jwtToken,
  }) async {
    try {
      if (ownerId.isEmpty) {
        logger.e(
          'ContactSellerApiService: ownerId is empty, cannot fetch contact info',
        );
        return null;
      }
      final url = Uri.parse('${ApiUrl.baseUrl}user/contact-info/$ownerId');

      logger.i(
        'ContactSellerApiService: Fetching contact info for ownerId: $ownerId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      logger.i(
        'ContactSellerApiService: Response status: ${response.statusCode}',
      );
      logger.d('ContactSellerApiService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        return ContactSellerResponseModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        logger.e('ContactSellerApiService: Unauthorized - Invalid token');
        return null;
      } else if (response.statusCode == 404) {
        logger.e('ContactSellerApiService: Contact info not found');
        return null;
      } else {
        logger.e(
          'ContactSellerApiService: Error ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      logger.e(
        'ContactSellerApiService: Exception occurred',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
