import 'package:equatable/equatable.dart';

abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

// In sub_category_state.dart
class SubCategoryLoaded extends SubCategoryState {
  final List<Map<String, dynamic>> subCategories;
  final String selectedSubCategoryCode;
  final String selectedSubCategoryName;
  final bool isSearching;

  const SubCategoryLoaded({
    required this.subCategories,
    this.selectedSubCategoryCode = '',
    this.selectedSubCategoryName = 'All',
    this.isSearching = false,
  });

  @override
  List<Object> get props => [
        subCategories,
        selectedSubCategoryCode,
        selectedSubCategoryName,
        isSearching
      ];

  SubCategoryLoaded copyWith({
    List<Map<String, dynamic>>? subCategories,
    String? selectedSubCategoryCode,
    String? selectedSubCategoryName,
    bool? isSearching,
  }) {
    return SubCategoryLoaded(
      subCategories: subCategories ?? this.subCategories,
      selectedSubCategoryCode:
          selectedSubCategoryCode ?? this.selectedSubCategoryCode,
      selectedSubCategoryName:
          selectedSubCategoryName ?? this.selectedSubCategoryName,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SubCategoryError extends SubCategoryState {
  final String message;

  const SubCategoryError(this.message);

  @override
  List<Object> get props => [message];
}
