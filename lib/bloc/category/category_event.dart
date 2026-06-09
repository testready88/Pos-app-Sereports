import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String searchText;

  const LoadCategories({this.searchText = ''});

  @override
  List<Object> get props => [searchText];
}

class SelectCategory extends CategoryEvent {
  final String categoryCode;
  final String categoryName;

  const SelectCategory(
      {required this.categoryCode, required this.categoryName});

  @override
  List<Object> get props => [categoryCode, categoryName];
}
