import 'package:dio/dio.dart';
import 'package:electro/core/network/dio_client.dart';
import 'package:electro/core/constants/api_constants.dart';
import 'package:electro/core/utils/shared_prefs_util.dart';
import 'package:electro/features/home/models/home_models.dart';

class WishlistRepository {
  final Dio _dio = DioClient.createDio();

  Future<Options> _getAuthOptions() async {
    final token = await SharedPrefsUtil.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<ProductModel>> getWishlist() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(ApiConstants.wishlist, options: options);
      if (response.data['status'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((item) => ProductModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> toggleWishlist(int productId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.post(
        ApiConstants.toggleWishlist,
        data: {'product_id': productId},
        options: options,
      );
      if (response.data['status'] == true) {
        return response.data['is_favorite'] ?? false;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
