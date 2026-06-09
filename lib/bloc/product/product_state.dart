abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<dynamic> products;
  final bool hasReachedMax;
  final int currentPage;
  final Map<String, String> filters;

  ProductLoaded({
    required this.products,
    required this.hasReachedMax,
    required this.currentPage,
    required this.filters,
  });

  ProductLoaded copyWith({
    List<Map<String, dynamic>>? products,
    bool? hasReachedMax,
    int? currentPage,
    Map<String, String>? filters,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      filters: filters ?? this.filters,
    );
  }
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
