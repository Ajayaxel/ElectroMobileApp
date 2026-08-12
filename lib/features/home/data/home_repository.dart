import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';
import '../models/home_models.dart';

class HomeRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<HomeDataModel> fetchHomeData({int page = 1}) async {
    try {
      debugPrint(
        '🔄 [HomeRepository] Calling GET ${ApiConstants.baseUrl}${ApiConstants.home}?page=$page ...',
      );
      final response = await _dio.get(
        ApiConstants.home,
        queryParameters: {'page': page},
      );

      debugPrint('✅ [HomeRepository] Status: ${response.statusCode}');
      debugPrint('📦 [HomeRepository] Response: ${response.data}');

      final model = HomeDataModel.fromJson(response.data);
      debugPrint('📂 Sections: ${model.sections.length}');
      return model;
    } on DioException catch (e) {
      debugPrint('❌ [HomeRepository] DioException: ${e.type}');
      debugPrint('❌ [HomeRepository] Message: ${e.message}');
      debugPrint('❌ [HomeRepository] URL: ${e.requestOptions.uri}');
      debugPrint('❌ [HomeRepository] Response: ${e.response?.data}');
      throw Exception(e.message ?? 'Failed to fetch home data');
    } catch (e) {
      debugPrint('❌ [HomeRepository] Unknown error: $e');
      rethrow;
    }
  }

  Future<List<String>> fetchBrandCapacities(String brandName) async {
    try {
      final response =
          await _dio.get('${ApiConstants.brands}/$brandName/capacities');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ [HomeRepository] Error fetching capacities: $e');
      return [];
    }
  }
}
