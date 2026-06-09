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

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final dateFormat = DateFormat('yyyy-MM-dd');

  final methodCtrl = TextEditingController();
  final statusCtrl = TextEditingController();
  final searchNameCtrl = TextEditingController();
  final searchInvoiceCtrl = TextEditingController();
  final dateFromCtrl = TextEditingController();
  final dateToCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();

  bool chkName = false;
  bool chkInvoice = false;
  bool chkDate = false;

  String method = 'ALL';
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
    methodCtrl.dispose();
    statusCtrl.dispose();
    searchNameCtrl.dispose();
    searchInvoiceCtrl.dispose();
    dateFromCtrl.dispose();
    dateToCtrl.dispose();
    remarkCtrl.dispose();
    super.dispose();
  }

  int get activeFilterCount {
    int c = 0;
    if (method != 'ALL') c++;
    if (status != 'ALL') c++;
    if (chkName && searchNameCtrl.text.isNotEmpty) c++;
    if (chkInvoice && searchInvoiceCtrl.text.isNotEmpty) c++;
    if (chkDate) c++;
    return c;
  }

  String _buildFilterString() {
    final nameFilter = chkName && searchNameCtrl.text.isNotEmpty
        ? " AND AcName LIKE '%${Api.sqlSafe(searchNameCtrl.text)}%' "
        : '';
    final invFilter = chkInvoice && searchInvoiceCtrl.text.isNotEmpty
        ? " AND InvoiceNo LIKE '%${Api.sqlSafe(searchInvoiceCtrl.text)}%' "
        : '';
    final dateFilter = chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty
        ? " AND AccountDate BETWEEN '${dateFromCtrl.text}' AND '${dateToCtrl.text}' "
        : '';
    final methodFilter = method != 'ALL' ? " AND AcMethod='$method' " : '';
    final statusFilter = status != 'ALL' ? " AND Status='$status' " : '';
    return "ID='AST'$methodFilter$statusFilter$nameFilter$invFilter$dateFilter";
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final filters = _buildFilterString();

      final summaryResp = await Api.get(
        url: Api.getAssetSummary,
        parameter: {'filters': filters},
      );

      final firstPage = await _fetchLedgerPage(0, 20, filters);

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

  Future<List<Map<String, dynamic>>> _fetchLedgerPage(int page, int pageSize, String filters) async {
    try {
      final resp = await Api.get(
        url: Api.getAssetLedger,
        parameter: {
          'filters': filters,
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
    return _fetchLedgerPage(page, pageSize, _buildFilterString());
  }

  Future<void> printSummaryReport() async {
    try {
      await AccountPrintService.printReport(
        title: 'Assets Account Summary',
        ledgerData: summaryData,
        numberFormat: numberFormat,
        columns: [
          {'key': 'AcName', 'label': 'AcName'},
          {'key': 'totalCredit', 'label': 'Cr.', 'type': 'amount'},
          {'key': 'totalDebit', 'label': 'Dr.', 'type': 'amount'},
          {'key': 'balanceAmount', 'label': 'B/L.', 'type': 'amount'},
        ],
        summary: {
          'Total Credit LKR': numberFormat(totalCredit),
          'Total Debit LKR': numberFormat(totalDebit),
          'Balance LKR': numberFormat(totalBalance),
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
        title: 'Assets Account Ledger',
        ledgerData: data,
        numberFormat: numberFormat,
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
                labelColor: Colors.teal,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.teal,
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
              title: 'Asset Totals',
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
            name: 'Assets Account',
            subtitle: 'Total overview',
            icon: Icons.account_balance_wallet,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF26A69A), Color(0xFF00897B)],
            ),
            fields: [
              AccountSummaryField(label: 'Credit', value: 'LKR ${numberFormat(totalCredit)}'),
              AccountSummaryField(label: 'Debit', value: 'LKR ${numberFormat(totalDebit)}'),
              AccountSummaryField(label: 'Balance', value: 'LKR ${numberFormat(totalBalance)}'),
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
                      final credit = (r['totalCredit'] ?? 0).toDouble();
                      final debit = (r['totalDebit'] ?? 0).toDouble();
                      final balance = (r['balanceAmount'] ?? 0).toDouble();
                      final colors = [
                        const Color(0xFF26A69A), const Color(0xFFC62828), const Color(0xFF1565C0),
                        const Color(0xFFE65100), const Color(0xFF6A1B9A), const Color(0xFF2E7D32),
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
                          AccountSummaryField(label: 'Credit', value: numberFormat(credit)),
                          AccountSummaryField(label: 'Debit', value: numberFormat(debit)),
                          AccountSummaryField(label: 'Balance', value: numberFormat(balance)),
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
        final colors = [
          const Color(0xFF00838F), const Color(0xFFC62828), const Color(0xFFE65100),
          const Color(0xFF2E7D32), const Color(0xFF6A1B9A), const Color(0xFF1565C0),
        ];
        return ExpandableLedgerCard(
          row: row,
          accentColor: colors[i % colors.length],
          icon: Icons.account_balance_wallet,
          primaryFields: [
            const CardField(key: 'AcName', label: 'Name', isBold: true, flex: 3),
            CardField(key: 'AccountDate', label: 'Date', flex: 2),
            CardField(key: 'CreditAmount', label: 'Cr.', isAmount: true, color: Colors.white70, flex: 2),
            CardField(key: 'DebitAmount', label: 'Dr.', isAmount: true, color: Colors.white70, flex: 2),
            CardField(key: 'BalanceAmount', label: 'B/L.', isAmount: true, color: Colors.white70, flex: 2),
          ],
          detailFields: [
            CardField(key: 'LocaCode', label: 'Loca'),
            CardField(key: 'CompID', label: 'CompID'),
            CardField(key: 'AcCode', label: 'Code'),
            CardField(key: 'AcMethod', label: 'Method'),
            CardField(key: 'Status', label: 'Status'),
            CardField(key: 'InvoiceNo', label: 'Invoice'),
            CardField(key: 'AcDescription', label: 'Remark', flex: 3),
          ],
          numberFormat: numberFormat,
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
                    if (method != 'ALL') filterChip(method),
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
                method = 'ALL'; status = 'ALL'; chkName = false; chkInvoice = false; chkDate = false;
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
        backgroundColor: Colors.teal.shade50,
      ),
    );
  }

  void showFilterSheet() {
    final fMethod = method;
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
        var mMethod = fMethod;
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
                        mMethod = 'ALL'; mStatus = 'ALL'; mChkName = false; mChkInvoice = false; mChkDate = false;
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
                    value: mMethod,
                    decoration: const InputDecoration(labelText: 'Method', isDense: true, border: OutlineInputBorder()),
                    items: ['ALL', 'FIXED', 'CURRENT'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mMethod = v!),
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
                        method = mMethod;
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

  String numberFormat(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }
}
