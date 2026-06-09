import 'package:equatable/equatable.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoading extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Map<String, dynamic>> suppliers;
  final String selectedSupplierCode;
  final String selectedSupplierName;
  final bool isSearching; // Add this flag

  const SupplierLoaded({
    required this.suppliers,
    this.selectedSupplierCode = '',
    this.selectedSupplierName = 'All',
    this.isSearching = false, // Default to false
  });

  @override
  List<Object> get props =>
      [suppliers, selectedSupplierCode, selectedSupplierName, isSearching];

  SupplierLoaded copyWith({
    List<Map<String, dynamic>>? suppliers,
    String? selectedSupplierCode,
    String? selectedSupplierName,
    bool? isSearching,
  }) {
    return SupplierLoaded(
      suppliers: suppliers ?? this.suppliers,
      selectedSupplierCode: selectedSupplierCode ?? this.selectedSupplierCode,
      selectedSupplierName: selectedSupplierName ?? this.selectedSupplierName,
      isSearching: isSearching ?? this.isSearching,
    );
  }
}

class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object> get props => [message];
}
