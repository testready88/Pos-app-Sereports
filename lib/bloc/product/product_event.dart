abstract class ProductEvent {}

class LoadProducts extends ProductEvent {
  final bool refresh;

  LoadProducts({this.refresh = false});
}

class LoadMoreProducts extends ProductEvent {}

class ApplyFilters extends ProductEvent {
  final String? searchProduct;
  final String? categoryName;
  final String? subCategoryName;
  final String? supplierName;
  final String? stockLevel;
  final String? itemSaleType;

  ApplyFilters({
    this.searchProduct,
    this.categoryName,
    this.subCategoryName,
    this.supplierName,
    this.stockLevel,
    this.itemSaleType,
  });
}

class SearchProduct extends ProductEvent {
  final String searchTerm;

  SearchProduct(this.searchTerm);
}
