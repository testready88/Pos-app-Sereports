// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';

import 'package:sereports/bloc/product/product_event.dart';
import 'package:sereports/bloc/product/product_state.dart';
import 'package:sereports/repository/product_repo.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepo productRepo;
  final int pageSize = 10;

  ProductBloc({required this.productRepo}) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadMoreProducts>(_onLoadMoreProducts);
    on<ApplyFilters>(_onApplyFilters);
    on<SearchProduct>(_onSearchProduct);
  }

  Future<void> _onLoadProducts(
      LoadProducts event, Emitter<ProductState> emit) async {
    try {
      if (state is ProductLoaded && !event.refresh) {
        return;
      }

      emit(ProductLoading());

      Map<String, String> filters = {};
      if (state is ProductLoaded) {
        filters = (state as ProductLoaded).filters;
      }

      final products = await _fetchProducts(0, filters);

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < pageSize,
        currentPage: 0,
        filters: filters,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onLoadMoreProducts(
      LoadMoreProducts event, Emitter<ProductState> emit) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      if (currentState.hasReachedMax) return;

      try {
        final nextPage = currentState.currentPage + 1;
        final newProducts =
            await _fetchProducts(nextPage, currentState.filters);

        if (newProducts.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true));
        } else {
          emit(
            currentState.copyWith(
              products: [...currentState.products, ...newProducts],
              currentPage: nextPage,
              hasReachedMax: newProducts.length < pageSize,
            ),
          );
        }
      } catch (e) {
        emit(ProductError(e.toString()));
      }
    }
  }

  Future<void> _onApplyFilters(
      ApplyFilters event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    Map<String, String> filters = {};

    if (event.searchProduct != null)
      filters['searchProduct'] = event.searchProduct!;
    if (event.categoryName != null && event.categoryName != 'All')
      filters['categoryName'] = event.categoryName!;
    if (event.subCategoryName != null && event.subCategoryName != 'All')
      filters['subCategoryName'] = event.subCategoryName!;
    if (event.supplierName != null && event.supplierName != 'All')
      filters['supplierName'] = event.supplierName!;
    if (event.stockLevel != null && event.stockLevel != 'All')
      filters['stockLevel'] = event.stockLevel!;
    if (event.itemSaleType != null && event.itemSaleType != 'All')
      filters['itemSaleType'] = event.itemSaleType!;

    try {
      final products = await _fetchProducts(0, filters);

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < pageSize,
        currentPage: 0,
        filters: filters,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProduct(
      SearchProduct event, Emitter<ProductState> emit) async {
    Map<String, String> filters = {};

    if (state is ProductLoaded) {
      filters = Map.from((state as ProductLoaded).filters);
    }

    filters['searchProduct'] = event.searchTerm;

    emit(ProductLoading());

    try {
      final products = await _fetchProducts(0, filters);

      emit(ProductLoaded(
        products: products,
        hasReachedMax: products.length < pageSize,
        currentPage: 0,
        filters: filters,
      ));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<List<dynamic>> _fetchProducts(
      int page, Map<String, String> filters) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'size': pageSize,
      ...filters,
    };
    final products = await productRepo.getAllProduct(searchqueryParams: queryParams);
    
    // Deduplicate products by itemCode + itemBarcode to avoid duplicates from different compId
    // This matches VB6 logic where items are unique by ItemCode
    final Map<String, dynamic> uniqueProducts = {};
    for (var product in products) {
      final itemCode = product['itemCode']?.toString() ?? '';
      final itemBarcode = product['itemBarcode']?.toString() ?? '';
      final key = '$itemCode|$itemBarcode';
      
      // Keep the first occurrence (or prefer the one with higher qtyRemain)
      if (!uniqueProducts.containsKey(key)) {
        uniqueProducts[key] = product;
      } else {
        // If duplicate, prefer the one with higher qtyRemain
        final existing = uniqueProducts[key];
        final existingQty = (existing['qtyRemain'] as num?) ?? 0;
        final newQty = (product['qtyRemain'] as num?) ?? 0;
        if (newQty > existingQty) {
          uniqueProducts[key] = product;
        }
      }
    }
    
    return uniqueProducts.values.toList();
  }
}
