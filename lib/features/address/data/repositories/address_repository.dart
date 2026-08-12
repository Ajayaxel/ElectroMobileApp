import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:electro/core/network/dio_client.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/core/utils/shared_prefs_util.dart';
import '../models/address_model.dart';

class AddressRepository {
  final Dio _dio = DioClient.createDio();

  Future<Options> _getAuthOptions() async {
    final token = await SharedPrefsUtil.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<AddressModel>> fetchAddresses() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(ApiConstants.address, options: options);

      debugPrint('📦 [AddressRepository] Response: ${response.data}');

      if (response.data['status'] == true) {
        final List<dynamic> addressData = response.data['data'];
        return addressData.map((json) => AddressModel.fromJson(json)).toList();
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch addresses',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ [AddressRepository] Fetch Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to fetch addresses',
      );
    }
  }

  Future<AddressModel> createAddress(AddressModel address) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConstants.address,
        data: address.toJson(),
        options: options,
      );

      debugPrint('📦 [AddressRepository] Create Response: ${response.data}');

      if (response.data['status'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create address');
      }
    } on DioException catch (e) {
      debugPrint('❌ [AddressRepository] Create Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to create address',
      );
    }
  }

  Future<AddressModel> updateAddress(
    int id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.put(
        '${ApiConstants.address}/$id',
        data: updates,
        options: options,
      );

      debugPrint('📦 [AddressRepository] Update Response: ${response.data}');

      if (response.data['status'] == true) {
        return AddressModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to update address');
      }
    } on DioException catch (e) {
      debugPrint('❌ [AddressRepository] Update Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to update address',
      );
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.delete(
        '${ApiConstants.address}/$id',
        options: options,
      );

      debugPrint('📦 [AddressRepository] Delete Response: ${response.data}');

      if (response.data['status'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      debugPrint('❌ [AddressRepository] Delete Error: ${e.response?.data}');
      throw Exception(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Failed to delete address',
      );
    }
  }
}
