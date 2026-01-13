class SignupUserModel {
  final String token;
  final SignupUser user;

  SignupUserModel({
    required this.token,
    required this.user,
  });

  factory SignupUserModel.fromJson(Map<String, dynamic> json) {
    return SignupUserModel(
      token: json['token'] ?? '',
      user: SignupUser.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class SignupUser {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String gender;
  final String address;
  final int age;
  final String role;
  final String createdAt;

  SignupUser({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.gender,
    required this.address,
    required this.age,
    required this.role,
    required this.createdAt,
  });

  factory SignupUser.fromJson(Map<String, dynamic> json) {
    return SignupUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      age: json['age'] is int ? json['age'] : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'gender': gender,
      'address': address,
      'age': age,
      'role': role,
      'createdAt': createdAt,
    };
  }
}

