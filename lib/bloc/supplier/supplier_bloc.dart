import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/supplier/supplier_event.dart';
import 'package:sereports/bloc/supplier/supplier_state.dart';
import 'package:sereports/repository/supplier_repo.dart';

class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierRepo supplierRepo;

  SupplierBloc({required this.supplierRepo}) : super(SupplierInitial()) {
    on<LoadSuppliers>(_onLoadSuppliers);
    on<SelectSupplier>(_onSelectSupplier);
  }

  Future<void> _onLoadSuppliers(
    LoadSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    // If we're already in a loaded state, set isSearching to true
    if (state is SupplierLoaded) {
      emit((state as SupplierLoaded).copyWith(isSearching: true));
    } else {
      emit(SupplierLoading());
    }

    try {
      final suppliers = await supplierRepo.getSupplierNameList(
        searchText: event.searchText,
      );

      List<Map<String, dynamic>> supplierList = [];

      // Add "All" option at the beginning
      supplierList.add({
        'code': '',
        'name': 'All',
      });

      // Add the rest of the suppliers
      for (var supplier in suppliers) {
        supplierList.add({
          'code': supplier['code'],
          'name': supplier['name'],
        });
      }

      // If we're coming from SupplierLoaded state, preserve the selected supplier
      if (state is SupplierLoaded) {
        final currentState = state as SupplierLoaded;
        emit(SupplierLoaded(
          suppliers: supplierList,
          selectedSupplierCode: currentState.selectedSupplierCode,
          selectedSupplierName: currentState.selectedSupplierName,
          isSearching: false, // Search complete
        ));
      } else {
        emit(SupplierLoaded(
          suppliers: supplierList,
          isSearching: false, // Search complete
        ));
      }
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  void _onSelectSupplier(
    SelectSupplier event,
    Emitter<SupplierState> emit,
  ) {
    if (state is SupplierLoaded) {
      final currentState = state as SupplierLoaded;
      emit(currentState.copyWith(
        selectedSupplierCode: event.supplierCode,
        selectedSupplierName: event.supplierName,
      ));
    }
  }
}
