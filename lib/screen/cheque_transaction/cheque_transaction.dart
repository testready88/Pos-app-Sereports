import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';

class ChequeTransaction extends StatefulWidget {
  const ChequeTransaction({super.key});

  @override
  State<ChequeTransaction> createState() => _ChequeTransactionState();
}

class _ChequeTransactionState extends State<ChequeTransaction> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedInvGap = "All";
  String selectedSettlementGap = "All";

  final List<Map<String, dynamic>> products = [
    {
      'Loca': '1',
      'StockId': 'SHOP',
      'ID': '2964',
      'ItemName': 'PROCESSOR I3 3RD GEN',
      'Quantity': 1,
      'U.Price': 1450,
      'MRP': 3500.00,
      'D.Price': 2750.00,
      'Category': 'Processor',
      'supplier': 'WARA CAPITAL PVT LTD',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      key: _scaffoldKey,
      drawer: AppDrawer(),
      appBar: Appbar(scaffoldKey: _scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8),
              child: SizedBox(
                height: 45,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'CHQ No',
                    hintStyle: TextStyle(color: grayColorForHintText),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                        onPressed: () {
                          showSummaryBottomSheet(context);
                        },
                        icon: Icon(Icons.filter_list)),
                    enabledBorder: kDefaultInputBorder,
                    focusedBorder: kDefaultFocusInputBorder,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFD8A713),
                borderRadius: BorderRadius.circular(radiusValue),
              ),
              child: Text(
                "Payable : 130,955.00 | Recaivable : 1,955.00 | Party CHQ : 129,000.00",
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: _buildProductCard(product),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String label) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(color: grayColorForBorader),
          borderRadius: BorderRadius.circular(radiusValue),
        ),
        child: DropdownMenuItem<String>(
          value: "Select Sub Category",
          child: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text("loading..."),
            ],
          ),
        ));
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(radiusValue),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          _buildProductDetail('Loca', product['Loca']),
          _buildProductDetail('StockId', product['StockId'].toString()),
          _buildProductDetail('ID', product['ID'].toString()),
          _buildProductDetail('ItemName', product['ItemName'].toString()),
          _buildProductDetail('Quantity', product['Quantity'].toString()),
          _buildProductDetail('U.Price', product['U.Price'].toString()),
          _buildProductDetail('MRP', product['MRP'].toString()),
          _buildProductDetail('Category', product['Category'].toString()),
          const SizedBox(height: 8),
          _buildProductDetail('Supplier', product['supplier']),
        ],
      ),
    );
  }

  Widget _buildProductDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF444444),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF222222),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void showSummaryBottomSheet(BuildContext context) {
    String selectedLocation = "All";
    String formatDate(DateTime? date) {
      return date != null
          ? DateFormat('yyyy-MM-dd').format(date)
          : "Select date";
    }

    DateTime? startDate;
    DateTime? endDate;
    void selectDate(BuildContext context, bool isStartDate) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );

      if (pickedDate != null) {
        setState(() {
          if (isStartDate) {
            startDate = pickedDate;
          } else {
            endDate = pickedDate;
          }
        });
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusValue)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(radiusValue)),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Location',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: grayColorForBorader),
                    borderRadius: BorderRadius.circular(radiusValue),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedLocation,
                      items: location.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedLocation = newValue!;
                        });
                      },
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Reference',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 45,
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Reference',
                      hintStyle: TextStyle(color: grayColorForHintText),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: kDefaultInputBorder,
                      focusedBorder: kDefaultFocusInputBorder,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text('Bank ID/Ac No',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildFilterDropdown('Income/Expenses'),
                const SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date From:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => selectDate(context, true),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              height: 45,
                              decoration: BoxDecoration(
                                border: Border.all(color: grayColorForBorader),
                                borderRadius:
                                    BorderRadius.circular(radiusValue),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatDate(startDate),
                                      style: TextStyle(color: Colors.black)),
                                  const Icon(Icons.calendar_today,
                                      color: grayColorForBorader),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date To:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => selectDate(context, false),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              height: 45,
                              decoration: BoxDecoration(
                                border: Border.all(color: grayColorForBorader),
                                borderRadius:
                                    BorderRadius.circular(radiusValue),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(formatDate(endDate),
                                      style: TextStyle(color: Colors.black)),
                                  const Icon(Icons.calendar_today,
                                      color: grayColorForBorader),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
