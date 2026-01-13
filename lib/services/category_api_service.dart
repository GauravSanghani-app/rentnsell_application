import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/category_model.dart';

class CategoryApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<List<CategoryModel>> getCategories() async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.category}';
      logger.t('CategoryApiService: GET $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      logger.t('CategoryApiService: Status Code: ${response.statusCode}');
      logger.t('CategoryApiService: Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        List<dynamic> categoriesList;
        if (responseData is List) {
          categoriesList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          categoriesList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is Map &&
            responseData.containsKey('categories')) {
          categoriesList = responseData['categories'] as List<dynamic>? ?? [];
        } else {
          logger.w('CategoryApiService: Unexpected response structure');
          categoriesList = [];
        }

        return categoriesList
            .map((item) => CategoryModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        logger.e(
          'CategoryApiService: Error - Status Code: ${response.statusCode}',
        );
        logger.e('CategoryApiService: Error - Response: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      logger.e('CategoryApiService: Exception - $e');
      logger.e('CategoryApiService: Stack Trace - $stackTrace');
      return [];
    }
  }
}
