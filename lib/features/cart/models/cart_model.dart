import '../../home/models/home_models.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final double price;

  CartItemModel({
    required this.product,
    required this.quantity,
    required this.price,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'product_id': product.id, 'quantity': quantity};
  }
}

class CartModel {
  final List<CartItemModel> items;
  final int totalItems;
  final double totalPrice;

  CartModel({
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Check if the input is already the 'data' part or the full response
    final data = json.containsKey('data') ? json['data'] : json;

    return CartModel(
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
      totalItems: data['total_items'] ?? 0,
      totalPrice: (data['total_price'] ?? 0).toDouble(),
    );
  }

  factory CartModel.empty() {
    return CartModel(items: [], totalItems: 0, totalPrice: 0.0);
  }
}
