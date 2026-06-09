// ignore_for_file: prefer_final_fields, unnecessary_to_list_in_spreads, avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';

class ChqRecordsScreen extends StatefulWidget {
  const ChqRecordsScreen({Key? key}) : super(key: key);

  @override
  _ChqRecordsScreenState createState() => _ChqRecordsScreenState();
}

class _ChqRecordsScreenState extends State<ChqRecordsScreen> {
  // Sample data for CHQ's In Hand
  final List<Map<String, dynamic>> chqInHandData = [
    {
      'receivable': '1/21/2024',
      'chqNo': '107642',
      'amount': 0.00,
      'id': 'INV',
      'status': 'PENDING',
      'party': '2K PAINT',
    },
    {
      'receivable': '6/16/2023',
      'chqNo': '000208',
      'amount': 61000.00,
      'id': 'INV',
      'status': 'PENDING',
      'party': 'AYURVEDIC BEAUTY CENTER',
    },
    {
      'receivable': '10/30/2024',
      'chqNo': '103859',
      'amount': 0.00,
      'id': 'INV',
      'status': 'PENDING',
      'party': 'CO-OPERATIVE RURAL BANK',
    },
    {
      'receivable': '1/20/2025',
      'chqNo': '533726',
      'amount': 30000.00,
      'id': 'INV',
      'status': 'PENDING',
      'party': '400 COMMUNICATION',
    },
    // Additional sample data
    {
      'receivable': '2/15/2024',
      'chqNo': '107699',
      'amount': 12500.00,
      'id': 'INV',
      'status': 'PENDING',
      'party': 'ABC SUPPLIES',
    },
    {
      'receivable': '3/22/2024',
      'chqNo': '108042',
      'amount': 8750.50,
      'id': 'INV',
      'status': 'PENDING',
      'party': 'XYZ CORPORATION',
    },
  ];

  int _rowsPerPage = 5;
  int _currentPage = 0;

  int get _startIndex => _currentPage * _rowsPerPage;
  int get _endIndex => (_startIndex + _rowsPerPage) > chqInHandData.length
      ? chqInHandData.length
      : (_startIndex + _rowsPerPage);
  int get _pageCount => (chqInHandData.length / _rowsPerPage).ceil();

  List<Map<String, dynamic>> get _currentPageData =>
      chqInHandData.sublist(_startIndex, _endIndex);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CHQ's In Hand Section
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radiusValue)),
            child: Container(
              // Fixed width similar to the image
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    // Similar to the teal color in the image
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: const Color(0xFF4ABED3),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radiusValue),
                            topRight:
                                Radius.circular(radiusValue))), // Teal color
                    child: const Text(
                      "CHQ's In Hand",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Table
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(minWidth: constraints.maxWidth),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Table Header
                              Container(
                                color: const Color(0xFF79B84B), // Green color
                                child: Row(
                                  children: [
                                    _buildHeaderCell('Receivable', 150),
                                    _buildHeaderCell('ChqNo', 150),
                                    _buildHeaderCell('Amount', 150),
                                    _buildHeaderCell('ID', 100),
                                    _buildHeaderCell('Status', 150),
                                    _buildHeaderCell('Party', 250),
                                  ],
                                ),
                              ),

                              // Table Data
                              ..._currentPageData
                                  .map((item) => _buildDataRow(item))
                                  .toList(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Pagination Controls
                  if (chqInHandData.length > _rowsPerPage)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: _currentPage > 0
                                ? () => setState(() => _currentPage--)
                                : null,
                          ),
                          Text(
                            'Page ${_currentPage + 1} of $_pageCount',
                            style: const TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: _currentPage < _pageCount - 1
                                ? () => setState(() => _currentPage++)
                                : null,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDataRow(Map<String, dynamic> item) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildDataCell(item['receivable'].toString(), 150),
          _buildDataCell(item['chqNo'].toString(), 150),
          _buildDataCell(item['amount'].toInt().toString(), 150),
          _buildDataCell(item['id'].toString(), 100, color: Colors.blue),
          _buildDataCell(item['status'].toString(), 150),
          _buildDataCell(item['party'].toString(), 250),
        ],
      ),
    );
  }

  Widget _buildDataCell(String text, double width, {Color? color}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: color,
        ),
      ),
    );
  }
}

// Alternative: Responsive table using DataTable widget
class ResponsiveDataTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ResponsiveDataTable({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Receivable')),
          DataColumn(label: Text('ChqNo')),
          DataColumn(label: Text('Amount')),
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Party')),
        ],
        rows: data
            .map((item) => DataRow(
                  cells: [
                    DataCell(Text(item['receivable'].toString())),
                    DataCell(Text(item['chqNo'].toString())),
                    DataCell(Text(item['amount'].toInt().toString())),
                    DataCell(Text(
                      item['id'].toString(),
                      style: const TextStyle(color: Colors.blue),
                    )),
                    DataCell(Text(item['status'].toString())),
                    DataCell(Text(item['party'].toString())),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
