import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/home_repository.dart';
import '../models/home_models.dart';
import 'home_event_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(HomeInitial()) {
    on<FetchHomeData>(_onFetchHomeData);
    on<LoadMoreHomeData>(_onLoadMoreHomeData);
    on<ResetHome>((event, emit) => emit(HomeInitial()));
  }

  Future<void> _onFetchHomeData(
    FetchHomeData event,
    Emitter<HomeState> emit,
  ) async {
    // PREVENT OVERCALLING: If we are already loading, ignore this request.
    if (state is HomeLoading) return;

    emit(HomeLoading());
    try {
      final data = await _repository.fetchHomeData(page: 1);
      emit(
        HomeLoaded(
          data,
          selectedType: 'battery',
          hasReachedMax: data.pagination.page >= data.pagination.pages,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLoadMoreHomeData(
    LoadMoreHomeData event,
    Emitter<HomeState> emit,
  ) async {
    if (state is HomeLoaded) {
      final current = state as HomeLoaded;
      if (current.isFetchingMore || current.hasReachedMax) return;

      emit(current.copyWith(isFetchingMore: true));

      try {
        final nextPage = current.data.pagination.page + 1;
        final newData = await _repository.fetchHomeData(page: nextPage);

        if (newData.sections.isEmpty || newData.sections.first.items.isEmpty) {
          emit(current.copyWith(isFetchingMore: false, hasReachedMax: true));
        } else {
          final updatedItems = [
            ...current.data.sections.first.items,
            ...newData.sections.first.items,
          ];

          final updatedSection = SectionModel(
            title: current.data.sections.first.title,
            type: current.data.sections.first.type,
            items: updatedItems,
          );
   // recent prducat will be show only populr battery section 
          final updatedData = HomeDataModel(
            brands: current.data.brands,
            banners: current.data.banners,
            sections: [updatedSection],
            pagination: newData.pagination,
          );

          emit(
            HomeLoaded(
              updatedData,
              selectedType: current.selectedType,
              isFetchingMore: false,
              hasReachedMax:
                  newData.pagination.page >= newData.pagination.pages,
            ),
          );
        }
      } catch (e) {
        emit(current.copyWith(isFetchingMore: false));
      }
    }
  }
}
