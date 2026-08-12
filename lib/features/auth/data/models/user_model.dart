import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String token;
  final String? profileImage;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.token,
    this.profileImage,
  });

  @override
  List<Object?> get props => [id, name, email, phone, token, profileImage];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      token: json['token'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'token': token,
      'profileImage': profileImage,
    };
  }
}
