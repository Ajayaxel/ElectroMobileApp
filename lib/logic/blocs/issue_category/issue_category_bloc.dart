import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:electro/data/repositories/issue_repository.dart';
import 'package:electro/logic/blocs/issue_category/issue_category_event.dart';
import 'package:electro/logic/blocs/issue_category/issue_category_state.dart';

class IssueCategoryBloc extends Bloc<IssueCategoryEvent, IssueCategoryState> {
  final IssueRepository issueRepository;

  IssueCategoryBloc({required this.issueRepository})
    : super(IssueCategoryInitial()) {
    on<FetchIssueCategories>((event, emit) async {
      emit(IssueCategoryLoading());
      try {
        final categories = await issueRepository.getIssueCategories();
        emit(IssueCategoryLoaded(categories));
      } catch (e) {
        emit(IssueCategoryError(e.toString()));
      }
    });
  }
}
