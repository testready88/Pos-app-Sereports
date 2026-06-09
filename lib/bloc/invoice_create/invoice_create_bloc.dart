import 'package:big_decimal/big_decimal.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_event.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_state.dart';
import 'package:sereports/model/invoiceitem.dart';
import 'package:sereports/repository/invoice_create_repo.dart';

class InvoiceCreationBloc
    extends Bloc<InvoiceCreationEvent, InvoiceCreationState> {
  final InvoiceRepository repository;
  final Connectivity connectivity;

  String _customerCode = '';
  String _customerName = '';
  List<InvoiceItem> _items = [];
  String _locaCode = '';
  String _stockId = '';

  InvoiceCreationBloc({
    required this.repository,
    required this.connectivity,
  }) : super(InvoiceCreationInitial()) {
    on<InitializeInvoiceCreation>(_onInitializeInvoiceCreation);
    on<LoadItemByBarcode>(_onLoadItemByBarcode);
    on<SearchItems>(_onSearchItems);
    on<AddItemToInvoice>(_onAddItemToInvoice);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RemoveItemFromInvoice>(_onRemoveItemFromInvoice);
    on<SubmitInvoice>(_onSubmitInvoice);
    on<SaveAndHoldInvoice>(_onSaveAndHoldInvoice);
    on<SyncPendingInvoices>(_onSyncPendingInvoices);
    on<ClearInvoice>(_onClearInvoice);
  }

  /// Calculate grand total of all items
  BigDecimal _calculateGrandTotal() {
    return _items.fold(
      BigDecimal.zero,
      (total, item) => total + (item.tPrice),
    );
  }

  Future<void> _onInitializeInvoiceCreation(
    InitializeInvoiceCreation event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      // Only update customer info, don't clear items
      _customerCode = event.customerCode;
      _customerName = event.customerName;
      // Keep existing items - don't clear them: _items = [];

      // If we have existing items, preserve them; otherwise start fresh
      final currentItems = (state is InvoiceCreationReady) 
          ? (state as InvoiceCreationReady).items 
          : _items;

      emit(InvoiceCreationReady(
        customerCode: _customerCode,
        customerName: _customerName,
        items: currentItems,
        grandTotal: currentItems.isEmpty 
            ? BigDecimal.zero 
            : currentItems.fold(BigDecimal.zero, (sum, item) => sum + item.tPrice),
      ));
    } catch (e) {
      print('Error initializing invoice: $e');
      emit(InvoiceCreationError(
          'Failed to initialize invoice: ${e.toString()}'));
    }
  }

  Future<void> _onLoadItemByBarcode(
    LoadItemByBarcode event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      emit(ItemLoading());
      _locaCode = event.barcode;
      _stockId = event.barcode;

      final item = await repository.getItemByBarcode(
        event.barcode,
        _locaCode,
        _stockId,
      );

      emit(ItemLoaded(item));
    } catch (e) {
      print('Error loading item: $e');
      emit(InvoiceCreationError('Failed to load item: ${e.toString()}'));

      // Restore previous state
      if (state is InvoiceCreationReady) {
        emit(state as InvoiceCreationReady);
      }
    }
  }

  Future<void> _onSearchItems(
    SearchItems event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      emit(ItemsSearching());

      final results = await repository.searchItems(
        searchTerm: event.searchTerm,
        barcode: event.barcode,
        stockId: event.stockId,
        locaCode: event.locaCode,
      );

      emit(ItemsSearchLoaded(results));
    } catch (e) {
      print('Error searching items: $e');
      emit(InvoiceCreationError('Failed to search items: ${e.toString()}'));

      // Restore previous state
      if (state is InvoiceCreationReady) {
        emit(state as InvoiceCreationReady);
      }
    }
  }

  Future<void> _onAddItemToInvoice(
    AddItemToInvoice event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      _items.add(event.item);

      if (state is InvoiceCreationReady) {
        emit((state as InvoiceCreationReady).copyWith(
          items: List.from(_items),
          grandTotal: _calculateGrandTotal(),
        ));
      }
    } catch (e) {
      print('Error adding item: $e');
      emit(InvoiceCreationError('Failed to add item: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      if (event.itemIndex >= 0 && event.itemIndex < _items.length) {
        final item = _items[event.itemIndex];

        // Get item price as BigDecimal
        final itemPrice = item.itemDPrice;

        final newTPrice = itemPrice * BigDecimal.parse(event.newQty.toString());

        // Create updated item with new quantity and total price
        _items[event.itemIndex] = item.copyWith(
          qty: event.newQty,
          tPrice: newTPrice,
        );

        // Emit updated state
        if (state is InvoiceCreationReady) {
          emit((state as InvoiceCreationReady).copyWith(
            items: List.from(_items),
            grandTotal: _calculateGrandTotal(),
          ));
        }
      }
    } catch (e) {
      print('Error updating quantity: $e');
      emit(InvoiceCreationError('Failed to update quantity: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveItemFromInvoice(
    RemoveItemFromInvoice event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      if (event.itemIndex >= 0 && event.itemIndex < _items.length) {
        _items.removeAt(event.itemIndex);

        if (state is InvoiceCreationReady) {
          emit((state as InvoiceCreationReady).copyWith(
            items: List.from(_items),
            grandTotal: _calculateGrandTotal(),
          ));
        }
      }
    } catch (e) {
      print('Error removing item: $e');
      emit(InvoiceCreationError('Failed to remove item: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitInvoice(
    SubmitInvoice event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    if (_items.isEmpty) {
      emit(const InvoiceCreationError('Invoice must have at least one item'));
      return;
    }

    try {
      emit(InvoiceSubmitting());

      final grandTotal = _calculateGrandTotal();

      final response = await repository.createInvoice(
        customerCode: _customerCode,
        customerName: _customerName,
        locaCode: event.locaCode,
        unitNo: event.unitNo,
        compId: event.compId,
        invType: event.invType,
        items: _items,
        grandTotal: grandTotal,
        paymentType: event.paymentType,
        cashPaid: event.cashPaid,
        cardPaid: event.cardPaid,
        creditPaid: event.creditPaid,
        bankTransferPaid: event.bankTransferPaid,
        chequePayment: event.chequePayment,
        cardPayment: event.cardPayment,
        bankTransfer: event.bankTransfer,
      );

      final isSynced = response['isSynced'] ?? false;

      emit(InvoiceSubmitSuccess(
        invoiceNo: response['invoiceNo'] ?? 'N/A',
        serialNo: response['serialNo'] ?? 'N/A',
        isSynced: isSynced,
      ));

      // Clear items after successful submission
      _items = [];
    } catch (e) {
      print('Error submitting invoice: $e');
      emit(InvoiceCreationError('Failed to submit invoice: ${e.toString()}'));
    }
  }

  Future<void> _onSaveAndHoldInvoice(
    SaveAndHoldInvoice event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    if (_items.isEmpty) {
      emit(const InvoiceCreationError('Invoice must have at least one item'));
      return;
    }

    try {
      emit(InvoiceSubmitting());

      final grandTotal = _calculateGrandTotal();

      final response = await repository.saveAndHoldInvoice(
        customerCode: _customerCode,
        customerName: _customerName,
        items: _items,
        grandTotal: grandTotal,
      );

      emit(InvoiceSubmitSuccess(
        invoiceNo: response['invoiceNo'] ?? 'HELD-${DateTime.now().millisecondsSinceEpoch}',
        serialNo: response['serialNo'] ?? 'HELD-${DateTime.now().millisecondsSinceEpoch}',
        isSynced: false, // Held invoices are not synced until completed
      ));

      // Clear items after successful hold
      _items = [];
    } catch (e) {
      print('Error saving and holding invoice: $e');
      emit(InvoiceCreationError('Failed to save and hold invoice: ${e.toString()}'));
    }
  }

  Future<void> _onSyncPendingInvoices(
    SyncPendingInvoices event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      emit(SyncInProgress(total: 1, synced: 0));

      final result = await repository.syncPendingInvoices();

      emit(SyncComplete(
        successCount: result['synced'] ?? 0,
        failureCount: result['failed'] ?? 0,
      ));
    } catch (e) {
      print('Error syncing invoices: $e');
      emit(InvoiceCreationError('Sync failed: ${e.toString()}'));
    }
  }

  Future<void> _onClearInvoice(
    ClearInvoice event,
    Emitter<InvoiceCreationState> emit,
  ) async {
    try {
      _items = [];
      _customerCode = '';
      _customerName = '';
      emit(InvoiceCreationReady(
        customerCode: _customerCode,
        customerName: _customerName,
        items: _items,
        grandTotal: BigDecimal.zero,
      ));
    } catch (e) {
      print('Error clearing invoice: $e');
      emit(InvoiceCreationError('Failed to clear invoice: ${e.toString()}'));
    }
  }
}

extension InvoiceItemCopyWith on InvoiceItem {
  /// Creates a copy of this InvoiceItem with specified fields replaced
  /// Example:
  /// ```dart
  /// final newItem = item.copyWith(qty: 5, tPrice: BigDecimal.from(500));
  /// ```
  InvoiceItem copyWith({
    String? itemCode,
    String? itemBarcode,
    String? itemName,
    String? stockId,
    int? qty,
    BigDecimal? itemUPrice,
    BigDecimal? itemSPrice,
    BigDecimal? itemDPrice,
    BigDecimal? tPrice,
    String? invType,
  }) {
    return InvoiceItem(
      itemCode: itemCode ?? this.itemCode,
      itemBarcode: itemBarcode ?? this.itemBarcode,
      itemName: itemName ?? this.itemName,
      stockId: stockId ?? this.stockId,
      qty: qty ?? this.qty,
      itemUPrice: itemUPrice ?? this.itemUPrice,
      itemSPrice: itemSPrice ?? this.itemSPrice,
      itemDPrice: itemDPrice ?? this.itemDPrice,
      tPrice: tPrice ?? this.tPrice,
      invType: invType ?? this.invType,
    );
  }
}
