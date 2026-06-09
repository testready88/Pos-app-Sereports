import 'package:equatable/equatable.dart';

abstract class SubCategoryEvent extends Equatable {
  const SubCategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSubCategories extends SubCategoryEvent {
  final String categoryCode;
  final String searchText;

  const LoadSubCategories({
    this.categoryCode = '',
    this.searchText = '',
  });

  @override
  List<Object> get props => [categoryCode, searchText];
}

class SelectSubCategory extends SubCategoryEvent {
  final String subCategoryCode;
  final String subCategoryName;

  const SelectSubCategory({
    required this.subCategoryCode,
    required this.subCategoryName,
  });

  @override
  List<Object> get props => [subCategoryCode, subCategoryName];
}
