import 'package:equatable/equatable.dart';
import '../models/home_models.dart';

// Events
abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchHomeData extends HomeEvent {}

class LoadMoreHomeData extends HomeEvent {}

class ResetHome extends HomeEvent {}

// States
abstract class HomeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeDataModel data;
  final String selectedType;
  final bool isFetchingMore;
  final bool hasReachedMax;

  HomeLoaded(
    this.data, {
    required this.selectedType,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  HomeLoaded copyWith({
    HomeDataModel? data,
    String? selectedType,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return HomeLoaded(
      data ?? this.data,
      selectedType: selectedType ?? this.selectedType,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [
    data,
    selectedType,
    isFetchingMore,
    hasReachedMax,
  ];
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
