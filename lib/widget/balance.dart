// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/constants.dart';

class BalanceSheetCard extends StatelessWidget {
  final Map<String, dynamic> balanceSheet;

  const BalanceSheetCard({
    Key? key,
    required this.balanceSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    // Extract values from balanceSheet
    final double cashInHand = balanceSheet['cashInHand'] ?? 0.0;
    final double amountInBank = balanceSheet['amountInBank'] ?? 0.0;
    final double amountReceivable = balanceSheet['amountReceivable'] ?? 0.0;
    final double chqReceivable = balanceSheet['chqReceivable'] ?? 0.0;
    final double inventory = balanceSheet['inventory'] ?? 0.0;
    final double otherCurrentAsset = balanceSheet['otherCurrentAsset'] ?? 0.0;
    final double totalCurrentAssets = balanceSheet['totalCurrentAssets'] ?? 0.0;
    final double totalFixedAssets = balanceSheet['totalFixedAssets'] ?? 0.0;
    final double totalAssets = balanceSheet['totalAssets'] ?? 0.0;

    final double amountPayable = balanceSheet['amountPayable'] ?? 0.0;
    final double chqPayable = balanceSheet['chqPayable'] ?? 0.0;
    final double advanceReceived = balanceSheet['advanceReceived'] ?? 0.0;
    final double totalCurrentLiabilities =
        balanceSheet['totalCurrentLiabilities'] ?? 0.0;
    final double capital = balanceSheet['capital'] ?? 0.0;
    final double netProfit = balanceSheet['netProfit'] ?? 0.0;
    final double totalLiabilities = balanceSheet['totalLiabilities'] ?? 0.0;

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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radiusValue),
                topRight: Radius.circular(radiusValue),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Balance Sheet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Text(
                    '',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assets',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                _buildRow('Cash in Hand', formatter.format(cashInHand)),
                _buildRow('Amount in Bank', formatter.format(amountInBank)),
                _buildRow(
                    'Amount Receivable', formatter.format(amountReceivable)),
                _buildRow('CHQ Receivable', formatter.format(chqReceivable)),
                _buildRow('Inventory', formatter.format(inventory)),
                _buildRow('Other Current Assets',
                    formatter.format(otherCurrentAsset)),
                _buildDivider(),
                _buildRow('Total Current Assets',
                    formatter.format(totalCurrentAssets),
                    isBold: true),
                _buildRow(
                    'Total Fixed Assets', formatter.format(totalFixedAssets)),
                _buildDivider(),
                _buildRow('Total Assets', formatter.format(totalAssets),
                    isBold: true),
                SizedBox(height: 16),
                Text(
                  'Liabilities',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                _buildRow('Amount Payable', formatter.format(amountPayable)),
                _buildRow('CHQ Payable', formatter.format(chqPayable)),
                _buildRow(
                    'Advance Received', formatter.format(advanceReceived)),
                _buildDivider(),
                _buildRow('Total Current Liabilities',
                    formatter.format(totalCurrentLiabilities),
                    isBold: true),
                _buildRow('Capital', formatter.format(capital)),
                _buildRow('Net Profit', formatter.format(netProfit)),
                _buildDivider(),
                _buildRow(
                    'Total Liabilities', formatter.format(totalLiabilities),
                    isBold: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
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
