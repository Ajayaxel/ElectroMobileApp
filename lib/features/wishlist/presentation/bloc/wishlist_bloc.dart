import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/wishlist/data/wishlist_repository.dart';
import 'package:electro/features/home/models/home_models.dart';

// Events
abstract class WishlistEvent {}

class FetchWishlist extends WishlistEvent {}

class ToggleWishlistEvent extends WishlistEvent {
  final int productId;
  ToggleWishlistEvent(this.productId);
}

// States
abstract class WishlistState {}

class WishlistInitial extends WishlistState {}

class WishlistLoading extends WishlistState {}

class WishlistLoaded extends WishlistState {
  final List<ProductModel> products;
  WishlistLoaded(this.products);
}

class WishlistError extends WishlistState {
  final String message;
  WishlistError(this.message);
}

// BLoC
class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistRepository repository;

  WishlistBloc(this.repository) : super(WishlistInitial()) {
    on<FetchWishlist>(_onFetchWishlist);
    on<ToggleWishlistEvent>(_onToggleWishlist);
  }

  Future<void> _onFetchWishlist(
    FetchWishlist event,
    Emitter<WishlistState> emit,
  ) async {
    emit(WishlistLoading());
    try {
      final products = await repository.getWishlist();
      emit(WishlistLoaded(products));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  Future<void> _onToggleWishlist(
    ToggleWishlistEvent event,
    Emitter<WishlistState> emit,
  ) async {
    try {
      await repository.toggleWishlist(event.productId);
      if (state is WishlistLoaded) {
        final products = await repository.getWishlist();
        emit(WishlistLoaded(products));
      }
    } catch (e) {
      // Handle error quietly or emit error state
    }
  }
}
