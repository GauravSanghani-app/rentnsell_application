/// Contact Seller Response Model
///
/// Response structure for GET /api/user/contact-info/{ownerId}
class ContactSellerResponseModel {
  final String name;
  final String mobile;

  ContactSellerResponseModel({
    required this.name,
    required this.mobile,
  });

  factory ContactSellerResponseModel.fromJson(Map<String, dynamic> json) {
    return ContactSellerResponseModel(
      name: json['name']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
    };
  }
}

