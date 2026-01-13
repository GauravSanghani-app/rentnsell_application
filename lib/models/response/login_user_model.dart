class LoginUserModel {
  final String token;
  final LoginUser user;

  LoginUserModel({
    required this.token,
    required this.user,
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      token: json['token'] ?? '',
      user: LoginUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class LoginUser {
  final String id;
  final String mobile;
  final String name;
  final String profileImage;
  final String role;
  final String createdAt;
  final int v;

  LoginUser({
    required this.id,
    required this.mobile,
    required this.name,
    required this.profileImage,
    required this.role,
    required this.createdAt,
    required this.v,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['_id'] ?? '',
      mobile: json['mobile'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profileImage'] ?? '',
      role: json['role'] ?? '',
      createdAt: json['createdAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'mobile': mobile,
      'name': name,
      'profileImage': profileImage,
      'role': role,
      'createdAt': createdAt,
      '__v': v,
    };
  }
}

