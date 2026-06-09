import 'package:big_decimal/big_decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:sereports/model/invoiceitem.dart';

abstract class InvoiceCreationState extends Equatable {
  const InvoiceCreationState();

  @override
  List<Object?> get props => [];
}

class InvoiceCreationInitial extends InvoiceCreationState {}

class InvoiceCreationReady extends InvoiceCreationState {
  final String customerCode;
  final String customerName;
  final List<InvoiceItem> items;
  final BigDecimal grandTotal;
  final bool isLoading;

  const InvoiceCreationReady({
    required this.customerCode,
    required this.customerName,
    required this.items,
    required this.grandTotal,
    this.isLoading = false,
  });

  @override
  List<Object?> get props =>
      [customerCode, customerName, items, grandTotal, isLoading];

  InvoiceCreationReady copyWith({
    String? customerCode,
    String? customerName,
    List<InvoiceItem>? items,
    BigDecimal? grandTotal,
    bool? isLoading,
  }) {
    return InvoiceCreationReady(
      customerCode: customerCode ?? this.customerCode,
      customerName: customerName ?? this.customerName,
      items: items ?? this.items,
      grandTotal: grandTotal ?? this.grandTotal,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ItemLoading extends InvoiceCreationState {}

class ItemLoaded extends InvoiceCreationState {
  final InvoiceItem item;

  const ItemLoaded(this.item);

  @override
  List<Object?> get props => [item];
}

class ItemsSearching extends InvoiceCreationState {}

class ItemsSearchLoaded extends InvoiceCreationState {
  final List<Map<String, dynamic>> items;

  const ItemsSearchLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class InvoiceSubmitting extends InvoiceCreationState {}

class InvoiceSubmitSuccess extends InvoiceCreationState {
  final String invoiceNo;
  final String serialNo;
  final bool isSynced;

  const InvoiceSubmitSuccess({
    required this.invoiceNo,
    required this.serialNo,
    required this.isSynced,
  });

  @override
  List<Object?> get props => [invoiceNo, serialNo, isSynced];
}

class InvoiceCreationError extends InvoiceCreationState {
  final String message;

  const InvoiceCreationError(this.message);

  @override
  List<Object?> get props => [message];
}

class SyncInProgress extends InvoiceCreationState {
  final int total;
  final int synced;

  const SyncInProgress({required this.total, required this.synced});

  @override
  List<Object?> get props => [total, synced];
}

class SyncComplete extends InvoiceCreationState {
  final int successCount;
  final int failureCount;

  const SyncComplete({
    required this.successCount,
    required this.failureCount,
  });

  @override
  List<Object?> get props => [successCount, failureCount];
}
