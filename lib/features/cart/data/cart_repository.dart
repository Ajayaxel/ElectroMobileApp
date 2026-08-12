import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:electro/core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/shared_prefs_util.dart';
import '../models/cart_model.dart';

class CartRepository {
  final Dio _dio = DioClient.createDio();

  Future<Options> _getAuthOptions() async {
    final token = await SharedPrefsUtil.getToken();
    return Options(
      contentType: Headers.jsonContentType,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<CartModel> fetchCart() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(ApiConstants.cart, options: options);

      if (response.data['status'] == true) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch cart');
      }
    } on DioException catch (e) {
      debugPrint('❌ [CartRepository] Fetch Error: ${e.response?.data}');
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to fetch cart');
    }
  }

  Future<CartModel> addToCart(int productId, int quantity) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConstants.addToCart,
        data: {'product_id': productId, 'quantity': quantity},
        options: options,
      );

      if (response.data['status'] == true) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to add to cart');
      }
    } on DioException catch (e) {
      debugPrint('❌ [CartRepository] Add Error: ${e.response?.data}');
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to add to cart');
    }
  }

  Future<CartModel> updateQuantity(int productId, int quantity) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        ApiConstants.updateCart,
        data: {'product_id': productId, 'quantity': quantity},
        options: options,
      );

      if (response.data['status'] == true) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to update quantity',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [CartRepository] Update Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to update quantity',
      );
    }
  }

  Future<CartModel> removeFromCart(int productId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.delete(
        ApiConstants.removeFromCart,
        queryParameters: {'product_id': productId},
        options: options,
      );

      if (response.data['status'] == true) {
        return CartModel.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to remove from cart',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [CartRepository] Remove Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to remove from cart',
      );
    }
  }
}
