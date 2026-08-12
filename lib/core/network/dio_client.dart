import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:electro/core/constants/api_constants.dart';

class DioClient {
  static VoidCallback? onUnauthorized;

  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map && data['status'] == false) {
            final message = data['message']?.toString() ?? '';
            if (message.contains('Not authorized') || message.contains('user not found')) {
              debugPrint('⚠️ [DioClient] Unauthorized response detected: $message');
              onUnauthorized?.call();
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          final data = e.response?.data;
          bool isUnauthorized = false;

          if (data is Map) {
            final message = data['message']?.toString() ?? '';
            if (message.contains('Not authorized') || message.contains('user not found')) {
              isUnauthorized = true;
            }
          }

          if (e.response?.statusCode == 401) {
            isUnauthorized = true;
          }

          if (isUnauthorized) {
            debugPrint('⚠️ [DioClient] Unauthorized error detected (Status: ${e.response?.statusCode})');
            onUnauthorized?.call();
          }

          return handler.next(e);
        },
      ),
    );

    return dio;
  }
}
