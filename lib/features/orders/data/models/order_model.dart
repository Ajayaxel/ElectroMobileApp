import 'package:electro/features/home/models/home_models.dart';

class OrderItemModel {
  final ProductModel product;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }
}

class OrderModel {
  final int id;
  final List<OrderItemModel> items;
  final int totalItems;
  final double itemsPrice;
  final double deliveryFee;
  final double totalPrice;
  final String paymentMethod;
  final String status;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalItems,
    required this.itemsPrice,
    required this.deliveryFee,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      totalItems: json['totalItems'] ?? 0,
      itemsPrice: (json['itemsPrice'] ?? 0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'Unknown',
      status: json['status'] ?? 'Pending',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
