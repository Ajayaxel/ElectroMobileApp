import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/cart_repository.dart';
import 'cart_event_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<FetchCart>(_onFetchCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartQuantity>(_onUpdateCartQuantity);
    on<RemoveFromCart>(_onRemoveFromCart);
  }

  Future<void> _onFetchCart(FetchCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await _cartRepository.fetchCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    // We don't want to show a full screen loading for add to cart usually,
    // maybe just a subtle one or success message.
    // For now, let's keep it simple.
    final currentState = state;
    emit(CartSubmitting());
    try {
      final cart = await _cartRepository.addToCart(
        event.productId,
        event.quantity,
      );
      emit(CartActionSuccess(message: 'Item added to cart', cart: cart));
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (currentState is CartLoaded) {
        emit(CartLoaded(currentState.cart));
      }
    }
  }

  Future<void> _onUpdateCartQuantity(
    UpdateCartQuantity event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    // For quantity update, we might want to stay on the same screen
    try {
      final cart = await _cartRepository.updateQuantity(
        event.productId,
        event.quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (currentState is CartLoaded) {
        emit(CartLoaded(currentState.cart));
      }
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    try {
      final cart = await _cartRepository.removeFromCart(event.productId);
      emit(CartActionSuccess(message: 'Item removed from cart', cart: cart));
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (currentState is CartLoaded) {
        emit(CartLoaded(currentState.cart));
      }
    }
  }
}
