import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      final errorMessage =
          (e.response?.data is Map ? e.response?.data['message'] : null) ??
          'Connection error. Please check your internet.';
      throw errorMessage;
    } catch (e) {
      throw 'An unexpected error occurred.';
    }
  }
}
