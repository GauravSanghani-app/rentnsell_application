import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/subcategory_model.dart';

class SubcategoryApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<List<SubcategoryModel>> getSubcategories(String categoryId) async {
    try {
      final url = '${ApiUrl.baseUrl}${MethodNames.subcategory}/$categoryId';
      logger.t('SubcategoryApiService: GET $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      logger.t('SubcategoryApiService: Status Code: ${response.statusCode}');
      logger.t('SubcategoryApiService: Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        List<dynamic> subcategoriesList;

        if (responseData is List) {
          subcategoriesList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          subcategoriesList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is Map &&
            responseData.containsKey('subcategories')) {
          subcategoriesList =
              responseData['subcategories'] as List<dynamic>? ?? [];
        } else {
          logger.w('SubcategoryApiService: Unexpected response structure');
          subcategoriesList = [];
        }

        return subcategoriesList.map((item) {
          final jsonItem = item as Map<String, dynamic>;
          final catId = jsonItem['categoryId'] ?? categoryId;
          return SubcategoryModel.fromJson({...jsonItem, 'categoryId': catId});
        }).toList();
      } else {
        logger.e(
          'SubcategoryApiService: Error - Status Code: ${response.statusCode}',
        );
        logger.e('SubcategoryApiService: Error - Response: ${response.body}');
        return [];
      }
    } catch (e, stackTrace) {
      logger.e('SubcategoryApiService: Exception - $e');
      logger.e('SubcategoryApiService: Stack Trace - $stackTrace');
      return [];
    }
  }
}
