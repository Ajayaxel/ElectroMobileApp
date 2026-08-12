// Brand Model
class BrandModel {
  final int id;
  final String name;
  final String image;

  BrandModel({required this.id, required this.name, required this.image});

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: _sanitizeUrl(json['image'] as String?),
    );
  }
}

class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String? link;
  final bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.link,
    required this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      image: _sanitizeUrl(json['image'] as String?),
      link: json['link'],
      isActive: json['isActive'] ?? true,
    );
  }
}

String _sanitizeUrl(String? url) {
  if (url == null || url.trim().isEmpty)
    return 'https://placehold.co/400x400?text=No+Image';

  // If it's already a full URL, return it
  if (url.startsWith('http')) {
    return url;
  }

  // Handle local development relative paths
  // Backend is usually at http://localhost:5001
  final String cleanPath = url.startsWith('/') ? url : '/$url';
  return 'http://localhost:5001$cleanPath';
}

// Product Model
class ProductModel {
  final int id;
  final String brand;
  final String name;
  final String description;
  final double price;
  final String image;
  final List<String> images;
  final String warranty;
  final String capacity;
  final String voltage;
  final bool isFavorite;
  final String type;
  final String stockStatus;
  final String batteryType;
  final String ah;
  final String cca;
  final String dimensions;
  final String partNumber;

  ProductModel({
    required this.id,
    required this.brand,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.images,
    required this.warranty,
    required this.capacity,
    required this.voltage,
    required this.isFavorite,
    required this.type,
    required this.stockStatus,
    required this.batteryType,
    required this.ah,
    required this.cca,
    required this.dimensions,
    required this.partNumber,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      image: _sanitizeUrl(json['image'] as String?),
      images: json['images'] != null
          ? List<String>.from(
              json['images'],
            ).map((e) => _sanitizeUrl(e)).toList()
          : [],
      warranty: json['warranty'] ?? 'Not specified',
      capacity: json['capacity'] ?? 'Not specified',
      voltage: json['voltage'] ?? 'Not specified',
      isFavorite: json['is_favorite'] ?? false,
      type: json['type'] ?? '',
      stockStatus: json['stock_status'] ?? 'In Stock',
      batteryType: json['battery_type'] ?? 'Not specified',
      ah: json['ah'] ?? 'Not specified',
      cca: json['cca'] ?? 'Not specified',
      dimensions: json['dimensions'] ?? 'Not specified',
      partNumber: json['part_number'] ?? 'Not specified',
    );
  }
}

// Section Model
class SectionModel {
  final String title;
  final String type;
  final List<ProductModel> items;

  SectionModel({required this.title, required this.type, required this.items});

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    return SectionModel(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => ProductModel.fromJson(item))
          .toList(),
    );
  }
}

// Pagination Model
class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int pages;

  PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}

class HomeDataModel {
  final List<BrandModel> brands;
  final List<BannerModel> banners;
  final List<SectionModel> sections;
  final PaginationModel pagination;

  HomeDataModel({
    required this.brands,
    required this.banners,
    required this.sections,
    required this.pagination,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return HomeDataModel(
      brands: (data['brands'] as List<dynamic>? ?? [])
          .map((b) => BrandModel.fromJson(b))
          .toList(),
      banners: (data['banners'] as List<dynamic>? ?? [])
          .map((b) => BannerModel.fromJson(b))
          .toList(),
      sections: (data['sections'] as List<dynamic>? ?? [])
          .map((s) => SectionModel.fromJson(s))
          .toList(),
      pagination: PaginationModel.fromJson(data['pagination'] ?? {}),
    );
  }
}
