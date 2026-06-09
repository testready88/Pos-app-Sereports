import 'package:flutter/material.dart';

/// A reusable widget for displaying a compact summary table of accounts.
class AccountSummaryTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> columns;
  final String title;

  const AccountSummaryTable({
    super.key,
    required this.data,
    required this.columns,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text('No summary data', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.indigo)),
        ),
        SizedBox(
          height: 200, // Fixed height for summary to allow ledger to take rest of space
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 40,
                  headingRowHeight: 35,
                  border: TableBorder.all(color: Colors.black, width: 0.5),
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  columns: columns.map((col) {
                    return DataColumn(
                      label: Text(
                        col['label'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  rows: data.map((row) {
                    return DataRow(
                      cells: columns.map((col) {
                        final value = row[col['key']];
                        final isNumeric = col['type'] == 'amount';
                        final key = (col['key'] ?? '').toString();
                        final isDate = key.endsWith('Date') && value is String;
                        return DataCell(
                          Text(
                            isNumeric ? _formatAmount(value) : isDate ? (value.length >= 10 ? value.substring(0, 10) : value) : value.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isNumeric && col['color'] != null ? col['color'] : null,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }
}

/// A reusable widget for the grand totals footer.
class GrandTotalFooter extends StatelessWidget {
  final Map<String, double> totals;
  final String title;

  const GrandTotalFooter({
    super.key,
    required this.totals,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      color: Colors.grey.shade800,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
              ...totals.entries.map((entry) {
                final v = entry.value;
                final formatted = v.toInt().toString();
                return Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '${entry.key}: $formatted',
                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

/// A reusable widget for the detailed ledger table.
class LedgerTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final List<Map<String, dynamic>> columns;
  final String title;
  final void Function(Map<String, dynamic> row)? onRowTap;
  final void Function(List<Map<String, dynamic>>)? onSelectionChanged;

  const LedgerTable({
    super.key,
    required this.data,
    required this.columns,
    required this.title,
    this.onRowTap,
    this.onSelectionChanged,
  });

  @override
  State<LedgerTable> createState() => _LedgerTableState();
}

class _LedgerTableState extends State<LedgerTable> {
  final Set<int> _selectedRows = {};

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(child: Text('No transactions', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(widget.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.teal)),
        ),
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  dataRowMinHeight: 30,
                  dataRowMaxHeight: 40,
                  headingRowHeight: 35,
                  border: TableBorder.all(color: Colors.black, width: 0.5),
                  headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                  columns: widget.columns.map((col) {
                    return DataColumn(
                      label: Text(
                        col['label'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  rows: widget.data.asMap().entries.map((e) {
                    final row = e.value;
                    final idx = e.key;
                    final selected = _selectedRows.contains(idx);
                    return DataRow(
                      selected: selected,
                      onSelectChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedRows.add(idx);
                          } else {
                            _selectedRows.remove(idx);
                          }
                        });
                        widget.onSelectionChanged?.call(
                          _selectedRows.map((i) => widget.data[i]).toList(),
                        );
                      },
                      color: WidgetStateProperty.resolveWith((_) => idx.isEven ? Colors.white : Colors.grey.shade50),
                      cells: widget.columns.asMap().entries.map((c) {
                        final col = c.value;
                        final value = row[col['key']];
                        final isNumeric = col['type'] == 'amount';
                        final key = (col['key'] ?? '').toString();
                        final isDate = key.endsWith('Date') && value is String;
                        return DataCell(
                          Text(
                            isNumeric ? _formatAmount(value) : isDate ? (value.length >= 10 ? value.substring(0, 10) : value) : value.toString(),
                            style: TextStyle(
                              fontSize: 11,
                              color: isNumeric && col['color'] != null ? col['color'] : null,
                            ),
                          ),
                          onTap: c.key == 0 ? () => widget.onRowTap?.call(row) : null,
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatAmount(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }
}
