import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/widget/snackbar.dart';

import 'package:sereports/service/account_print_service.dart';
import 'package:sereports/widget/expandable_ledger_card.dart';
import 'package:sereports/widget/account_summary_card.dart';

class ChequesPage extends StatefulWidget {
  const ChequesPage({super.key});

  @override
  State<ChequesPage> createState() => _ChequesPageState();
}

class _ChequesPageState extends State<ChequesPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final dateFormat = DateFormat('yyyy-MM-dd');

  final searchChqNoCtrl = TextEditingController();
  final searchInvoiceCtrl = TextEditingController();
  final searchVenCtrl = TextEditingController();
  final searchBnkCtrl = TextEditingController();
  final dateFromCtrl = TextEditingController();
  final dateToCtrl = TextEditingController();

  bool chkChqNo = false;
  bool chkInvoice = false;
  bool chkVen = false;
  bool chkBnk = false;
  bool chkDate = false;

  String locaCode = 'All';
  String chqType = 'ALL';
  String chqStatus = 'ALL';
  String idFilter = 'ALL';

  List<Map<String, dynamic>> chqData = [];
  Set<String> selectedRows = {};

  double totalRecAmount = 0, totalGivenAmount = 0, totalPartyAmount = 0, totalInHandAmount = 0;
  double totalSuccessAmount = 0, totalReturnAmount = 0, totalCrossAmount = 0, totalCashAmount = 0;
  int totalRecCount = 0, totalGivenCount = 0, totalPartyCount = 0, totalInHandCount = 0;
  int totalSuccessCount = 0, totalReturnCount = 0, totalCrossCount = 0, totalCashCount = 0;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    searchChqNoCtrl.dispose();
    searchInvoiceCtrl.dispose();
    searchVenCtrl.dispose();
    searchBnkCtrl.dispose();
    dateFromCtrl.dispose();
    dateToCtrl.dispose();
    super.dispose();
  }

  int get activeFilterCount {
    int c = 0;
    if (chqType != 'ALL') c++;
    if (chqStatus != 'ALL') c++;
    if (idFilter != 'ALL') c++;
    if (chkChqNo && searchChqNoCtrl.text.isNotEmpty) c++;
    if (chkInvoice && searchInvoiceCtrl.text.isNotEmpty) c++;
    if (chkVen && searchVenCtrl.text.isNotEmpty) c++;
    if (chkBnk && searchBnkCtrl.text.isNotEmpty) c++;
    if (chkDate) c++;
    return c;
  }

  Future<void> fetchData() async {
    setState(() => loading = true);
    try {
      final resp = await Api.get(
        url: Api.getChequeTransactions,
        parameter: {
          'locaCode': locaCode,
          'bankName': chkBnk && searchBnkCtrl.text.isNotEmpty ? searchBnkCtrl.text : 'All',
          'searchRef': chkInvoice ? searchInvoiceCtrl.text : '',
          'chqNo': chkChqNo ? searchChqNoCtrl.text : '',
          'chqType': chqType,
          'statusFilter': chqStatus,
          'idFilter': idFilter,
          'vendor': chkVen && searchVenCtrl.text.isNotEmpty ? searchVenCtrl.text : '',
          'page': '0',
          'size': '5000',
          if (chkDate && dateFromCtrl.text.isNotEmpty) 'dateFrom': dateFromCtrl.text,
          if (chkDate && dateToCtrl.text.isNotEmpty) 'dateTo': dateToCtrl.text,
        },
      );
      final raw = resp['data'];
      final data = raw is Map ? raw['data'] ?? raw : raw;
      final content = (data is Map ? (data['content'] ?? data['data'] ?? []) : (data is List ? data : [])) as List;
      if (!mounted) return;
       setState(() {
          chqData = content.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
         chqData.sort((a, b) => (b['ChqDate'] ?? '').compareTo(a['ChqDate'] ?? ''));
         selectedRows.clear();
         computeSummaries();
       });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void computeSummaries() {
    totalRecAmount = 0; totalRecCount = 0;
    totalGivenAmount = 0; totalGivenCount = 0;
    totalPartyAmount = 0; totalPartyCount = 0;
    totalInHandAmount = 0; totalInHandCount = 0;
    totalSuccessAmount = 0; totalSuccessCount = 0;
    totalReturnAmount = 0; totalReturnCount = 0;
    totalCrossAmount = 0; totalCrossCount = 0;
    totalCashAmount = 0; totalCashCount = 0;

    for (var r in chqData) {
      final amt = _toDouble(r['PaidAmount']);
      final cType = r['ChqType']?.toString() ?? '';
      final status = r['Status']?.toString() ?? '';
      final pType = r['PaymentType']?.toString() ?? '';
      final tType = r['TransactionType']?.toString() ?? '';

      if (cType == 'RECIEVED CHQ' && status != 'UNKNOWN' && status != 'RETURN' && tType != 'IN HAND') {
        totalRecAmount += amt; totalRecCount++;
      }
      if (cType == 'OWN CHQ' && status != 'UNKNOWN' && status != 'RETURN' && tType != 'IN HAND') {
        totalGivenAmount += amt; totalGivenCount++;
      }
      if (cType == 'PARTY CHQ' && status != 'UNKNOWN' && status != 'RETURN' && tType != 'IN HAND') {
        totalPartyAmount += amt; totalPartyCount++;
      }
      if (tType == 'IN HAND' && status != 'RETURN') {
        totalInHandAmount += amt; totalInHandCount++;
      }
      if (status == 'SUCCESS' && tType != 'IN HAND') {
        totalSuccessAmount += amt; totalSuccessCount++;
      }
      if (status == 'RETURN' && tType != 'IN HAND') {
        totalReturnAmount += amt; totalReturnCount++;
      }
      if (pType == 'CROSS CHQ' && status != 'UNKNOWN' && status != 'RETURN') {
        totalCrossAmount += amt; totalCrossCount++;
      }
      if (pType == 'CASH CHQ' && status != 'UNKNOWN' && status != 'RETURN') {
        totalCashAmount += amt; totalCashCount++;
      }
    }
  }

  String get selectedRowNos => selectedRows.join(',');

  String _smartNum(dynamic val) {
    final v = (val is double || val is int) ? val.toDouble() : double.tryParse(val?.toString() ?? '') ?? 0;
    return v.toInt().toString();
  }

  Future<void> printReport() async {
    final cols = [
      {'key': 'ChqType', 'label': 'Type'},
      {'key': 'Status', 'label': 'Status'},
      {'key': 'PaidAmount', 'label': 'Amount', 'type': 'amount'},
      {'key': 'chqCount', 'label': 'Count'},
    ];
    try {
      await AccountPrintService.printReport(
        title: 'Cheque Summary',
        ledgerData: chqData,
        numberFormat: _smartNum,
        columns: cols,
        summary: {
          'Received': '${totalRecAmount.toStringAsFixed(0)} ($totalRecCount)',
          'Own Chq': '${totalGivenAmount.toStringAsFixed(0)} ($totalGivenCount)',
          'Party Chq': '${totalPartyAmount.toStringAsFixed(0)} ($totalPartyCount)',
          'Success': '${totalSuccessAmount.toStringAsFixed(0)} ($totalSuccessCount)',
          'Return': '${totalReturnAmount.toStringAsFixed(0)} ($totalReturnCount)',
        },
      );
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, "Couldn't generate print job");
    }
  }

  Future<void> printLedgerReport() async {
    final data = selectedRows.isNotEmpty
        ? chqData.where((r) => selectedRows.contains(r['RowNo']?.toString())).toList()
        : chqData;
    final cols = [
      {'key': 'LocaCode', 'label': 'Loca'},
      {'key': 'CompID', 'label': 'Comp'},
      {'key': 'InvoiceNo', 'label': 'Invoice No'},
      {'key': 'ID', 'label': 'ID'},
      {'key': 'ChqNo', 'label': 'Cheque No'},
      {'key': 'Status', 'label': 'Status'},
      {'key': 'PaidAmount', 'label': 'Chq Amount', 'type': 'amount'},
      {'key': 'ChqDate', 'label': 'Cheque Date'},
      {'key': 'ChqType', 'label': 'Chq Type'},
      {'key': 'VenName', 'label': 'Vendor'},
      {'key': 'VenNameChqFrom', 'label': 'Vendor Party CHQ'},
      {'key': 'BnkName', 'label': 'Bank'},
    ];
    try {
      await AccountPrintService.printReport(
        title: 'Cheque Ledger',
        ledgerData: data,
        numberFormat: _smartNum,
        columns: cols,
      );
    } catch (e) {
      if (context.mounted) showErrorSnackBar(context, "Couldn't generate print job");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: Appbar(scaffoldKey: scaffoldKey),
      drawer: AppDrawer(),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: FloatingActionButton.small(
          onPressed: fetchData,
          tooltip: 'Refresh',
          child: const Icon(Icons.refresh),
        ),
      ),
      body: Column(
        children: [
          if (loading) const LinearProgressIndicator(),
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  filterBar(),
                  summaryCards(),
                  const Divider(height: 1),
                  Expanded(child: chqList()),
                  actionButtons(),
                  statusFooter(),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }

  Widget filterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.filter_list, size: 20),
              label: Text('Filters ($activeFilterCount)', style: const TextStyle(fontSize: 14)),
              onPressed: () => showFilterSheet(),
            ),
            if (activeFilterCount > 0) ...[
              if (chqType != 'ALL') filterChip(chqType),
              if (chqStatus != 'ALL') filterChip(chqStatus),
              if (idFilter != 'ALL') filterChip(idFilter),
              if (chkChqNo && searchChqNoCtrl.text.isNotEmpty) filterChip('Chq#: ${searchChqNoCtrl.text}'),
              if (chkInvoice && searchInvoiceCtrl.text.isNotEmpty) filterChip('Inv: ${searchInvoiceCtrl.text}'),
              if (chkVen && searchVenCtrl.text.isNotEmpty) filterChip('Ven: ${searchVenCtrl.text}'),
              if (chkBnk && searchBnkCtrl.text.isNotEmpty) filterChip('Bnk: ${searchBnkCtrl.text}'),
              if (chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty) filterChip('${dateFromCtrl.text}~${dateToCtrl.text}'),
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  chqType = 'ALL'; chqStatus = 'ALL'; idFilter = 'ALL';
                  chkChqNo = false; chkInvoice = false; chkVen = false; chkBnk = false; chkDate = false;
                  searchChqNoCtrl.clear(); searchInvoiceCtrl.clear(); searchVenCtrl.clear(); searchBnkCtrl.clear(); dateFromCtrl.clear(); dateToCtrl.clear();
                  fetchData();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
            OutlinedButton(
              onPressed: printReport,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                visualDensity: VisualDensity.compact,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                textStyle: const TextStyle(fontSize: 11),
              ),
              child: const Text('Print Summary'),
            ),
            const SizedBox(width: 4),
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
        backgroundColor: Colors.cyan.shade50,
      ),
    );
  }

  void showFilterSheet() {
    final fChqType = chqType;
    final fChqStatus = chqStatus;
    final fIdFilter = idFilter;
    final fChkChqNo = chkChqNo;
    final fChkInvoice = chkInvoice;
    final fChkVen = chkVen;
    final fChkBnk = chkBnk;
    final fChkDate = chkDate;
    final fChqNoCtrl = TextEditingController(text: searchChqNoCtrl.text);
    final fInvoiceCtrl = TextEditingController(text: searchInvoiceCtrl.text);
    final fVenCtrl = TextEditingController(text: searchVenCtrl.text);
    final fBnkCtrl = TextEditingController(text: searchBnkCtrl.text);
    final fDateFromCtrl = TextEditingController(text: dateFromCtrl.text);
    final fDateToCtrl = TextEditingController(text: dateToCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        var mChqType = fChqType;
        var mChqStatus = fChqStatus;
        var mIdFilter = fIdFilter;
        var mChkChqNo = fChkChqNo;
        var mChkInvoice = fChkInvoice;
        var mChkVen = fChkVen;
        var mChkBnk = fChkBnk;
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
                        mChqType = 'ALL'; mChqStatus = 'ALL'; mIdFilter = 'ALL';
                        mChkChqNo = false; mChkInvoice = false; mChkVen = false; mChkBnk = false; mChkDate = false;
                        fChqNoCtrl.clear(); fInvoiceCtrl.clear(); fVenCtrl.clear(); fBnkCtrl.clear();
                        fDateFromCtrl.text = dateFormat.format(DateTime.now());
                        fDateToCtrl.text = dateFormat.format(DateTime.now());
                        setSheetState(() {});
                      }, child: const Text('Clear All')),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mChqType,
                    decoration: const InputDecoration(labelText: 'Chq Type', isDense: true, border: OutlineInputBorder()),
                    items: ['ALL','OWN CHQ','RECEIVED CHQ','PARTY CHQ','CHQ IN HAND','CROSS CHQ','CASH CHQ','RETURN CHQ','UNKNOWN CHQ']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mChqType = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mChqStatus,
                    decoration: const InputDecoration(labelText: 'Status', isDense: true, border: OutlineInputBorder()),
                    items: ['ALL','PENDING','SUCCESS','RETURN']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mChqStatus = v!),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: mIdFilter,
                    decoration: const InputDecoration(labelText: 'Type', isDense: true, border: OutlineInputBorder()),
                    items: ['ALL','INVOICE','PURCHASE','EXPENSES','INCOME','ADVANCE PAYMENT','DEPOSIT','WITHDRAW']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setSheetState(() => mIdFilter = v!),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(value: mChkChqNo, onChanged: (v) => setSheetState(() => mChkChqNo = v!)),
                    Expanded(child: TextField(
                      controller: fChqNoCtrl,
                      decoration: const InputDecoration(labelText: 'Chq No', isDense: true, border: OutlineInputBorder()),
                    )),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Checkbox(value: mChkInvoice, onChanged: (v) => setSheetState(() => mChkInvoice = v!)),
                    Expanded(child: TextField(
                      controller: fInvoiceCtrl,
                      decoration: const InputDecoration(labelText: 'Invoice', isDense: true, border: OutlineInputBorder()),
                    )),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Checkbox(value: mChkVen, onChanged: (v) => setSheetState(() => mChkVen = v!)),
                    Expanded(child: TextField(
                      controller: fVenCtrl,
                      decoration: const InputDecoration(labelText: 'Vendor', isDense: true, border: OutlineInputBorder()),
                    )),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Checkbox(value: mChkBnk, onChanged: (v) => setSheetState(() => mChkBnk = v!)),
                    Expanded(child: TextField(
                      controller: fBnkCtrl,
                      decoration: const InputDecoration(labelText: 'Bank', isDense: true, border: OutlineInputBorder()),
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
                        chqType = mChqType;
                        chqStatus = mChqStatus;
                        idFilter = mIdFilter;
                        chkChqNo = mChkChqNo;
                        chkInvoice = mChkInvoice;
                        chkVen = mChkVen;
                        chkBnk = mChkBnk;
                        chkDate = mChkDate;
                        searchChqNoCtrl.text = fChqNoCtrl.text;
                        searchInvoiceCtrl.text = fInvoiceCtrl.text;
                        searchVenCtrl.text = fVenCtrl.text;
                        searchBnkCtrl.text = fBnkCtrl.text;
                        dateFromCtrl.text = fDateFromCtrl.text;
                        dateToCtrl.text = fDateToCtrl.text;
                      });
                      Navigator.pop(ctx);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        fChqNoCtrl.dispose();
                        fInvoiceCtrl.dispose();
                        fVenCtrl.dispose();
                        fBnkCtrl.dispose();
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

  Widget summaryCards() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: Colors.white,
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _graphicalSummaryCard('Received Chq', totalRecAmount, totalRecCount, Icons.receipt_long, Colors.blue),
          _graphicalSummaryCard('Own Chq', totalGivenAmount, totalGivenCount, Icons.payment, Colors.orange),
          _graphicalSummaryCard('Party Chq', totalPartyAmount, totalPartyCount, Icons.groups, Colors.purple),
          _graphicalSummaryCard('In Hand', totalInHandAmount, totalInHandCount, Icons.handshake, Colors.teal),
          _graphicalSummaryCard('Success', totalSuccessAmount, totalSuccessCount, Icons.check_circle, Colors.green),
          _graphicalSummaryCard('Return', totalReturnAmount, totalReturnCount, Icons.cancel, Colors.red),
          _graphicalSummaryCard('Cross', totalCrossAmount, totalCrossCount, Icons.swap_horiz, Colors.indigo),
          _graphicalSummaryCard('Cash', totalCashAmount, totalCashCount, Icons.money, Colors.indigo),
        ],
      ),
    );
  }

  Widget _graphicalSummaryCard(String label, double amount, int count, IconData icon, Color color) {
    final hsl = HSLColor.fromColor(color);
    final lighter = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
    final darker = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0)).toColor();
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lighter, darker],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 14),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _smartNum(amount),
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$count items',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget chqList() {
    if (chqData.isEmpty) {
      return const Center(child: Text('No data', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Cheque Transactions (${chqData.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal)),
        ),
        Expanded(
          child: PaginatedCardList(
            data: chqData,
            emptyMessage: 'No data',
            fetchPage: (page, pageSize) async {
              try {
                final resp = await Api.get(
                  url: Api.getChequeTransactions,
                  parameter: {
                    'locaCode': locaCode,
                    'bankName': chkBnk && searchBnkCtrl.text.isNotEmpty ? searchBnkCtrl.text : 'All',
                    'searchRef': chkInvoice ? searchInvoiceCtrl.text : '',
                    'chqNo': chkChqNo ? searchChqNoCtrl.text : '',
                    'chqType': chqType,
                    'statusFilter': chqStatus,
                    'idFilter': idFilter,
                    'vendor': chkVen && searchVenCtrl.text.isNotEmpty ? searchVenCtrl.text : '',
                    'page': page.toString(),
                    'size': pageSize.toString(),
                    if (chkDate && dateFromCtrl.text.isNotEmpty) 'dateFrom': dateFromCtrl.text,
                    if (chkDate && dateToCtrl.text.isNotEmpty) 'dateTo': dateToCtrl.text,
                  },
                );
                final raw = resp['data'];
                final data = raw is Map ? raw['data'] ?? raw : raw;
                final content = (data is Map ? (data['content'] ?? data['data'] ?? []) : (data is List ? data : [])) as List;
                final items = content.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
                items.sort((a, b) => (b['ChqDate'] ?? '').compareTo(a['ChqDate'] ?? ''));
                return items;
              } catch (_) {
                return [];
              }
            },
            pageSize: 20,
            fetchSize: 40,
            cardBuilder: (row, i) {
              final st = row['Status']?.toString() ?? '';
              final rowNo = row['RowNo']?.toString() ?? '';
              final isSelected = selectedRows.contains(rowNo);
              final statusColors = {
                'SUCCESS': [
                  const Color(0xFF2E7D32), const Color(0xFF1565C0), const Color(0xFFE65100),
                  const Color(0xFF6A1B9A), const Color(0xFFC62828), const Color(0xFF00838F),
                ],
                'RETURN': [
                  const Color(0xFFC62828), const Color(0xFF2E7D32), const Color(0xFF1565C0),
                  const Color(0xFFE65100), const Color(0xFF6A1B9A), const Color(0xFF00838F),
                ],
                'PENDING': [
                  const Color(0xFFE65100), const Color(0xFF1565C0), const Color(0xFF2E7D32),
                  const Color(0xFF6A1B9A), const Color(0xFFC62828), const Color(0xFF00838F),
                ],
              };
              final palette = statusColors[st] ?? [
                const Color(0xFF455A64), const Color(0xFF37474F), const Color(0xFF546E7A),
                const Color(0xFF607D8B), const Color(0xFF263238), const Color(0xFF78909C),
              ];
              final ven = row['VenName']?.toString() ?? '';
              final bnk = row['BnkName']?.toString() ?? '';
              final parts = [ven, bnk].where((s) => s.isNotEmpty).toList();
              final subtitle = parts.join(' • ');
              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (isSelected) {
                      selectedRows.remove(rowNo);
                    } else {
                      selectedRows.add(rowNo);
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected ? Border.all(color: Colors.amber, width: 3) : null,
                  ),
                  child: ExpandableLedgerCard(
                    row: {
                      ...row,
                      '_subtitle': subtitle,
                      '_statusColor': st == 'SUCCESS' ? 'green' : st == 'RETURN' ? 'red' : st == 'PENDING' ? 'orange' : 'grey',
                    },
                    accentColor: isSelected ? Colors.amber.shade700 : palette[i % palette.length],
                    icon: isSelected ? Icons.check_circle : Icons.receipt,
                    primaryFields: [
                      CardField(key: 'ChqNo', label: 'Chq No', isBold: true, flex: 2),
                      CardField(key: '_subtitle', label: '', flex: 3),
                      CardField(key: 'PaidAmount', label: 'Amount', isAmount: true, color: Colors.white70, flex: 2),
                      CardField(key: 'ChqDate', label: 'Date', flex: 2),
                      CardField(key: 'Status', label: 'Status', flex: 1),
                    ],
                    detailFields: [
                      CardField(key: 'LocaCode', label: 'Loca'),
                      CardField(key: 'CompID', label: 'CompID'),
                      CardField(key: 'InvoiceNo', label: 'Invoice'),
                      CardField(key: 'ChqType', label: 'Type'),
                      CardField(key: 'BnkName', label: 'Bank', flex: 2),
                      CardField(key: 'VenNameChqFrom', label: 'Vendor Party CHQ', flex: 2),
                      CardField(key: 'AcType', label: 'Ac Type'),
                      CardField(key: 'ReferenceNo', label: 'Ref No'),
                      CardField(key: 'InvoiceDescription', label: 'Remark', flex: 3),
                    ],
                    numberFormat: _smartNum,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void showChqDetailSheet(Map<String, dynamic> r) {
    final st = r['Status']?.toString() ?? '';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 12),
            Row(children: [
              const Text('Cheque Detail', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (r['Status']?.toString() == 'SUCCESS' ? Colors.green :
                          r['Status']?.toString() == 'RETURN' ? Colors.red :
                          r['Status']?.toString() == 'PENDING' ? Colors.orange : Colors.grey).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(r['Status']?.toString() ?? '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color:
                  r['Status']?.toString() == 'SUCCESS' ? Colors.green :
                  r['Status']?.toString() == 'RETURN' ? Colors.red :
                  r['Status']?.toString() == 'PENDING' ? Colors.orange : Colors.grey)),
              ),
            ]),
            const Divider(),
            detailRow('Loca', _val(r, 'LocaCode')),
            detailRow('CompID', _val(r, 'CompID')),
            detailRow('Invoice No', r['InvoiceNo']?.toString() ?? ''),
            detailRow('ID', _val(r, 'ID')),
            detailRow('Cheque No', r['ChqNo']?.toString() ?? ''),
            detailRow('Status', st),
            detailRow('Chq Amount', nf(r['PaidAmount'])),
            detailRow('Cheque Date', _dateShort(_val(r, 'ChqDate'))),
            detailRow('Chq Type', _val(r, 'ChqType')),
            detailRow('Vendor', r['VenName']?.toString() ?? ''),
            detailRow('Vendor Party CHQ', r['VenNameChqFrom']?.toString() ?? ''),
            detailRow('Bank', r['BnkName']?.toString() ?? ''),
            detailRow('Ac Type', _val(r, 'AcType')),
            detailRow('Remark', r['InvoiceDescription']?.toString() ?? ''),
            detailRow('Ref No', _val(r, 'ReferenceNo')),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 70, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget statusFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      color: Colors.grey.shade800,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _footerItem('Rec.Chq', totalRecAmount, totalRecCount, Colors.blue),
              _footerItem('Own Chq', totalGivenAmount, totalGivenCount, Colors.orange),
              _footerItem('Party', totalPartyAmount, totalPartyCount, Colors.purpleAccent),
              _footerItem('In Hand', totalInHandAmount, totalInHandCount, Colors.tealAccent),
              _footerItem('Success', totalSuccessAmount, totalSuccessCount, Colors.greenAccent),
              _footerItem('Return', totalReturnAmount, totalReturnCount, Colors.redAccent),
              _footerItem('Cross', totalCrossAmount, totalCrossCount, Colors.indigoAccent),
              _footerItem('Cash', totalCashAmount, totalCashCount, Colors.deepOrangeAccent),
          ],
        ),
      ),
    );
  }

  Widget _footerItem(String label, double amount, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70)),
          Text(amount.toStringAsFixed(0), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          Text('($count)', style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.grey.shade100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _actionBtn('Pass', Colors.green, cmdChqPassed),
          const SizedBox(width: 8),
          _actionBtn('Hold', Colors.orange, cmdCHQHold),
          const SizedBox(width: 8),
          _actionBtn('Deposit', Colors.blue, cmdCHQDeposit),
          const SizedBox(width: 8),
          _actionBtn('Return', Colors.red, cmdReturn),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.15),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Future<void> cmdChqPassed() async {
    if (selectedRows.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select cheques first'))); return; }
    try {
      await Api.post(url: Api.chqPass, body: {'rowNos': selectedRowNos});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cheques marked as passed')));
      fetchData();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> cmdCHQHold() async {
    if (selectedRows.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select cheques first'))); return; }
    try {
      await Api.post(url: Api.chqHold, body: {'rowNos': selectedRowNos});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cheques held')));
      fetchData();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> cmdCHQDeposit() async {
    if (selectedRows.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select cheques first'))); return; }
    try {
      await Api.post(url: Api.chqDeposit, body: {'rowNos': selectedRowNos});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cheques deposited')));
      fetchData();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
  }

  Future<void> cmdReturn() async {
    if (selectedRows.isEmpty) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select cheques first'))); return; }
    try {
      await Api.post(url: Api.chqReturn, body: {'rowNos': selectedRowNos});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cheques marked as returned')));
      fetchData();
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
  }

  String _val(Map r, String key) {
    if (r.containsKey(key)) return (r[key] ?? '').toString();
    final lower = key.toLowerCase();
    for (final k in r.keys) {
      if (k.toString().toLowerCase() == lower) {
        return (r[k] ?? '').toString();
      }
    }
    return '';
  }

  String _dateShort(String d) {
    return d.length >= 10 ? d.substring(0, 10) : d;
  }

  String nf(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }

  double _toDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val?.toString() ?? '') ?? 0;
  }
}
