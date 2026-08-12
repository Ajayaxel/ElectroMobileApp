import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String confirmPassword;

  RegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, phone, password, confirmPassword];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class ProfileRequested extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String currentPassword;
  final String? newPassword;
  final String? imagePath;

  UpdateProfileRequested({
    this.name,
    this.email,
    this.phone,
    required this.currentPassword,
    this.newPassword,
    this.imagePath,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    currentPassword,
    newPassword,
    imagePath,
  ];
}

class DeleteAccountRequested extends AuthEvent {}
