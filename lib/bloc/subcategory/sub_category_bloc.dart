import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/subcategory/sub_category_event.dart';
import 'package:sereports/bloc/subcategory/sub_category_state.dart';
import 'package:sereports/repository/sub_category_repo.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryRepo subCategoryRepo;

  SubCategoryBloc({required this.subCategoryRepo})
      : super(SubCategoryInitial()) {
    on<LoadSubCategories>(_onLoadSubCategories);
    on<SelectSubCategory>(_onSelectSubCategory);
  }

  Future<void> _onLoadSubCategories(
    LoadSubCategories event,
    Emitter<SubCategoryState> emit,
  ) async {
    // If we're already in a loaded state, set isSearching to true
    if (state is SubCategoryLoaded) {
      emit((state as SubCategoryLoaded).copyWith(isSearching: true));
    } else {
      emit(SubCategoryLoading());
    }

    try {
      final subCategories = await subCategoryRepo.getSubcategorNameList(
        categoryId: event.categoryCode,
        searchText: event.searchText,
      );

      List<Map<String, dynamic>> subCategoryList = [];

      // Add "All" option at the beginning
      subCategoryList.add({
        'code': '',
        'name': 'All',
      });

      // Add the rest of the sub-categories
      for (var subCategory in subCategories) {
        subCategoryList.add({
          'code': subCategory['code'],
          'name': subCategory['name'],
        });
      }

      // If we're coming from SubCategoryLoaded state, preserve the selected sub-category
      if (state is SubCategoryLoaded) {
        final currentState = state as SubCategoryLoaded;
        emit(SubCategoryLoaded(
          subCategories: subCategoryList,
          selectedSubCategoryCode: currentState.selectedSubCategoryCode,
          selectedSubCategoryName: currentState.selectedSubCategoryName,
          isSearching: false, // Search complete
        ));
      } else {
        emit(SubCategoryLoaded(
          subCategories: subCategoryList,
          isSearching: false, // Search complete
        ));
      }
    } catch (e) {
      emit(SubCategoryError(e.toString()));
    }
  }

  void _onSelectSubCategory(
    SelectSubCategory event,
    Emitter<SubCategoryState> emit,
  ) {
    if (state is SubCategoryLoaded) {
      final currentState = state as SubCategoryLoaded;
      emit(currentState.copyWith(
        selectedSubCategoryCode: event.subCategoryCode,
        selectedSubCategoryName: event.subCategoryName,
      ));
    }
  }
}
