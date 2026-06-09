import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/category/category_event.dart';
import 'package:sereports/bloc/category/category_state.dart';
import 'package:sereports/repository/category_repo.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepo categoryRepo;

  CategoryBloc({required this.categoryRepo}) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<SelectCategory>(_onSelectCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    // If we're already in a loaded state, set isSearching to true
    if (state is CategoryLoaded) {
      emit((state as CategoryLoaded).copyWith(isSearching: true));
    } else {
      emit(CategoryLoading());
    }

    try {
      final categories = await categoryRepo.getCategoryNameList(
        searchText: event.searchText,
      );

      List<Map<String, dynamic>> categoryList = [];

      // Add "All" option at the beginning
      categoryList.add({
        'code': '',
        'name': 'All',
      });

      // Add the rest of the categories
      for (var category in categories) {
        categoryList.add({
          'code': category['code'],
          'name': category['name'],
        });
      }

      // If we're coming from CategoryLoaded state, preserve the selected category
      if (state is CategoryLoaded) {
        final currentState = state as CategoryLoaded;
        emit(CategoryLoaded(
          categories: categoryList,
          selectedCategoryCode: currentState.selectedCategoryCode,
          selectedCategoryName: currentState.selectedCategoryName,
          isSearching: false, // Search complete
        ));
      } else {
        emit(CategoryLoaded(
          categories: categoryList,
          isSearching: false, // Search complete
        ));
      }
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<CategoryState> emit,
  ) {
    if (state is CategoryLoaded) {
      final currentState = state as CategoryLoaded;
      emit(currentState.copyWith(
        selectedCategoryCode: event.categoryCode,
        selectedCategoryName: event.categoryName,
      ));
    }
  }
}
