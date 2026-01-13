class WishlistAddRequestModel {
  final String productId;

  WishlistAddRequestModel({required this.productId});

  Map<String, dynamic> toJson() {
    return {'productId': productId};
  }

  factory WishlistAddRequestModel.fromJson(Map<String, dynamic> json) {
    return WishlistAddRequestModel(productId: json['productId'] ?? '');
  }
}
