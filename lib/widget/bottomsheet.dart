// bottomsheet.dart - Enhanced version with support for different card types

// ignore_for_file: unreachable_switch_default, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Card types enum to identify different bottom sheets
enum FinancialCardType {
  netSales,
  netProfit,
  netPurchase,
  otherIncome,
  otherExpenses,
  stockValue,
}

// Generic bottom sheet function that displays different content based on the card type
void showFinancialDetailBottomSheet(
  BuildContext context, {
  required String title,
  required FinancialCardType cardType,
  required Map<String, dynamic> data,
  Color color = Colors.blue,
}) {
  final formatter = NumberFormat("#,##0.00", "en_US");

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: color),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content based on card type
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: _buildContentBasedOnCardType(cardType, data, formatter),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Helper method to build content based on card type
Widget _buildContentBasedOnCardType(
  FinancialCardType cardType,
  Map<String, dynamic> data,
  NumberFormat formatter,
) {
  switch (cardType) {
    case FinancialCardType.netSales:
      return _buildNetSalesContent(data, formatter);

    case FinancialCardType.netProfit:
      return _buildNetProfitContent(data, formatter);

    case FinancialCardType.netPurchase:
      return _buildNetPurchaseContent(data, formatter);

    case FinancialCardType.otherIncome:
      return _buildOtherIncomeContent(data, formatter);

    case FinancialCardType.otherExpenses:
      return _buildOtherExpensesContent(data, formatter);

    case FinancialCardType.stockValue:
      return _buildStockValueContent(data, formatter);

    default:
      return Text("Details not available");
  }
}

// Content for Net Sales bottom sheet
Widget _buildNetSalesContent(
    Map<String, dynamic> salesSummary, NumberFormat formatter) {
  return Column(
    children: [
      _buildDetailRow(
          'Total Qty', formatter.format(salesSummary['totalQtySold'] ?? 0.0)),
      _buildDetailRow('Cost Of Sales Rs',
          formatter.format(salesSummary['costSales'] ?? 0.0)),
      _buildDetailRow('Gross Sales Rs',
          formatter.format(salesSummary['grossSales'] ?? 0.0)),
      _buildDetailRow('Cash Discount Rs',
          formatter.format(salesSummary['cashDiscount'] ?? 0.0)),
      _buildDetailRow('Item Discount Rs',
          formatter.format(salesSummary['itemDiscount'] ?? 0.0)),
      _buildDetailRow('Points Redeem Rs',
          formatter.format(salesSummary['pointsRedeem'] ?? 0.0)),
      _buildDetailRow('Extra Charges Rs',
          formatter.format(salesSummary['exCharges'] ?? 0.0)),
    ],
  );
}

// Content for Net Profit bottom sheet
Widget _buildNetProfitContent(
    Map<String, dynamic> salesSummary, NumberFormat formatter) {
  final double profitBeforeDiscount =
      salesSummary['profitBeforeDiscount'] ?? 0.0;
  final double profitAfterDiscount = salesSummary['profitAfterDiscount'] ?? 0.0;

  // Calculate profit by sales type
  // Note: This is an approximation - you might need to adjust based on your actual calculation logic
  final double totalSales = (salesSummary['cashPayment'] ?? 0.0) +
      (salesSummary['creditPayment'] ?? 0.0) +
      (salesSummary['cardPayment'] ?? 0.0) +
      (salesSummary['chqPayment'] ?? 0.0);

  double profitByType(double amount) {
    if (totalSales == 0) return 0;
    return (amount / totalSales) * profitAfterDiscount;
  }

  return Column(
    children: [
      _buildDetailRow(
          'Profit B/F Discount Rs', formatter.format(profitBeforeDiscount)),
      Divider(height: 30, thickness: 1),
      _buildDetailRow('Profit By Cash Sales Rs',
          formatter.format(profitByType(salesSummary['cashPayment'] ?? 0.0))),
      _buildDetailRow('Profit By Credit Sales Rs',
          formatter.format(profitByType(salesSummary['creditPayment'] ?? 0.0))),
      _buildDetailRow('Profit By Card Sales Rs',
          formatter.format(profitByType(salesSummary['cardPayment'] ?? 0.0))),
      _buildDetailRow('Profit By CHQ Sales Rs',
          formatter.format(profitByType(salesSummary['chqPayment'] ?? 0.0))),
      Divider(height: 30, thickness: 1),
      _buildDetailRow('Cash Sales Rs',
          formatter.format(salesSummary['cashPayment'] ?? 0.0)),
      _buildDetailRow('Credit Sales Rs',
          formatter.format(salesSummary['creditPayment'] ?? 0.0)),
      _buildDetailRow('Card Sales Rs',
          formatter.format(salesSummary['cardPayment'] ?? 0.0)),
      _buildDetailRow(
          'CHQ Sales Rs', formatter.format(salesSummary['chqPayment'] ?? 0.0)),
    ],
  );
}

// Content for Net Purchase bottom sheet
Widget _buildNetPurchaseContent(
    Map<String, dynamic> purchaseSummary, NumberFormat formatter) {
  return Column(
    children: [
      _buildDetailRow(
          'Total Qty', formatter.format(purchaseSummary['totalQtyPur'] ?? 0.0)),
      _buildDetailRow('Gross Purchase Rs',
          formatter.format(purchaseSummary['grossPurchase'] ?? 0.0)),
      _buildDetailRow('Line Discount Rs',
          formatter.format(purchaseSummary['itemDiscountPur'] ?? 0.0)),
      _buildDetailRow('Cash Discount Rs',
          formatter.format(purchaseSummary['cashDiscountPur'] ?? 0.0)),
      _buildDetailRow('Transport Charge Rs',
          formatter.format(purchaseSummary['transportCharge'] ?? 0.0)),
      _buildDetailRow('Labour Charge Rs',
          formatter.format(purchaseSummary['labourCharge'] ?? 0.0)),
    ],
  );
}

// Content for Other Income bottom sheet
Widget _buildOtherIncomeContent(
    Map<String, dynamic> otherIncomeExpense, NumberFormat formatter) {
  return Column(
    children: [
      _buildDetailRow('Other Income Total',
          formatter.format(otherIncomeExpense['otherIncome'] ?? 0.0),
          isBold: true),
      _buildDetailRow('Cash Payment',
          formatter.format(otherIncomeExpense['cashPaymentInc'] ?? 0.0)),

      // Add more income details here if available
    ],
  );
}

// Content for Other Expenses bottom sheet
Widget _buildOtherExpensesContent(
    Map<String, dynamic> otherIncomeExpense, NumberFormat formatter) {
  return Column(
    children: [
      _buildDetailRow('Other Expenses Total',
          formatter.format(otherIncomeExpense['otherExpenses'] ?? 0.0),
          isBold: true),
      _buildDetailRow('Cash Payment',
          formatter.format(otherIncomeExpense['cashPaymentExp'] ?? 0.0)),

      // Add more expense details here if available
    ],
  );
}

// Content for Stock Value bottom sheet
Widget _buildStockValueContent(
    Map<String, dynamic> stockSummary, NumberFormat formatter) {
  return Column(
    children: [
      _buildDetailRow('Quantity Remaining',
          formatter.format(stockSummary['qtyRemain'] ?? 0.0)),
      _buildDetailRow(
          'Cost Value', formatter.format(stockSummary['costValue'] ?? 0.0),
          isBold: true),
      _buildDetailRow(
          'Sales Value', formatter.format(stockSummary['salesValue'] ?? 0.0)),

      Divider(height: 30, thickness: 1),

      // Calculate potential profit
      _buildDetailRow(
        'Potential Profit',
        formatter.format((stockSummary['salesValue'] ?? 0.0) -
            (stockSummary['costValue'] ?? 0.0)),
        textColor: Colors.green,
      ),
    ],
  );
}

// Helper to build a detail row
Widget _buildDetailRow(String label, String value,
    {bool isBold = false, Color? textColor}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: textColor,
          ),
        ),
      ],
    ),
  );
}
