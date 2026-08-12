import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/features/cart/data/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc({required this.orderRepository}) : super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
  }

  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final orders = await orderRepository.getOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
