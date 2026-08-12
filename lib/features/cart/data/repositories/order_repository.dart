import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:electro/core/network/dio_client.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/core/utils/shared_prefs_util.dart';
import 'package:electro/features/orders/data/models/order_model.dart';

class OrderRepository {
  final Dio _dio = DioClient.createDio();

  Future<Options> _getAuthOptions() async {
    final token = await SharedPrefsUtil.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<bool> placeOrder({
    required int addressId,
    required String paymentMethod,
    double deliveryFee = 0.0,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConstants.placeOrder,
        data: {
          'addressId': addressId,
          'paymentMethod': paymentMethod,
          'deliveryFee': deliveryFee,
        },
        options: options,
      );

      if (response.data['status'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to place order');
      }
    } on DioException catch (e) {
      debugPrint('❌ [OrderRepository] Place Order Error: ${e.response?.data}');
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to place order');
    }
  }

  Future<List<OrderModel>> getOrders() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        ApiConstants.userOrders,
        options: options,
      );

      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch orders');
      }
    } on DioException catch (e) {
      debugPrint('❌ [OrderRepository] Get Orders Error: ${e.response?.data}');
      throw Exception((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to fetch orders');
    }
  }
}
