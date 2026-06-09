import 'package:big_decimal/big_decimal.dart';
import 'package:equatable/equatable.dart';
import 'package:sereports/model/invoiceitem.dart';
import 'package:sereports/model/cheque_payment_dto.dart';
import 'package:sereports/model/card_payment_dto.dart';
import 'package:sereports/model/bank_transfer_dto.dart';

abstract class InvoiceCreationEvent extends Equatable {
  const InvoiceCreationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeInvoiceCreation extends InvoiceCreationEvent {
  final String customerCode;
  final String customerName;

  const InitializeInvoiceCreation({
    required this.customerCode,
    required this.customerName,
  });

  @override
  List<Object?> get props => [customerCode, customerName];
}

class LoadItemByBarcode extends InvoiceCreationEvent {
  final String barcode;

  const LoadItemByBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class SearchItems extends InvoiceCreationEvent {
  final String? searchTerm;
  final String? barcode;
  final String? stockId;
  final String? locaCode;

  const SearchItems({
    this.searchTerm,
    this.barcode,
    this.stockId,
    this.locaCode,
  });

  @override
  List<Object?> get props => [searchTerm, barcode, stockId, locaCode];
}

class AddItemToInvoice extends InvoiceCreationEvent {
  final InvoiceItem item;

  const AddItemToInvoice(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateItemQuantity extends InvoiceCreationEvent {
  final int itemIndex;
  final int newQty;

  const UpdateItemQuantity({
    required this.itemIndex,
    required this.newQty,
  });

  @override
  List<Object?> get props => [itemIndex, newQty];
}

class RemoveItemFromInvoice extends InvoiceCreationEvent {
  final int itemIndex;

  const RemoveItemFromInvoice(this.itemIndex);

  @override
  List<Object?> get props => [itemIndex];
}

class SubmitInvoice extends InvoiceCreationEvent {
  final String? locaCode; // Optional - backend will use default
  final String? unitNo; // Optional - backend will use default
  final String? compId; // Optional - backend will extract from token
  final String? invType; // Optional - backend will use default
  final String? paymentType;
  final BigDecimal? cashPaid;
  final BigDecimal? cardPaid;
  final BigDecimal? creditPaid;
  final BigDecimal? bankTransferPaid;
  final ChequePaymentDTO? chequePayment;
  final CardPaymentDTO? cardPayment;
  final BankTransferDTO? bankTransfer;

  const SubmitInvoice({
    this.locaCode,
    this.unitNo,
    this.compId,
    this.invType,
    this.paymentType,
    this.cashPaid,
    this.cardPaid,
    this.creditPaid,
    this.bankTransferPaid,
    this.chequePayment,
    this.cardPayment,
    this.bankTransfer,
  });

  @override
  List<Object?> get props => [
        locaCode,
        unitNo,
        compId,
        invType,
        paymentType,
        cashPaid,
        cardPaid,
        creditPaid,
        bankTransferPaid,
        chequePayment,
        cardPayment,
        bankTransfer,
      ];
}

class SyncPendingInvoices extends InvoiceCreationEvent {
  const SyncPendingInvoices();
}

class ClearInvoice extends InvoiceCreationEvent {
  const ClearInvoice();
}

class SaveAndHoldInvoice extends InvoiceCreationEvent {
  const SaveAndHoldInvoice();
}
