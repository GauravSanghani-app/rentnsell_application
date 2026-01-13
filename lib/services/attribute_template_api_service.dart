import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/attribute_template_model.dart';

class AttributeTemplateApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<List<AttributeTemplateModel>> getAttributeTemplate(
    String subcategoryId, {
    String? jwtToken,
  }) async {
    try {
      final url =
          '${ApiUrl.baseUrl}${MethodNames.attributeTemplate}/$subcategoryId';
      logger.t('AttributeTemplateApiService: GET $url');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (jwtToken != null && jwtToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jwtToken';
      }
      final response = await http.get(Uri.parse(url), headers: headers);
      logger.t(
        'AttributeTemplateApiService: Status Code: ${response.statusCode}',
      );
      logger.t('AttributeTemplateApiService: Response Body: ${response.body}');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        List<dynamic> templateList;
        if (responseData is List) {
          templateList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          templateList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is Map &&
            responseData.containsKey('templates')) {
          templateList = responseData['templates'] as List<dynamic>? ?? [];
        } else {
          logger.w(
            'AttributeTemplateApiService: Unexpected response structure',
          );
          templateList = [];
        }
        return templateList
            .map(
              (item) =>
                  AttributeTemplateModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        logger.e(
          'AttributeTemplateApiService: Error - Status Code: ${response.statusCode}',
        );
        logger.e(
          'AttributeTemplateApiService: Error - Response: ${response.body}',
        );
        return [];
      }
    } catch (e, stackTrace) {
      logger.e('AttributeTemplateApiService: Exception - $e');
      logger.e('AttributeTemplateApiService: Stack Trace - $stackTrace');
      return [];
    }
  }
}
