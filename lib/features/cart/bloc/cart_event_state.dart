import 'package:equatable/equatable.dart';
import '../models/cart_model.dart';

// Events
abstract class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {}

class AddToCart extends CartEvent {
  final int productId;
  final int quantity;

  AddToCart({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class UpdateCartQuantity extends CartEvent {
  final int productId;
  final int quantity;

  UpdateCartQuantity({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCart extends CartEvent {
  final int productId;

  RemoveFromCart({required this.productId});

  @override
  List<Object?> get props => [productId];
}

// States
abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartSubmitting extends CartState {}

class CartLoaded extends CartState {
  final CartModel cart;

  CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}

class CartActionSuccess extends CartState {
  final String message;
  final CartModel cart;

  CartActionSuccess({required this.message, required this.cart});

  @override
  List<Object?> get props => [message, cart];
}
