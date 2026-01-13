class ProductModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final double price;
  final double? deposit;
  final String categoryId;
  final String subcategoryId;
  final List<String> imageUrls;
  final String location;
  final String? contactPhone;
  final bool isContactShow;
  final String gender;
  final String? condition;
  final String? size;
  final String? color;
  final String? brand;
  final String sellerId;
  final String? sellerName;
  final String? sellerImageUrl;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final bool isWishlisted;
  final double? distance;
  final Map<String, dynamic>? priceObject;
  final Map<String, dynamic>? locationObject;
  final String? productType;
  final Map<String, dynamic>? attributes;
  final bool isReviewed;

  ProductModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    this.deposit,
    required this.categoryId,
    required this.subcategoryId,
    required this.imageUrls,
    required this.location,
    this.contactPhone,
    required this.isContactShow,
    required this.gender,
    this.condition,
    this.size,
    this.color,
    this.brand,
    required this.sellerId,
    this.sellerName,
    this.sellerImageUrl,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.isWishlisted = false,
    this.distance,
    this.priceObject,
    this.locationObject,
    this.productType,
    this.attributes,
    this.isReviewed = true,
  });

  double getPriceForType(String type) {
    if (priceObject != null) {
      if (type == 'rent' && priceObject!.containsKey('rent')) {
        return (priceObject!['rent'] as num?)?.toDouble() ?? 0.0;
      } else if (type == 'sell' && priceObject!.containsKey('sell')) {
        return (priceObject!['sell'] as num?)?.toDouble() ?? 0.0;
      }
    }
    return price;
  }

  String getCity() {
    if (locationObject != null && locationObject!.containsKey('city')) {
      return locationObject!['city'] as String? ?? location;
    }
    return location;
  }

  double? getLatitude() {
    if (locationObject != null && locationObject!.containsKey('lat')) {
      return (locationObject!['lat'] as num?)?.toDouble();
    }
    return latitude;
  }

  double? getLongitude() {
    if (locationObject != null && locationObject!.containsKey('lng')) {
      return (locationObject!['lng'] as num?)?.toDouble();
    }
    return longitude;
  }

  String? getAttribute(String key) {
    if (attributes != null && attributes!.containsKey(key)) {
      final value = attributes![key];
      return value?.toString();
    }
    switch (key) {
      case 'gender':
        return gender;
      case 'size':
        return size;
      case 'color':
        return color;
      case 'brand':
        return brand;
      case 'condition':
        return condition;
      default:
        return null;
    }
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final priceObj = json['price'] is Map<String, dynamic>
        ? json['price'] as Map<String, dynamic>
        : null;
    final locationObj = json['location'] is Map<String, dynamic>
        ? json['location'] as Map<String, dynamic>
        : null;

    double legacyPrice = 0.0;
    if (priceObj != null) {
      legacyPrice =
          (priceObj['rent'] as num?)?.toDouble() ??
          (priceObj['sell'] as num?)?.toDouble() ??
          0.0;
    } else if (json['price'] != null) {
      legacyPrice = (json['price'] as num).toDouble();
    }

    String legacyLocation = '';
    double? legacyLatitude;
    double? legacyLongitude;

    if (locationObj != null) {
      legacyLocation = locationObj['city'] as String? ?? '';
      legacyLatitude = (locationObj['lat'] as num?)?.toDouble();
      legacyLongitude = (locationObj['lng'] as num?)?.toDouble();
    } else if (json['location'] is String) {
      legacyLocation = json['location'] as String;
      legacyLatitude = json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null;
      legacyLongitude = json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null;
    }

    final productTypeValue = json['productType'] as String?;

    String typeValue =
        json['type'] as String? ??
        (productTypeValue == 'both' ? 'rent' : productTypeValue) ??
        'sell';
    List<String> images = [];
    if (json['images'] != null && json['images'] is List) {
      images = (json['images'] as List)
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    } else if (json['imageUrls'] != null && json['imageUrls'] is List) {
      images = List<String>.from(json['imageUrls'] ?? []);
    }

    Map<String, dynamic>? attrs;
    if (json['attributes'] != null && json['attributes'] is Map) {
      attrs = Map<String, dynamic>.from(json['attributes'] as Map);
    }

    String genderValue = json['gender'] as String? ?? 'unisex';
    if (attrs != null && attrs.containsKey('gender')) {
      genderValue = attrs['gender']?.toString() ?? genderValue;
    }

    String ownerIdValue = '';
    String? ownerName;
    String? ownerImageUrl;

    if (json['ownerId'] != null) {
      if (json['ownerId'] is Map<String, dynamic>) {
        final ownerObj = json['ownerId'] as Map<String, dynamic>;
        ownerIdValue =
            ownerObj['_id']?.toString() ??
            ownerObj['id']?.toString() ??
            json['sellerId']?.toString() ??
            '';
        ownerName = ownerObj['name'] as String?;
        ownerImageUrl = ownerObj['profileImage'] as String?;
      } else {
        ownerIdValue = json['ownerId'].toString();
      }
    } else {
      ownerIdValue = json['sellerId']?.toString() ?? '';
    }

    ownerName ??= json['sellerName'] as String?;
    ownerImageUrl ??= json['sellerImageUrl'] as String?;

    final productId =
        json['productId']?.toString() ??
        json['_id']?.toString() ??
        json['id']?.toString() ??
        '';

    return ProductModel(
      id: productId,
      type: typeValue,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: legacyPrice,
      deposit: json['deposit'] != null
          ? (json['deposit'] as num).toDouble()
          : null,
      categoryId: json['categoryId'] ?? '',
      subcategoryId: json['subCategoryId'] ?? json['subcategoryId'] ?? '',
      imageUrls: images,
      location: legacyLocation,
      contactPhone: json['contactPhone'],
      isContactShow: json['isContactShow'] ?? false,
      gender: genderValue,
      condition: json['condition'] ?? attrs?['condition']?.toString(),
      size: json['size'] ?? attrs?['size']?.toString(),
      color: json['color'] ?? attrs?['color']?.toString(),
      brand: json['brand'] ?? attrs?['brand']?.toString(),
      sellerId: ownerIdValue,
      sellerName: ownerName,
      sellerImageUrl: ownerImageUrl,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      latitude:
          legacyLatitude ??
          (json['latitude'] != null
              ? (json['latitude'] as num).toDouble()
              : null),
      longitude:
          legacyLongitude ??
          (json['longitude'] != null
              ? (json['longitude'] as num).toDouble()
              : null),
      isWishlisted: json['isWishlisted'] ?? false,
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      priceObject: priceObj,
      locationObject: locationObj,
      productType: productTypeValue,
      attributes: attrs,
      isReviewed: json['isReviewed'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'price': priceObject ?? price,
      'deposit': deposit,
      'categoryId': categoryId,
      'subCategoryId': subcategoryId,
      'subcategoryId': subcategoryId,
      'images': imageUrls,
      'imageUrls': imageUrls,
      'location': locationObject ?? location,
      'contactPhone': contactPhone,
      'isContactShow': isContactShow,
      'gender': gender,
      'condition': condition,
      'size': size,
      'color': color,
      'brand': brand,
      'ownerId': sellerId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerImageUrl': sellerImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'latitude': latitude ?? getLatitude(),
      'longitude': longitude ?? getLongitude(),
      'isWishlisted': isWishlisted,
      'distance': distance,
      'productType': productType ?? type,
      'attributes': attributes,
      'isReviewed': isReviewed,
    };
  }
}
