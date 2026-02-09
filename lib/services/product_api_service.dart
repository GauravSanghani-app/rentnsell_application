import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../api/request_const.dart';
import '../models/product_model.dart';
import '../models/response/product_list_response_model.dart';
import '../models/response/product_detail_response_model.dart';

class ProductApiService {
  static final Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  Future<ProductListResponseModel> getProducts({
    String? jwtToken,
    required String type,
    String? categoryId,
    String? subCategoryId,
    String? search,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{'type': type};

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }

      if (subCategoryId != null && subCategoryId.isNotEmpty) {
        queryParams['subCategoryId'] = subCategoryId;
      }

      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      if (lat != null && lng != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lng'] = lng.toString();
      }

      if (jwtToken != null && jwtToken.isNotEmpty) {
        queryParams['page'] = page.toString();
        queryParams['limit'] = limit.toString();
      }

      final uri = Uri.parse(
        '${ApiUrl.baseUrl}${MethodNames.productsList}',
      ).replace(queryParameters: queryParams);
      logger.t('ProductApiService: GET $uri');
      logger.t('ProductApiService: Query Params: $queryParams');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (jwtToken != null && jwtToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jwtToken';
      }
      final httpResponse = await http.get(uri, headers: headers);
      logger.t('ProductApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('ProductApiService: Response Body: ${httpResponse.body}');
      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseData = json.decode(httpResponse.body);
        List<ProductModel> products = [];
        int currentPage = 1;
        int totalPages = 1;
        int totalItems = 0;
        int perPage = limit;
        bool hasNextPage = false;
        bool hasPreviousPage = false;
        final isLoggedIn = jwtToken != null && jwtToken.isNotEmpty;

        if (responseData is List) {
          products = responseData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          if (!isLoggedIn) {
            totalItems = products.length;
            totalPages = 1;
            perPage = products.length;
            hasNextPage = false;
            hasPreviousPage = false;
          } else {
            totalItems = products.length;
            totalPages = (products.length >= limit)
                ? (products.length / limit).ceil()
                : 1;
            perPage = limit;
            hasNextPage = products.length >= limit;
            hasPreviousPage = page > 1;
          }
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') &&
              responseData['data'] is List) {
            products = (responseData['data'] as List)
                .map(
                  (item) => ProductModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
            if (responseData.containsKey('pagination') &&
                responseData['pagination'] is Map<String, dynamic>) {
              final pagination =
                  responseData['pagination'] as Map<String, dynamic>;
              currentPage = pagination['currentPage'] ?? page;
              totalPages = pagination['totalPages'] ?? 1;
              totalItems = pagination['totalRecords'] ?? products.length;
              perPage = pagination['pageSize'] ?? limit;
              hasNextPage = currentPage < totalPages;
              hasPreviousPage = currentPage > 1;
            } else {
              currentPage = page;
              totalPages = 1;
              totalItems = products.length;
              perPage = limit;
              hasNextPage = false;
              hasPreviousPage = false;
            }
          } else if (responseData.containsKey('data') &&
              responseData['data'] is Map<String, dynamic>) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('products') && data['products'] is List) {
              products = (data['products'] as List)
                  .map(
                    (item) =>
                        ProductModel.fromJson(item as Map<String, dynamic>),
                  )
                  .toList();
            }

            currentPage = data['currentPage'] ?? page;
            totalPages = data['totalPages'] ?? 1;
            totalItems = data['totalItems'] ?? products.length;
            perPage = data['perPage'] ?? limit;
            hasNextPage = data['hasNextPage'] ?? false;
            hasPreviousPage = data['hasPreviousPage'] ?? false;
          } else if (responseData.containsKey('products') &&
              responseData['products'] is List) {
            products = (responseData['products'] as List)
                .map(
                  (item) => ProductModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
            currentPage = responseData['currentPage'] ?? page;
            totalPages = responseData['totalPages'] ?? 1;
            totalItems = responseData['totalItems'] ?? products.length;
            perPage = responseData['perPage'] ?? limit;
            hasNextPage = responseData['hasNextPage'] ?? false;
            hasPreviousPage = responseData['hasPreviousPage'] ?? false;
          }
        }

        final filteredProducts = products.where((product) {
          if (product.productType == 'both') {
            return true;
          }
          return product.productType == type;
        }).toList();

        final reviewedProducts = filteredProducts
            .where((product) => product.isReviewed)
            .toList();

        final finalProducts = isLoggedIn
            ? reviewedProducts
            : reviewedProducts.take(10).toList();

        final finalHasNextPage = isLoggedIn ? hasNextPage : false;

        final responseModel = ProductListResponseModel(
          success: true,
          statusCode: 200,
          message: 'Products retrieved successfully',
          data: ProductListResponseData(
            products: finalProducts,
            currentPage: currentPage,
            totalPages: isLoggedIn ? totalPages : 1,
            totalItems: isLoggedIn ? totalItems : finalProducts.length,
            perPage: isLoggedIn ? perPage : finalProducts.length,
            hasNextPage: finalHasNextPage,
            hasPreviousPage: isLoggedIn ? hasPreviousPage : false,
          ),
        );

        logger.t(
          'ProductApiService: Success - ${finalProducts.length} products (Page $currentPage/${isLoggedIn ? totalPages : 1}, Logged in: $isLoggedIn)',
        );
        return responseModel;
      } else {
        logger.e(
          'ProductApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('ProductApiService: Error - Response: ${httpResponse.body}');

        return ProductListResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message:
              'Failed to load products. Status: ${httpResponse.statusCode}',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('ProductApiService: Exception - $e');
      logger.e('ProductApiService: Stack Trace - $stackTrace');

      return ProductListResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to load products: $e',
        data: null,
      );
    }
  }

  Future<ProductDetailResponseModel> getProductDetail({
    String? jwtToken,
    required String productId,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}products/$productId');
      logger.t('ProductApiService: GET $uri');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (jwtToken != null && jwtToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $jwtToken';
      }
      final httpResponse = await http.get(uri, headers: headers);
      logger.t('ProductApiService: Status Code: ${httpResponse.statusCode}');
      logger.t('ProductApiService: Response Body: ${httpResponse.body}');

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        final responseData = json.decode(httpResponse.body);
        ProductModel? product;
        if (responseData is Map<String, dynamic>) {
          product = ProductModel.fromJson(responseData);
        }

        if (product != null) {
          final responseModel = ProductDetailResponseModel(
            success: true,
            statusCode: 200,
            message: 'Product retrieved successfully',
            data: product,
          );
          logger.t('ProductApiService: Success - Product loaded');
          return responseModel;
        } else {
          return ProductDetailResponseModel(
            success: false,
            statusCode: httpResponse.statusCode,
            message: 'Invalid product data',
            data: null,
          );
        }
      } else {
        logger.e(
          'ProductApiService: Error - Status Code: ${httpResponse.statusCode}',
        );
        logger.e('ProductApiService: Error - Response: ${httpResponse.body}');

        return ProductDetailResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: 'Failed to load product. Status: ${httpResponse.statusCode}',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e('ProductApiService: Exception - $e');
      logger.e('ProductApiService: Stack Trace - $stackTrace');

      return ProductDetailResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to load product: $e',
        data: null,
      );
    }
  }

  Future<ProductListResponseModel> getMyProducts({
    required String jwtToken,
  }) async {
    try {
      final url = Uri.parse('${ApiUrl.baseUrl}products/my/list');
      logger.i('ProductApiService: Fetching my products');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };
      final httpResponse = await http.get(url, headers: headers);
      logger.i(
        'ProductApiService: My Products Status Code: ${httpResponse.statusCode}',
      );
      logger.d(
        'ProductApiService: My Products Response Body: ${httpResponse.body}',
      );

      if (httpResponse.statusCode == 200) {
        final responseData = json.decode(httpResponse.body);

        List<ProductModel> products = [];
        if (responseData is List) {
          products = responseData
              .map(
                (item) => ProductModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        } else if (responseData is Map<String, dynamic>) {
          if (responseData['data'] != null && responseData['data'] is List) {
            products = (responseData['data'] as List)
                .map(
                  (item) => ProductModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
        }

        return ProductListResponseModel(
          success: true,
          statusCode: 200,
          message: 'My products retrieved successfully',
          data: ProductListResponseData(
            products: products,
            currentPage: 1,
            totalPages: 1,
            totalItems: products.length,
            perPage: products.length,
            hasNextPage: false,
            hasPreviousPage: false,
          ),
        );
      } else if (httpResponse.statusCode == 401) {
        logger.e('ProductApiService: Unauthorized - Invalid token');
        return ProductListResponseModel(
          success: false,
          statusCode: 401,
          message: 'Unauthorized - Please login',
          data: null,
        );
      } else {
        logger.e(
          'ProductApiService: Error ${httpResponse.statusCode}: ${httpResponse.body}',
        );
        return ProductListResponseModel(
          success: false,
          statusCode: httpResponse.statusCode,
          message: 'Failed to load my products',
          data: null,
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        'ProductApiService: Exception in getMyProducts',
        error: e,
        stackTrace: stackTrace,
      );
      return ProductListResponseModel(
        success: false,
        statusCode: 0,
        message: 'Failed to load my products: $e',
        data: null,
      );
    }
  }

  /// Delete a product by ID.
  /// Success: 200 with body {"msg": "Product removed"}.
  /// Failure: e.g. 404 with "Product not found" or API error message.
  Future<({bool success, String message})> deleteProduct({
    required String productId,
    required String jwtToken,
  }) async {
    try {
      final uri = Uri.parse('${ApiUrl.baseUrl}products/$productId');
      logger.i('ProductApiService: DELETE $uri');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      };
      final httpResponse = await http.delete(uri, headers: headers);
      logger.i(
        'ProductApiService: Delete Status Code: ${httpResponse.statusCode}',
      );
      logger.d('ProductApiService: Delete Response: ${httpResponse.body}');

      if (httpResponse.statusCode == 200) {
        final body = httpResponse.body.trim();
        if (body.isNotEmpty) {
          try {
            final decoded = json.decode(body);
            if (decoded is Map && decoded['msg'] != null) {
              return (success: true, message: decoded['msg'].toString());
            }
          } catch (_) {}
        }
        return (success: true, message: 'Product removed');
      }

      // Parse error message from response
      String errorMessage = 'Failed to delete product';
      final body = httpResponse.body.trim();
      if (body.isNotEmpty) {
        try {
          final decoded = json.decode(body);
          if (decoded is Map && decoded['msg'] != null) {
            errorMessage = decoded['msg'].toString();
          } else if (decoded is String) {
            errorMessage = decoded;
          }
        } catch (_) {
          if (body.length < 200) errorMessage = body;
        }
      } else if (httpResponse.statusCode == 404) {
        errorMessage = 'Product not found';
      }

      return (success: false, message: errorMessage);
    } catch (e, stackTrace) {
      logger.e(
        'ProductApiService: Exception in deleteProduct',
        error: e,
        stackTrace: stackTrace,
      );
      return (
        success: false,
        message: 'Network error. Please check your connection and try again.',
      );
    }
  }
}
