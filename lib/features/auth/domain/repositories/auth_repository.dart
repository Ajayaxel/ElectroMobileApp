import 'package:dio/dio.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/features/auth/data/models/user_model.dart';

class AuthRepository {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  Future<UserModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'confirm_password': confirmPassword,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      print('REGISTER API ERROR RESPONSE: ${e.response?.data}');
      throw (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'An error occurred during registration';
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'An error occurred during login';
    }
  }

  Future<UserModel> getProfile(String token) async {
    try {
      final response = await dio.get(
        ApiConstants.profile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'An error occurred fetching profile';
    }
  }

  Future<UserModel> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    required String currentPassword,
    String? newPassword,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'current_password': currentPassword,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (newPassword != null) 'new_password': newPassword,
        if (imagePath != null)
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: 'profile.jpg',
          ),
      });

      final response = await dio.put(
        ApiConstants.profile,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'An error occurred updating profile';
    }
  }

  Future<void> deleteAccount(String token) async {
    try {
      await dio.delete(
        ApiConstants.profile,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'An error occurred deleting account';
    }
  }
}
