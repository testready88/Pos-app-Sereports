import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/utils/api.dart';
import 'package:sereports/utils/interceptor.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/widget/snackbar.dart';
import 'package:sereports/service/account_print_service.dart';
import 'package:sereports/widget/expandable_ledger_card.dart';
import 'package:sereports/widget/account_summary_card.dart';
import 'package:http_interceptor/http_interceptor.dart';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final dateFormat = DateFormat('yyyy-MM-dd');
  late TabController _tabController;

  final searchCtrl = TextEditingController();
  final dateFromCtrl = TextEditingController();
  final dateToCtrl = TextEditingController();
  final remarkCtrl = TextEditingController();
  final adjustAmountCtrl = TextEditingController();
  final dRateCtrl = TextEditingController();
  final depAmountCtrl = TextEditingController();
  final depDeductionCtrl = TextEditingController();
  final searchBankCtrl = TextEditingController();

  bool chkSearch = false;
  bool chkDate = false;

  String locaCode = 'ALL';

  List<Map<String, dynamic>> accountData = [];
  List<Map<String, dynamic>> ledgerData = [];
  List<String> bankNames = [];
  String? selectedBankName;

  String? selectedAcCode;
  String? selectedAcName;
  double selectedBalance = 0;
  double selectedDRate = 0;

  bool loading = false;
  bool showDepositPanel = false;
  final Set<int> _selectedLedgerRows = {};
  final filterScrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchBankNames();
    fetchAccounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchCtrl.dispose();
    dateFromCtrl.dispose();
    dateToCtrl.dispose();
    remarkCtrl.dispose();
    adjustAmountCtrl.dispose();
    dRateCtrl.dispose();
    depAmountCtrl.dispose();
    depDeductionCtrl.dispose();
    searchBankCtrl.dispose();
    filterScrollCtrl.dispose();
    super.dispose();
  }

  int get activeFilterCount {
    int c = 0;
    if (chkSearch && searchCtrl.text.isNotEmpty) c++;
    if (chkDate) c++;
    if (locaCode != 'ALL') c++;
    return c;
  }

  String _getSearchFilter() {
    if (!chkSearch || searchCtrl.text.isEmpty) return '';
    return "AND AcName LIKE '%${Api.sqlSafe(searchCtrl.text)}%'";
  }

  Future<void> fetchBankNames() async {
    try {
      final resp = await Api.get(url: Api.getBankNameList, parameter: {});
      final data = resp['data'];
      if (!mounted) return;
      setState(() {
        if (data is List) {
          bankNames = data.map((e) => e.toString()).toList();
        }
      });
    } catch (_) {}
  }

  Future<void> fetchAccounts() async {
    setState(() => loading = true);
    try {
      final client = InterceptedHttp.build(interceptors: [SeReportInterceptor()]);
      final uri = Uri.parse(Api.getCardAccounts).replace(queryParameters: {
        if (_getSearchFilter().isNotEmpty) 'filters': _getSearchFilter(),
      });
      final response = await client.get(uri);
      if (response.statusCode != 200) {
        if (mounted) showErrorSnackBar(context, 'HTTP ${response.statusCode}');
        return;
      }
      final raw = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        final d = raw is Map ? raw['data'] : raw;
        if (d is Map && d['data'] is List) {
          accountData = (d['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
        } else if (d is List) {
          accountData = d.map((e) => Map<String, dynamic>.from(e)).toList();
        } else {
          accountData = [];
        }
      });
      await fetchLedger();
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> fetchLedger() async {
    try {
      final searchFilter = chkSearch && searchCtrl.text.isNotEmpty
          ? "AND AcName LIKE '%${Api.sqlSafe(searchCtrl.text)}%'" : '';
      final dateFilter = chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty
          ? "AND CreateDate BETWEEN '${dateFromCtrl.text}' AND '${dateToCtrl.text}'" : '';
      final locaFilter = locaCode != 'ALL' ? "AND LocaCode='$locaCode'" : '';
      final acFilter = selectedAcCode != null ? "AND AcCode='${Api.sqlSafe(selectedAcCode!)}'" : '';
      final filters = "(CreditAmount<>0 OR DebitAmount<>0) $acFilter $searchFilter $dateFilter $locaFilter ORDER BY RowNo DESC";

      final client = InterceptedHttp.build(interceptors: [SeReportInterceptor()]);
      final uri = Uri.parse(Api.getCardLedger).replace(queryParameters: {'filters': filters});
      final response = await client.get(uri);
      if (response.statusCode != 200) return;
      final raw = jsonDecode(response.body);
      if (!mounted) return;
      setState(() {
        final d = raw is Map ? raw['data'] : raw;
        if (d is Map && d['data'] is List) {
          ledgerData = (d['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
          ledgerData.sort((a, b) => (b['CreateDate'] ?? '').compareTo(a['CreateDate'] ?? ''));
        } else if (d is List) {
          ledgerData = d.map((e) => Map<String, dynamic>.from(e)).toList();
          ledgerData.sort((a, b) => (b['CreateDate'] ?? '').compareTo(a['CreateDate'] ?? ''));
        } else {
          ledgerData = [];
        }
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> printSummaryReport() async {
    try {
      await AccountPrintService.printReport(
        title: 'Card Account Summary',
        ledgerData: accountData,
        numberFormat: nf,
        columns: [
          {'key': 'AcName', 'label': 'Account Name'},
          {'key': 'AcCode', 'label': 'Code'},
          {'key': 'DeductionRate', 'label': 'De.Rate'},
          {'key': 'BalanceAmount', 'label': 'Balance', 'type': 'amount'},
        ],
      );
    } catch (_) {}
  }

  Future<void> printLedgerReport() async {
    final data = _selectedLedgerRows.isNotEmpty
        ? _selectedLedgerRows.map((i) => ledgerData[i]).toList()
        : ledgerData;
    final cols = [
      {'key': 'LocaCode', 'label': 'Loca'},
      {'key': 'CompID', 'label': 'Comp'},
      {'key': 'CreateDate', 'label': 'CreateDate'},
      {'key': 'AcName', 'label': 'Account Name'},
      {'key': 'InvoiceDescription', 'label': 'Description'},
      {'key': 'CreditAmount', 'label': 'Cr.', 'type': 'amount'},
      {'key': 'DebitAmount', 'label': 'Dr.', 'type': 'amount'},
      {'key': 'BalanceAmount', 'label': 'Balance', 'type': 'amount'},
    ];
    await AccountPrintService.printReport(
      title: 'Card Account Ledger',
      ledgerData: data,
      numberFormat: nf,
      columns: cols,
    );
  }

  Future<void> adjustBalance() async {
    if (selectedAcName == null) return;
    try {
      await Api.post(
        url: Api.adjustCardBalance,
        body: {
          'acName': selectedAcName,
          'acCode': selectedAcCode,
          'adjustAmount': adjustAmountCtrl.text,
          'remark': remarkCtrl.text,
          'deductionRate': dRateCtrl.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Balance adjusted successfully'), backgroundColor: Colors.green),
        );
        adjustAmountCtrl.text = '0.00';
        remarkCtrl.clear();
        fetchAccounts();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> depositToBank() async {
    if (selectedAcName == null) return;
    try {
      await Api.post(
        url: Api.depositCardToBank,
        body: {
          'acName': selectedAcName,
          'acCode': selectedAcCode,
          'amount': depAmountCtrl.text,
          'deductionRate': dRateCtrl.text,
          'bankName': selectedBankName ?? '',
          'remark': remarkCtrl.text,
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deposit successful'), backgroundColor: Colors.green),
        );
        depAmountCtrl.text = '0.00';
        depDeductionCtrl.text = '0.00';
        searchBankCtrl.clear();
        setState(() => showDepositPanel = false);
        fetchAccounts();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void showAdjustDialog() {
    if (selectedAcName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select an account from the list first')),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Adjust Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Account: $selectedAcName'),
            const SizedBox(height: 8),
            TextField(
              controller: remarkCtrl,
              decoration: const InputDecoration(labelText: 'Remark', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: adjustAmountCtrl,
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: dRateCtrl,
              decoration: const InputDecoration(labelText: 'Deduction Rate %', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () { Navigator.pop(ctx); adjustBalance(); }, child: const Text('Adjust')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: Appbar(scaffoldKey: scaffoldKey),
      drawer: AppDrawer(),
      floatingActionButton: FloatingActionButton.small(
        onPressed: fetchAccounts,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            if (loading) const LinearProgressIndicator(),
            filterBar(),
            if (showDepositPanel) depositPanel(),
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: 'Summary'),
                  Tab(text: 'Ledger'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSummaryTab(),
                  _buildLedgerTab(),
                ],
              ),
            ),
            statusFooter(),
          ],
        ),
      )
    );
  }

  Widget filterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: Colors.white,
      child: Scrollbar(
        controller: filterScrollCtrl,
        thumbVisibility: true,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: filterScrollCtrl,
        child: Row(
          children: [
            TextButton.icon(
              icon: const Icon(Icons.filter_list, size: 20),
              label: Text('Filters ($activeFilterCount)', style: const TextStyle(fontSize: 14)),
              onPressed: () => showFilterSheet(),
            ),
            if (activeFilterCount > 0) ...[
              if (chkSearch && searchCtrl.text.isNotEmpty)
                _cardFilterChip(searchCtrl.text),
            if (chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty)
              _cardFilterChip('${dateFromCtrl.text}~${dateToCtrl.text}'),
            if (locaCode != 'ALL')
              _cardFilterChip('Loca: $locaCode'),
            ],
            if (activeFilterCount > 0)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  chkSearch = false; chkDate = false; locaCode = 'ALL';
                  searchCtrl.clear(); dateFromCtrl.clear(); dateToCtrl.clear();
                  fetchAccounts();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            if (selectedAcName != null)
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.indigo.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text(selectedAcName!, style: TextStyle(fontSize: 11, color: Colors.indigo.shade700, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(width: 4),
            TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Adjust', style: TextStyle(fontSize: 13)),
              onPressed: showAdjustDialog,
            ),
            const SizedBox(width: 4),
            TextButton.icon(
              icon: Icon(Icons.account_balance, size: 18, color: Colors.green.shade700),
              label: Text('Deposit', style: TextStyle(fontSize: 13, color: Colors.green.shade700)),
              onPressed: () {
                if (selectedAcName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Select an account from the list first')),
                  );
                  return;
                }
                setState(() => showDepositPanel = !showDepositPanel);
              },
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
      ),
      ),
    );
  }

  Widget _cardFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Text(label, style: TextStyle(fontSize: 10, color: Colors.blue.shade700)),
      ),
    );
  }

  void showFilterSheet() {
    final fChkSearch = chkSearch;
    final fChkDate = chkDate;
    final fSearchCtrl = TextEditingController(text: searchCtrl.text);
    final fDateFromCtrl = TextEditingController(text: dateFromCtrl.text);
    final fDateToCtrl = TextEditingController(text: dateToCtrl.text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        var mChkSearch = fChkSearch;
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
                          fSearchCtrl.clear();
                          fDateFromCtrl.text = dateFormat.format(DateTime.now());
                          fDateToCtrl.text = dateFormat.format(DateTime.now());
                          mChkSearch = false;
                          mChkDate = false;
                          setSheetState(() {});
                        }, child: const Text('Clear All')),
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Row(children: [
                    Checkbox(value: mChkSearch, onChanged: (v) => setSheetState(() => mChkSearch = v!)),
                    Expanded(child: TextField(
                      controller: fSearchCtrl,
                      decoration: const InputDecoration(labelText: 'Search Using Account Name', isDense: true, border: OutlineInputBorder()),
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
                        chkSearch = mChkSearch;
                        chkDate = mChkDate;
                        searchCtrl.text = fSearchCtrl.text;
                        dateFromCtrl.text = fDateFromCtrl.text;
                        dateToCtrl.text = fDateToCtrl.text;
                      });
                      Navigator.pop(ctx);
                      Future.delayed(const Duration(milliseconds: 500), () {
                        fSearchCtrl.dispose();
                        fDateFromCtrl.dispose();
                        fDateToCtrl.dispose();
                      });
                      fetchAccounts();
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

  Widget depositPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.blue.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: selectedBankName,
            decoration: const InputDecoration(labelText: 'Bank', isDense: true, border: OutlineInputBorder()),
            items: bankNames.map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (v) => setState(() => selectedBankName = v),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: depAmountCtrl,
            decoration: const InputDecoration(labelText: 'Amount', isDense: true, border: OutlineInputBorder()),
            keyboardType: TextInputType.number,
            onChanged: (_) {
              double amt = double.tryParse(depAmountCtrl.text) ?? 0;
              double rate = double.tryParse(dRateCtrl.text) ?? 0;
              depDeductionCtrl.text = (amt * rate / 100).toStringAsFixed(2);
            },
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Available: ${nf(selectedBalance)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              ElevatedButton(
                onPressed: (selectedBankName != null && (double.tryParse(depAmountCtrl.text) ?? 0) > 0) ? () => depositToBank() : null,
                child: const Text('Confirm Deposit', style: TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: () => setState(() { showDepositPanel = false; selectedBankName = null; }), child: const Text('Cancel', style: TextStyle(fontSize: 13))),
            ],
          ),
        ],
      ),
    );
  }

  Widget accountList() {
    if (accountData.isEmpty) {
      return const Center(child: Text('No accounts', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Card Account Summary (${accountData.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.indigo)),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            itemCount: accountData.length,
            itemBuilder: (ctx, i) {
              final r = accountData[i];
              final code = r['AcCode']?.toString() ?? '';
              final name = r['AcName']?.toString() ?? '';
              final balance = (r['BalanceAmount'] ?? 0).toDouble();
              final dRate = (r['DeductionRate'] ?? 0).toDouble();
              final isSelected = selectedAcName == name;
              return GestureDetector(
                onLongPress: () {
                  setState(() {
                    if (selectedAcName == name) {
                      selectedAcCode = null;
                      selectedAcName = null;
                      selectedBalance = 0;
                      selectedDRate = 0;
                    } else {
                      selectedAcCode = code;
                      selectedAcName = name;
                      selectedBalance = balance;
                      selectedDRate = dRate;
                      dRateCtrl.text = dRate.toStringAsFixed(2);
                    }
                  });
                  fetchLedger();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isSelected
                          ? [Colors.indigo.shade400, Colors.indigo.shade700]
                          : [Colors.blue.shade300, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (isSelected ? Colors.indigo : Colors.blue).withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(nf(balance), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                          ),
                          Text('${dRate.toStringAsFixed(1)}%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget ledgerList() {
    if (ledgerData.isEmpty) {
      return const Center(child: Text('No transactions', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text('Card Account Ledger (${ledgerData.length})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.teal)),
        ),
        Expanded(
          child: PaginatedCardList(
            data: ledgerData,
            emptyMessage: 'No transactions',
            fetchPage: (page, pageSize) async {
              try {
                final searchFilter = chkSearch && searchCtrl.text.isNotEmpty
                    ? "AND AcName LIKE '%${Api.sqlSafe(searchCtrl.text)}%'" : '';
                final dateFilter = chkDate && dateFromCtrl.text.isNotEmpty && dateToCtrl.text.isNotEmpty
                    ? "AND CreateDate BETWEEN '${dateFromCtrl.text}' AND '${dateToCtrl.text}'" : '';
                final locaFilter = locaCode != 'ALL' ? "AND LocaCode='$locaCode'" : '';
                final acFilter = selectedAcCode != null ? "AND AcCode='${Api.sqlSafe(selectedAcCode!)}'" : '';
                final filters = "(CreditAmount<>0 OR DebitAmount<>0) $acFilter $searchFilter $dateFilter $locaFilter ORDER BY RowNo DESC";

                final client = InterceptedHttp.build(interceptors: [SeReportInterceptor()]);
                final uri = Uri.parse(Api.getCardLedger).replace(queryParameters: {
                  'filters': filters,
                  'page': page.toString(),
                  'size': pageSize.toString(),
                });
                final response = await client.get(uri);
                if (response.statusCode != 200) return [];
                final raw = jsonDecode(response.body);
                final d = raw is Map ? raw['data'] : raw;
                List<Map<String, dynamic>> items = [];
                if (d is Map && d['data'] is List) {
                  items = (d['data'] as List).map((e) => Map<String, dynamic>.from(e)).toList();
                } else if (d is List) {
                  items = d.map((e) => Map<String, dynamic>.from(e)).toList();
                }
                items.sort((a, b) => (b['CreateDate'] ?? '').compareTo(a['CreateDate'] ?? ''));
                return items;
              } catch (_) {
                return [];
              }
            },
            pageSize: 20,
            fetchSize: 40,
            cardBuilder: (row, i) {
              final colors = [
                const Color(0xFF1565C0), const Color(0xFFC62828), const Color(0xFF2E7D32),
                const Color(0xFFE65100), const Color(0xFF6A1B9A), const Color(0xFF00838F),
              ];
              return ExpandableLedgerCard(
                row: row,
                accentColor: colors[i % colors.length],
                icon: Icons.credit_card,
                primaryFields: [
                  const CardField(key: 'AcName', label: 'Account', isBold: true, flex: 3),
                  CardField(key: 'CreateDate', label: 'Date', flex: 2),
                  CardField(key: 'CreditAmount', label: 'Cr.', isAmount: true, color: Colors.white70, flex: 2),
                  CardField(key: 'DebitAmount', label: 'Dr.', isAmount: true, color: Colors.white70, flex: 2),
                  CardField(key: 'BalanceAmount', label: 'Balance', isAmount: true, color: Colors.white70, flex: 2),
                ],
                detailFields: [
                  CardField(key: 'LocaCode', label: 'Loca'),
                  CardField(key: 'CompID', label: 'CompID'),
                  CardField(key: 'InvoiceDescription', label: 'Description', flex: 3),
                ],
                numberFormat: nf,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          if (accountData.isNotEmpty)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: accountData.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final r = accountData[i];
                  final code = r['AcCode']?.toString() ?? '';
                  final name = r['AcName']?.toString() ?? '';
                  final balance = (r['BalanceAmount'] ?? 0).toDouble();
                  final dRate = (r['DeductionRate'] ?? 0).toDouble();
                  final loca = r['LocaCode']?.toString() ?? '';
                  final compId = r['CompID']?.toString() ?? '';
                  final isSelected = selectedAcName == name;
                  final colors = [
                    const Color(0xFF1565C0), const Color(0xFFC62828), const Color(0xFF2E7D32),
                    const Color(0xFFE65100), const Color(0xFF6A1B9A), const Color(0xFF00838F),
                  ];
                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        if (selectedAcName == name) {
                          selectedAcCode = null;
                          selectedAcName = null;
                          selectedBalance = 0;
                          selectedDRate = 0;
                        } else {
                          selectedAcCode = code;
                          selectedAcName = name;
                          selectedBalance = balance;
                          selectedDRate = dRate;
                          dRateCtrl.text = dRate.toStringAsFixed(2);
                        }
                      });
                      fetchLedger();
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isSelected
                              ? [Colors.indigo.shade400, Colors.indigo.shade700]
                              : [colors[i % colors.length], colors[i % colors.length].withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.credit_card, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    if (code.isNotEmpty)
                                      Text(code, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(nf(balance), style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (loca.isNotEmpty) _detailChip('Loca', loca),
                              if (compId.isNotEmpty) _detailChip('Comp', compId),
                              const Spacer(),
                              Text('${dRate.toStringAsFixed(1)}%', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (accountData.isEmpty && !loading)
            const Expanded(child: Center(child: Text('No accounts', style: TextStyle(color: Colors.grey)))),
        ],
      ),
    );
  }

  Widget _detailChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label: $value', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10)),
    );
  }

  Widget _buildLedgerTab() {
    return ledgerList();
  }

  Widget statusFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Colors.grey.shade800,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Accounts: ${accountData.length} | Tx: ${ledgerData.length}',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ),
      ),
    );
  }

  void showLedgerDetailSheet(Map<String, dynamic> r) {
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
            Text('Transaction Detail', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            detailRow('Loca', _val(r, 'LocaCode')),
            detailRow('CompID', _val(r, 'CompID')),
            detailRow('CreateDate', _dateShort(_val(r, 'CreateDate'))),
            detailRow('Account Name', _val(r, 'AcName')),
            detailRow('Description', _val(r, 'InvoiceDescription')),
            detailRow('Cr.', nf(r['CreditAmount'] ?? 0)),
            detailRow('Dr.', nf(r['DebitAmount'] ?? 0)),
            detailRow('Balance', nf(r['BalanceAmount'] ?? 0)),
          ],
        ),
      ),
    );
  }

  Widget detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _dateShort(String d) {
    return d.length >= 10 ? d.substring(0, 10) : d;
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

  String nf(dynamic val) {
    double v = (val is double || val is int) ? val.toDouble() : double.tryParse(val.toString()) ?? 0;
    return v.toInt().toString();
  }

  Future<void> pickDate(Function(String) onPicked) async {
    final date = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (date != null) onPicked(dateFormat.format(date));
  }
}
