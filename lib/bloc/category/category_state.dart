import 'package:equatable/equatable.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object> get props => [];
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

// In category_state.dart
class CategoryLoaded extends CategoryState {
  final List<Map<String, dynamic>> categories;
  final String selectedCategoryCode;
  final String selectedCategoryName;
  final bool isSearching;

  const CategoryLoaded({
    required this.categories,
    this.selectedCategoryCode = '',
    this.selectedCategoryName = 'All',
    this.isSearching = false,
  });

  @override
  List<Object> get props =>
      [categories, selectedCategoryCode, selectedCategoryName, isSearching];

  CategoryLoaded copyWith({
    List<Map<String, dynamic>>? categories,
    String? selectedCategoryCode,
    String? selectedCategoryName,
    bool? isSearching,
  }) {
    return CategoryLoaded(
      categories: categories ?? this.categories,
      selectedCategoryCode: selectedCategoryCode ?? this.selectedCategoryCode,
      selectedCategoryName: selectedCategoryName ?? this.selectedCategoryName,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
