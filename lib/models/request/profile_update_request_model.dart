class ProfileUpdateRequestModel {
  String? name;
  String? email;
  String? gender;
  String? phone;
  String? address;
  String? profileImageBase64;
  String? profileImageName;
  String? profileImageType;
  bool? showAddressToAll;
  List<String>? interestedCategoryIds;
  List<String>? interestedActions;

  ProfileUpdateRequestModel({
    this.name,
    this.email,
    this.gender,
    this.phone,
    this.address,
    this.profileImageBase64,
    this.profileImageName,
    this.profileImageType,
    this.showAddressToAll,
    this.interestedCategoryIds,
    this.interestedActions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }

    if (email != null && email!.isNotEmpty) {
      json['email'] = email;
    }

    if (gender != null && gender!.isNotEmpty) {
      json['gender'] = gender;
    }

    if (phone != null) {
      json['phone'] = phone;
    }

    if (address != null) {
      json['address'] = address;
    }

    if (profileImageBase64 != null && profileImageBase64!.isNotEmpty) {
      json['profileImageBase64'] = profileImageBase64;
      json['profileImageName'] = profileImageName;
      json['profileImageType'] = profileImageType ?? 'image/jpeg';
    }

    if (showAddressToAll != null) {
      json['showAddressToAll'] = showAddressToAll;
    }

    if (interestedCategoryIds != null) {
      json['interestedCategoryIds'] = interestedCategoryIds;
    }

    if (interestedActions != null) {
      json['interestedActions'] = interestedActions;
    }

    return json;
  }

  factory ProfileUpdateRequestModel.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateRequestModel(
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      phone: json['phone'],
      address: json['address'],
      profileImageBase64: json['profileImageBase64'],
      profileImageName: json['profileImageName'],
      profileImageType: json['profileImageType'],
      showAddressToAll: json['showAddressToAll'],
      interestedCategoryIds: json['interestedCategoryIds'] != null
          ? List<String>.from(json['interestedCategoryIds'])
          : null,
      interestedActions: json['interestedActions'] != null
          ? List<String>.from(json['interestedActions'])
          : null,
    );
  }
}
