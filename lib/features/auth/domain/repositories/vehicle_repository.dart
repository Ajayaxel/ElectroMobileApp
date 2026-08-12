import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class VehicleBrand {
  final int id;
  final String name;
  final String logo;

  VehicleBrand({required this.id, required this.name, required this.logo});

  factory VehicleBrand.fromJson(Map<String, dynamic> json) {
    return VehicleBrand(
      id: json['id'] ?? json['brandId'] ?? 0,
      name: json['name'] ?? '',
      logo: json['logo'] ?? json['image'] ?? '',
    );
  }
}

class VehicleModelItem {
  final int id;
  final String name;
  final String image;
  final String type;
  final String category;

  VehicleModelItem({
    required this.id,
    required this.name,
    required this.image,
    required this.type,
    required this.category,
  });

  factory VehicleModelItem.fromJson(Map<String, dynamic> json) {
    return VehicleModelItem(
      id: json['id'] ?? json['modelId'] ?? 0,
      name: json['name'] ?? json['modelName'] ?? '',
      image: json['image'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? json['modelCategory'] ?? '',
    );
  }
}

class NestedVehicleType {
  final String id;
  final String name;
  final List<NestedBrand> brands;

  NestedVehicleType({
    required this.id,
    required this.name,
    required this.brands,
  });

  factory NestedVehicleType.fromJson(Map<String, dynamic> json) {
    return NestedVehicleType(
      id: json['vehicleType'],
      name: json['name'] ?? '',
      brands: (json['brands'] as List)
          .map((e) => NestedBrand.fromJson(e))
          .toList(),
    );
  }
}

class NestedBrand {
  final int brandId;
  final String brandName;
  final String image;
  final List<VehicleModelItem> models;

  NestedBrand({
    required this.brandId,
    required this.brandName,
    required this.image,
    required this.models,
  });

  factory NestedBrand.fromJson(Map<String, dynamic> json) {
    return NestedBrand(
      brandId: json['brandId'] ?? json['id'] ?? 0,
      brandName: json['brandName'] ?? json['name'] ?? '',
      image: json['image'] ?? '',
      models: (json['models'] as List? ?? [])
          .map((e) => VehicleModelItem.fromJson(e))
          .toList(),
    );
  }
}

class VehicleRepository {
  Future<List<NestedVehicleType>> getNestedVehicleData() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.allVehicleData),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => NestedVehicleType.fromJson(e)).toList();
    }
    throw Exception('Failed to load nested vehicle data');
  }

  Future<List<String>> getModelCategories({
    required String vehicleType,
  }) async {
    final normalizedType = vehicleType.toLowerCase();
    final url =
        '${ApiConstants.baseUrl}${ApiConstants.modelCategories}?vehicle_type=$normalizedType';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data
          .map((e) => (e['id'] ?? '').toString())
          .where((id) => id.isNotEmpty)
          .toList();
    }
    return [];
  }

  Future<List<VehicleBrand>> getBrands() async {
    final response = await http.get(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.vehicleBrands),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => VehicleBrand.fromJson(e)).toList();
    }
    throw Exception('Failed to load brands');
  }

  Future<List<VehicleModelItem>> getModels(
    int brandId,
    String type, {
    String? category,
  }) async {
    final categoryQuery =
        category != null && category.isNotEmpty ? '&category=$category' : '';
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.vehicleModels}?brand_id=$brandId&type=${type.toLowerCase()}$categoryQuery',
      ),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((e) => VehicleModelItem.fromJson(e)).toList();
    }
    throw Exception('Failed to load models');
  }

  Future<Map<String, dynamic>> addUserVehicle({
    required int userId,
    required int brandId,
    required int modelId,
    required String vehicleType,
    required String country,
    required String emirate,
    required String plateCode,
    required String plateNumber,
  }) async {
    final payload = {
      'user_id': userId,
      'brand_id': brandId,
      'model_id': modelId,
      'vehicle_type': vehicleType.toLowerCase(),
      'country': country,
      'emirate': emirate,
      'plate_code': plateCode,
      'plate_number': plateNumber,
    };

    print('--- API REQUEST: addUserVehicle ---');
    print('Payload: ${json.encode(payload)}');

    final response = await http.post(
      Uri.parse(ApiConstants.baseUrl + ApiConstants.userVehicles),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    final responseData = json.decode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('--- API SUCCESS: addUserVehicle ---');
      print('Response: ${response.body}');
    } else {
      print('--- API ERROR: addUserVehicle ---');
      print('Status: ${response.statusCode}');
      print('Error Body: ${response.body}');
    }

    return responseData;
  }

  Future<List<Map<String, dynamic>>> getUserVehicles(int userId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userVehicles}?user_id=$userId',
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    throw Exception('Failed to load user vehicles');
  }

  Future<Map<String, dynamic>> removeUserVehicle(int vehicleId) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.userVehicles}/$vehicleId',
      ),
      headers: {'Content-Type': 'application/json'},
    );
    return json.decode(response.body);
  }
}
