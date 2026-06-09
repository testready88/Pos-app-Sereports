// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/constants.dart';

class PLAccountCard extends StatelessWidget {
  final Map<String, dynamic> salesSummary;
  final Map<String, dynamic> purchaseSummary;
  final Map<String, dynamic> otherIncomeExpense;

  const PLAccountCard({
    Key? key,
    required this.salesSummary,
    required this.purchaseSummary,
    required this.otherIncomeExpense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    // Calculate profit or loss
    final double netSales = salesSummary['netSales'] ?? 0.0;
    final double costSales = salesSummary['costSales'] ?? 0.0;
    final double otherIncome = otherIncomeExpense['otherIncome'] ?? 0.0;
    final double otherExpenses = otherIncomeExpense['otherExpenses'] ?? 0.0;

    final double grossProfit = netSales - costSales;
    final double netProfit = grossProfit + otherIncome - otherExpenses;

    final bool isProfit = netProfit >= 0;
    final Color statusColor = isProfit ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: grayColorForBorader),
        borderRadius: BorderRadius.circular(radiusValue),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusValue),
                topRight: Radius.circular(radiusValue),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profit & Loss Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  isProfit ? 'Profit' : 'Loss',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildRow('Net Sales', formatter.format(netSales)),
                _buildRow('Cost of Sales', formatter.format(costSales)),
                _buildDivider(),
                _buildRow('Gross Profit', formatter.format(grossProfit),
                    isBold: true),
                _buildDivider(),
                _buildRow('Other Income', formatter.format(otherIncome)),
                _buildRow('Other Expenses', formatter.format(otherExpenses)),
                _buildDivider(),
                _buildRow(isProfit ? 'Net Profit' : 'Net Loss',
                    formatter.format(netProfit.abs()),
                    isBold: true, textColor: statusColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: grayColorForBorader,
      thickness: 1.0,
    );
  }
}
