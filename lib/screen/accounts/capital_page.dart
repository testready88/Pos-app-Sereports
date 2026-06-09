import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/widget/snackbar.dart';
import 'package:sereports/service/account_print_service.dart';
import 'package:sereports/widget/expandable_ledger_card.dart';
import 'package:sereports/widget/common_widgets.dart';
import 'package:sereports/widget/account_summary_card.dart';

class CapitalPage extends StatefulWidget {
  const CapitalPage({super.key});

  @override
  State<CapitalPage> createState() => _CapitalPageState();
}

class _CapitalPageState extends State<CapitalPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final dateFormat = DateFormat('yyyy-MM-dd');

  final searchNameCtrl = TextEditingController();
  final searchInvoiceCtrl = TextEditingController();
  final dateFromCtrl = TextEditingController();
  final dateToCtrl = TextEditingController();

  bool chkName = false;
  bool chkInvoice = false;
  bool chkDate = false;

  String type = 'CAPITAL';
  String status = 'ALL';

  List<Map<String, dynamic>> ledgerData = [];
  List<Map<String, dynamic>> summaryData = [];
  List<Map<String, dynamic>> selectedLedgerData = [];
  double totalCredit = 0, totalDebit = 0, totalBalance = 0;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    searchNameCtrl.dispose();
    searchInvoiceCtrl.dispose();
    dateFromCtrl.dispose();
    dateToCtrl.dispose();
    super.dispose();
  }

  String get typeFilter {
    switch (type) {
      case 'CAPITAL':
        return "(ID='CA' OR ID='CAC')";
      case 'CAPITAL CONTRIBUTION':
        return "ID='CAC'";
      case 'DIVIDEND':
        return "ID='DA'";
      default:
        return "(ID='CA' OR ID='CAC' OR ID='DA')";
    }
  }

  int get activeFilterCount {
    int c = 0;
    if (type != 'CAPITAL') c++;
    if (status != 'ALL') c++;
    if (chkName && searchNameCtrl.text.isNotEmpty) c++;
    if (chkInvoice && searchInvoiceCtrl.text.isNotEmpty) c++;
    if (chkDate) c++;
    return c;
  }

  String get _currentFilters {
    final nameFilter = chkName && searchNameCtrl.text.isNotEmpty
        ? " AND AcName LIKE '%${Api.sqlSafe(searchNameCtrl.text)}%' " : '';
    final invFilter = chkInvoice && searchInvoiceCtrl.text.isNotEmpty
        ? " AND InvoiceNo LIKE '%${Api.sqlSafe(searchInvoiceCtrl.text)}%' " : '';
    final dateFilter = chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty
        ? " AND AccountDate BETWEEN '${dateFromCtrl.text}' AND '${dateToCtrl.text}' " : '';
    final statusFilter = status != 'ALL' ? " AND Status='$status' " : '';
    return "$typeFilter$nameFilter$invFilter$dateFilter$statusFilter";
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final filters = _currentFilters;

      final summaryResp = await Api.get(
        url: Api.getCapitalSummary,
        parameter: {'filters': filters},
      );

      final firstPage = await _fetchLedgerPage(0, 20);

      if (!mounted) return;
      setState(() {
        ledgerData = firstPage;

        final sd = summaryResp['data'];
        if (sd is Map && sd['data'] is List) {
          summaryData = (sd['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        } else {
          summaryData = [];
        }

        totalCredit = ledgerData.fold(0.0, (s, r) => s + ((r['CreditAmount'] ?? 0).toDouble()));
        totalDebit = ledgerData.fold(0.0, (s, r) => s + ((r['DebitAmount'] ?? 0).toDouble()));
        totalBalance = ledgerData.fold(0.0, (s, r) => s + ((r['BalanceAmount'] ?? 0).toDouble()));
        if (sd is Map && sd['totals'] is Map) {
          final t = sd['totals'] as Map;
          if ((t['totalCredit'] ?? 0) != 0 || (t['totalDebit'] ?? 0) != 0) {
            totalCredit = (t['totalCredit'] ?? 0).toDouble();
            totalDebit = (t['totalDebit'] ?? 0).toDouble();
            totalBalance = (t['totalBalance'] ?? 0).toDouble();
          }
        }
      });
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLedgerPage(int page, int pageSize) async {
    try {
      final resp = await Api.get(
        url: Api.getCapitalLedger,
        parameter: {
          'filters': _currentFilters,
          'page': page.toString(),
          'size': pageSize.toString(),
        },
      );
      final ld = resp['data'];
      if (ld is Map && ld['data'] is List) {
        final items = (ld['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        items.sort((a, b) => (b['AccountDate'] ?? '').compareTo(a['AccountDate'] ?? ''));
        return items;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchLedgerPage(int page, int pageSize) async {
    return _fetchLedgerPage(page, pageSize);
  }

  Future<void> printSummaryReport() async {
    try {
      await AccountPrintService.printReport(
        title: 'Capital Account Summary',
        ledgerData: summaryData,
        numberFormat: nf,
        columns: [
          {'key': 'AcName', 'label': 'AcName'},
          {'key': 'ca', 'label': 'Capital Invest', 'type': 'amount'},
          {'key': 'cac', 'label': 'Capital Contribution', 'type': 'amount'},
          {'key': 'caTotal', 'label': 'Capital B/L', 'type': 'amount'},
          {'key': 'da', 'label': 'Profit Distribution', 'type': 'amount'},
        ],
        summary: {
          'Total Credit LKR': nf(totalCredit),
          'Total Debit LKR': nf(totalDebit),
          'Balance LKR': nf(totalBalance),
        },
      );
    } catch (_) {}
  }

  Future<void> printLedgerReport() async {
    try {
      final data = selectedLedgerData.isNotEmpty ? selectedLedgerData : ledgerData;
      final cols = [
        {'key': 'LocaCode', 'label': 'Loca'},
        {'key': 'CompID', 'label': 'CompID'},
        {'key': 'AccountDate', 'label': 'Date'},
        {'key': 'AcName', 'label': 'Ac Name'},
        {'key': 'CreditAmount', 'label': 'Cr.', 'type': 'amount'},
        {'key': 'DebitAmount', 'label': 'Dr.', 'type': 'amount'},
        {'key': 'BalanceAmount', 'label': 'B/L.', 'type': 'amount'},
        {'key': 'AcDescription', 'label': 'Remark'},
      ];
      await AccountPrintService.printReport(
        title: 'Capital Account Ledger',
        ledgerData: data,
        numberFormat: nf,
        columns: cols,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: Appbar(scaffoldKey: scaffoldKey),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: fetchData,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            if (loading) const LinearProgressIndicator(),
            filterBar(),
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.amber,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.amber,
                tabs: [
                  Tab(text: 'Summary'),
                  Tab(text: 'Ledger'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSummaryTab(),
                  _buildLedgerTab(),
                ],
              ),
            ),
            GrandTotalFooter(
              title: 'Capital Totals',
              totals: {
                'Cr.': totalCredit,
                'Dr.': totalDebit,
                'B/L.': totalBalance,
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryTab() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          AccountSummaryCard(
            name: 'Capital Account',
            subtitle: 'Total overview',
            icon: Icons.monetization_on,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
            ),
            fields: [
              AccountSummaryField(label: 'Credit', value: 'LKR ${nf(totalCredit)}'),
              AccountSummaryField(label: 'Debit', value: 'LKR ${nf(totalDebit)}'),
              AccountSummaryField(label: 'Balance', value: 'LKR ${nf(totalBalance)}'),
            ],
          ),
          if (summaryData.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text('Account Breakdown', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
          Expanded(
            child: summaryData.isEmpty
                ? Center(child: Text('No summary data', style: TextStyle(color: Colors.grey, fontSize: 13)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: summaryData.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (ctx, i) {
                      final r = summaryData[i];
                      final name = r['AcName']?.toString() ?? '';
                      final credit = (r['ca'] ?? r['totalCredit'] ?? 0).toDouble();
                      final debit = (r['cac'] ?? r['totalDebit'] ?? 0).toDouble();
                      final balance = (r['caTotal'] ?? r['balanceAmount'] ?? 0).toDouble();
                      final colors = [
                        const Color(0xFFE65100), const Color(0xFF1565C0), const Color(0xFF2E7D32),
                        const Color(0xFF6A1B9A), const Color(0xFFC62828), const Color(0xFF00838F),
                      ];
                      return AccountSummaryCard(
                        name: name,
                        icon: Icons.account_box,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors[i % colors.length], colors[i % colors.length].withOpacity(0.7)],
                        ),
                        fields: [
                          AccountSummaryField(label: 'Invest', value: nf(credit)),
                          AccountSummaryField(label: 'Contri', value: nf(debit)),
                          AccountSummaryField(label: 'Balance', value: nf(balance)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTab() {
    return PaginatedCardList(
      data: ledgerData,
      emptyMessage: 'No ledger data',
      fetchPage: fetchLedgerPage,
      pageSize: 20,
      fetchSize: 40,
      cardBuilder: (row, i) {
        final typeId = row['ID']?.toString() ?? '';
        final typeLabel = typeId == 'CA' ? 'INVEST' : typeId == 'CAC' ? 'CONTRI' : typeId == 'DA' ? 'DIVIDEND' : typeId;
        final name = row['AcName']?.toString() ?? '';
        final subtitle = [name, typeLabel].where((s) => s.isNotEmpty).join(' • ');
        final colors = [
          const Color(0xFFE65100), const Color(0xFF1565C0), const Color(0xFF2E7D32),
          const Color(0xFF6A1B9A), const Color(0xFFC62828), const Color(0xFF00838F),
        ];
        return ExpandableLedgerCard(
          row: {...row, '_subtitle': subtitle},
          accentColor: colors[i % colors.length],
          icon: Icons.savings,
          primaryFields: [
            CardField(key: '_subtitle', label: '', isBold: true, flex: 5),
            CardField(key: 'AccountDate', label: 'Date', flex: 2),
            CardField(key: 'CreditAmount', label: 'Cr.', isAmount: true, color: Colors.white70, flex: 2),
            CardField(key: 'DebitAmount', label: 'Dr.', isAmount: true, color: Colors.white70, flex: 2),
            CardField(key: 'BalanceAmount', label: 'B/L.', isAmount: true, color: Colors.white70, flex: 2),
          ],
          detailFields: [
            CardField(key: 'LocaCode', label: 'Loca'),
            CardField(key: 'CompID', label: 'CompID'),
            CardField(key: 'InvoiceNo', label: 'Invoice'),
            CardField(key: 'AcDescription', label: 'Remark', flex: 3),
          ],
          numberFormat: nf,
        );
      },
    );
  }

  Widget filterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: Colors.white,
      child: Row(
        children: [
          TextButton.icon(
            icon: const Icon(Icons.filter_list, size: 20),
            label: Text('Filters ($activeFilterCount)', style: const TextStyle(fontSize: 14)),
            onPressed: () => showFilterSheet(),
          ),
          if (activeFilterCount > 0)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (type != 'CAPITAL') filterChip(type),
                    if (status != 'ALL') filterChip(status),
                    if (chkName && searchNameCtrl.text.isNotEmpty) filterChip(searchNameCtrl.text),
                    if (chkInvoice && searchInvoiceCtrl.text.isNotEmpty) filterChip(searchInvoiceCtrl.text),
                    if (chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty) filterChip('${dateFromCtrl.text}~${dateToCtrl.text}'),
                  ],
                ),
              ),
            ),
          if (activeFilterCount > 0)
            IconButton(
              icon: const Icon(Icons.clear, size: 18),
              onPressed: () {
                type = 'CAPITAL'; status = 'ALL'; chkName = false; chkInvoice = false; chkDate = false;
                searchNameCtrl.clear(); searchInvoiceCtrl.clear(); dateFromCtrl.clear(); dateToCtrl.clear();
                fetchData();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          OutlinedButton(
            onPressed: printSummaryReport,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              visualDensity: VisualDensity.compact,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Print Summary'),
          ),
          OutlinedButton(
            onPressed: printLedgerReport,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              visualDensity: VisualDensity.compact,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: const Text('Print Ledger'),
          ),
        ],
      ),
    );
  }

  Widget filterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        backgroundColor: Colors.amber.shade50,
      ),
    );
  }

  void showFilterSheet() {
    final fType = type;
    final fStatus = status;
    final fChkName = chkName;
    final fChkInvoice = chkInvoice;
    final fChkDate = chkDate;
    final fNameCtrl = TextEditingController(text: searchNameCtrl.text);
    final fInvoiceCtrl = TextEditingController(text: searchInvoiceCtrl.text);
    final fDateFromCtrl = TextEditingController(text: dateFromCtrl.text);
    final fDateToCtrl = TextEditingController(text: dateToCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        var mType = fType;
        var mStatus = fStatus;
        var mChkName = fChkName;
        var mChkInvoice = fChkInvoice;
        var mChkDate = fChkDate;

        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 16, right: 16, top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton(onPressed: () {
                        mType = 'CAPITAL'; mStatus = 'ALL'; mChkName = false; mChkInvoice = false; mChkDate = false;
                        fNameCtrl.clear(); fInvoiceCtrl.clear();
                        fDateFromCtrl.text = dateFormat.format(DateTime.now());
                        fDateToCtrl.text = dateFormat.format(DateTime.now());
                        setSheetState(() {});
                      }, child: const Text('Clear All')),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mType,
                    decoration: const InputDecoration(labelText: 'Type', isDense: true, border: OutlineInputBorder()),
                    items: ['CAPITAL', 'DIVIDEND', 'CAPITAL CONTRIBUTION'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mType = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mStatus,
                    decoration: const InputDecoration(labelText: 'Status', isDense: true, border: OutlineInputBorder()),
                    items: ['ALL', 'AVAILABLE', 'UNAVAILABLE'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mStatus = v!),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(value: mChkName, onChanged: (v) => setSheetState(() => mChkName = v!)),
                    Expanded(child: TextField(
                      controller: fNameCtrl,
                      decoration: const InputDecoration(labelText: 'Search Name', isDense: true, border: OutlineInputBorder()),
                    )),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(value: mChkInvoice, onChanged: (v) => setSheetState(() => mChkInvoice = v!)),
                    Expanded(child: TextField(
                      controller: fInvoiceCtrl,
                      decoration: const InputDecoration(labelText: 'Search Invoice', isDense: true, border: OutlineInputBorder()),
                    )),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(value: mChkDate, onChanged: (v) => setSheetState(() => mChkDate = v!)),
                    const Text('Date:', style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Expanded(child: TextField(
                      controller: fDateFromCtrl,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      readOnly: true,
                      onTap: () async {
                        final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (d != null) fDateFromCtrl.text = dateFormat.format(d);
                      },
                    )),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 13))),
                    Expanded(child: TextField(
                      controller: fDateToCtrl,
                      decoration: const InputDecoration(isDense: true, border: OutlineInputBorder()),
                      readOnly: true,
                      onTap: () async {
                        final d = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (d != null) fDateToCtrl.text = dateFormat.format(d);
                      },
                    )),
                  ]),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: () {
                      setState(() {
                        type = mType;
                        status = mStatus;
                        chkName = mChkName;
                        chkInvoice = mChkInvoice;
                        chkDate = mChkDate;
                        searchNameCtrl.text = fNameCtrl.text;
                        searchInvoiceCtrl.text = fInvoiceCtrl.text;
                        dateFromCtrl.text = fDateFromCtrl.text;
                        dateToCtrl.text = fDateToCtrl.text;
                      });
                      Navigator.pop(ctx);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        fNameCtrl.dispose();
                        fInvoiceCtrl.dispose();
                        fDateFromCtrl.dispose();
                        fDateToCtrl.dispose();
                      });
                      fetchData();
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String nf(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }
}
