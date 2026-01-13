import 'dart:convert';
import '../product_model.dart';

/// Wishlist GET API Response Model
/// 
/// This model matches the exact structure of the GET /api/user/wishlist response:
/// {
///   "count": 2,
///   "wishlist": [...]
/// }

class WishlistResponse {
  final int count;
  final List<WishlistItem> wishlist;

  WishlistResponse({
    required this.count,
    required this.wishlist,
  });

  factory WishlistResponse.fromJson(Map<String, dynamic> json) {
    return WishlistResponse(
      count: json['count'] ?? 0,
      wishlist: (json['wishlist'] as List<dynamic>?)
              ?.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'wishlist': wishlist.map((e) => e.toJson()).toList(),
    };
  }

  WishlistResponse copyWith({
    int? count,
    List<WishlistItem>? wishlist,
  }) {
    return WishlistResponse(
      count: count ?? this.count,
      wishlist: wishlist ?? this.wishlist,
    );
  }
}

class WishlistItem {
  final String id;
  final String userId;
  final DateTime addedAt;
  final WishlistProduct? product; // Nullable for POST response (add/remove)
  final String? productId; // For POST response when product is not included

  WishlistItem({
    required this.id,
    required this.userId,
    required this.addedAt,
    this.product,
    this.productId,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    // POST response (add/remove) has productId as string, no product object
    // GET response has product object with full details
    WishlistProduct? productData;
    String? productIdOnly;
    
    if (json['product'] != null && json['product'] is Map<String, dynamic>) {
      // GET response: has full product object
      productData = WishlistProduct.fromJson(json['product'] as Map<String, dynamic>);
    } else if (json['productId'] != null) {
      // POST response: has productId as string only
      productIdOnly = json['productId']?.toString();
    }
    
    return WishlistItem(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      product: productData,
      productId: productIdOnly,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'addedAt': addedAt.toIso8601String(),
      if (product != null) 'product': product!.toJson(),
      if (productId != null) 'productId': productId,
    };
  }

  WishlistItem copyWith({
    String? id,
    String? userId,
    DateTime? addedAt,
    WishlistProduct? product,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
      product: product ?? this.product,
    );
  }
}

class WishlistProduct {
  final String ownerId; // Can be string or object - handled as string for now
  final String title;
  final String description;
  final String categoryId;
  final String subCategoryId;
  final String productType;
  final Map<String, dynamic> attributes; // Dynamic attributes
  final Price price;
  final List<String> images;
  final Location location;
  final bool isReviewed;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedDate;
  final String productId; // Actual product identifier (product.productId)

  WishlistProduct({
    required this.ownerId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.subCategoryId,
    required this.productType,
    required this.attributes,
    required this.price,
    required this.images,
    required this.location,
    required this.isReviewed,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedDate,
    required this.productId,
  });

  factory WishlistProduct.fromJson(Map<String, dynamic> json) {
    // Handle ownerId - can be string or object
    String ownerIdValue = '';
    if (json['ownerId'] is String) {
      ownerIdValue = json['ownerId'] as String;
    } else if (json['ownerId'] is Map<String, dynamic>) {
      ownerIdValue = json['ownerId']?['_id']?.toString() ?? '';
    }

    return WishlistProduct(
      ownerId: ownerIdValue,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      subCategoryId: json['subCategoryId']?.toString() ?? 
                     json['subcategoryId']?.toString() ?? 
                     '',
      productType: json['productType']?.toString() ?? 'sell',
      attributes: json['attributes'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['attributes'] as Map)
          : <String, dynamic>{},
      price: Price.fromJson(json['price'] as Map<String, dynamic>? ?? {}),
      images: json['images'] is List
          ? List<String>.from(json['images'] as List)
          : <String>[],
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      isReviewed: json['isReviewed'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedDate: json['reviewedDate'] != null
          ? DateTime.parse(json['reviewedDate'] as String)
          : null,
      productId: json['productId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'productType': productType,
      'attributes': attributes,
      'price': price.toJson(),
      'images': images,
      'location': location.toJson(),
      'isReviewed': isReviewed,
      'createdAt': createdAt.toIso8601String(),
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (reviewedDate != null) 'reviewedDate': reviewedDate!.toIso8601String(),
      'productId': productId,
    };
  }

  WishlistProduct copyWith({
    String? ownerId,
    String? title,
    String? description,
    String? categoryId,
    String? subCategoryId,
    String? productType,
    Map<String, dynamic>? attributes,
    Price? price,
    List<String>? images,
    Location? location,
    bool? isReviewed,
    DateTime? createdAt,
    String? reviewedBy,
    DateTime? reviewedDate,
    String? productId,
  }) {
    return WishlistProduct(
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      productType: productType ?? this.productType,
      attributes: attributes ?? this.attributes,
      price: price ?? this.price,
      images: images ?? this.images,
      location: location ?? this.location,
      isReviewed: isReviewed ?? this.isReviewed,
      createdAt: createdAt ?? this.createdAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedDate: reviewedDate ?? this.reviewedDate,
      productId: productId ?? this.productId,
    );
  }
}

class Price {
  final int rent;
  final int sell;

  Price({
    required this.rent,
    required this.sell,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      rent: (json['rent'] as num?)?.toInt() ?? 0,
      sell: (json['sell'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rent': rent,
      'sell': sell,
    };
  }

  Price copyWith({
    int? rent,
    int? sell,
  }) {
    return Price(
      rent: rent ?? this.rent,
      sell: sell ?? this.sell,
    );
  }
}

class Location {
  final String city;
  final double lat;
  final double lng;

  Location({
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      city: json['city']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'lat': lat,
      'lng': lng,
    };
  }

  Location copyWith({
    String? city,
    double? lat,
    double? lng,
  }) {
    return Location(
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}

// Legacy models for backward compatibility with existing code
// These wrap the new models to maintain compatibility

WishlistResponseModel wishlistResponseModelFromJson(String str) =>
    WishlistResponseModel.fromJson(json.decode(str));

String wishlistResponseModelToJson(WishlistResponseModel data) =>
    json.encode(data.toJson());

class WishlistResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final WishlistItem? wishlistItem;

  WishlistResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.wishlistItem,
  });

  factory WishlistResponseModel.fromJson(Map<String, dynamic> json) =>
      WishlistResponseModel(
        success: json["success"] ?? true,
        statusCode: json["statusCode"] ?? 200,
        message: json["message"] ?? '',
        wishlistItem: json["wishlistItem"] != null
            ? WishlistItem.fromJson(json["wishlistItem"] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "wishlistItem": wishlistItem?.toJson(),
      };
}

class WishlistListResponseModel {
  final bool success;
  final int statusCode;
  final String message;
  final WishlistListResponseData? data;

  WishlistListResponseModel({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory WishlistListResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle direct response with count and wishlist array
    if (json.containsKey("count") && json.containsKey("wishlist")) {
      final wishlistResponse = WishlistResponse.fromJson(json);
      return WishlistListResponseModel(
        success: true,
        statusCode: 200,
        message: json["message"] ?? '',
        data: WishlistListResponseData(
          wishlistItems: wishlistResponse.wishlist
              .where((item) => item.product != null) // Only include items with product data (GET response)
              .map((item) => WishlistItemWithProduct(
                    id: item.id,
                    userId: item.userId,
                    addedAt: item.addedAt,
                    product: _convertWishlistProductToProductModel(item.product!),
                  ))
              .toList(),
          count: wishlistResponse.count,
        ),
      );
    }
    
    // Handle wrapped response
    return WishlistListResponseModel(
      success: json["success"] ?? true,
      statusCode: json["statusCode"] ?? 200,
      message: json["message"] ?? '',
      data: json["data"] != null
          ? WishlistListResponseData.fromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "message": message,
        "data": data?.toJson(),
      };
}

class WishlistListResponseData {
  final List<WishlistItemWithProduct> wishlistItems;
  final int count;

  WishlistListResponseData({
    required this.wishlistItems,
    required this.count,
  });

  factory WishlistListResponseData.fromJson(Map<String, dynamic> json) {
    final wishlistArray = json["wishlist"] as List<dynamic>? ?? [];
    final count = json["count"] as int? ?? wishlistArray.length;
    
    final items = wishlistArray
        .map((item) => WishlistItemWithProduct.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return WishlistListResponseData(
      wishlistItems: items,
      count: count,
    );
  }

  Map<String, dynamic> toJson() => {
        "count": count,
        "wishlist": wishlistItems.map((x) => x.toJson()).toList(),
      };
}

class WishlistItemWithProduct {
  final String id;
  final String userId;
  final ProductModel product; // Converted to ProductModel for UI compatibility
  final DateTime addedAt;

  WishlistItemWithProduct({
    required this.id,
    required this.userId,
    required this.product,
    required this.addedAt,
  });

  factory WishlistItemWithProduct.fromJson(Map<String, dynamic> json) {
    final wishlistItem = WishlistItem.fromJson(json);
    // WishlistItemWithProduct requires product data, so it should only be used for GET response
    if (wishlistItem.product == null) {
      throw Exception('WishlistItemWithProduct requires product data. This model should only be used for GET wishlist response.');
    }
    return WishlistItemWithProduct(
      id: wishlistItem.id,
      userId: wishlistItem.userId,
      addedAt: wishlistItem.addedAt,
      product: _convertWishlistProductToProductModel(wishlistItem.product!),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "product": product.toJson(),
        "addedAt": addedAt.toIso8601String(),
      };
}

// Helper function to convert WishlistProduct to ProductModel
ProductModel _convertWishlistProductToProductModel(WishlistProduct wishlistProduct) {
  // Extract dynamic attributes
  final gender = wishlistProduct.attributes['gender']?.toString() ?? 'unisex';
  final condition = wishlistProduct.attributes['condition']?.toString();
  final size = wishlistProduct.attributes['size']?.toString();
  final color = wishlistProduct.attributes['color']?.toString();
  final brand = wishlistProduct.attributes['brand']?.toString();
  
  // Determine effective type and price
  final productType = wishlistProduct.productType;
  String effectiveType = productType == 'both' ? 'rent' : productType;
  double effectivePrice = productType == 'rent' 
      ? wishlistProduct.price.rent.toDouble()
      : wishlistProduct.price.sell.toDouble();

  // IMPORTANT: Use productId from WishlistProduct as the product identifier
  // This is the actual product ID that should be used for matching and removal
  final productId = wishlistProduct.productId;
  
  if (productId.isEmpty) {
    print('WishlistResponseModel: Warning - Empty productId in WishlistProduct');
    print('WishlistResponseModel: Product title: ${wishlistProduct.title}');
  } else {
    print('WishlistResponseModel: Converting WishlistProduct to ProductModel');
    print('WishlistResponseModel:   Product ID (product.productId): $productId');
    print('WishlistResponseModel:   Product Title: ${wishlistProduct.title}');
  }

  return ProductModel(
    id: productId, // This is product.productId from the API response - used for matching products
    type: effectiveType,
    title: wishlistProduct.title,
    description: wishlistProduct.description,
    price: effectivePrice,
    deposit: null,
    categoryId: wishlistProduct.categoryId,
    subcategoryId: wishlistProduct.subCategoryId,
    imageUrls: wishlistProduct.images,
    location: wishlistProduct.location.city,
    contactPhone: null,
    isContactShow: true,
    gender: gender,
    condition: condition,
    size: size,
    color: color,
    brand: brand,
    sellerId: wishlistProduct.ownerId,
    sellerName: null,
    sellerImageUrl: null,
    createdAt: wishlistProduct.createdAt,
    latitude: wishlistProduct.location.lat,
    longitude: wishlistProduct.location.lng,
    isWishlisted: true,
    distance: null,
    priceObject: {
      'rent': wishlistProduct.price.rent,
      'sell': wishlistProduct.price.sell,
    },
    locationObject: {
      'city': wishlistProduct.location.city,
      'lat': wishlistProduct.location.lat,
      'lng': wishlistProduct.location.lng,
    },
    productType: wishlistProduct.productType,
    attributes: wishlistProduct.attributes,
    isReviewed: wishlistProduct.isReviewed,
  );
}
