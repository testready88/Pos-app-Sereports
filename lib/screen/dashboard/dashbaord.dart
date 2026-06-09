// ignore_for_file: unused_element, avoid_print, avoid_unnecessary_containers, use_build_context_synchronously, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sereports/bloc/dashboard/dashboard_bloc.dart';
import 'package:sereports/bloc/dashboard/dashboard_event.dart';
import 'package:sereports/bloc/dashboard/dashboard_state.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/repository/auth_repo.dart';
import 'package:sereports/utils/sesstion_manager.dart';
import 'package:sereports/utils/shimmerEffect/shimmer.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/balance.dart';
import 'package:sereports/widget/bottomsheet.dart';
import 'package:sereports/widget/cash_in_hand.dart';
import 'package:sereports/widget/custom_bottom_nav_bar.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/widget/finacial_overview.dart';
import 'package:sereports/widget/plcard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashbaordScreen extends StatefulWidget {
  const DashbaordScreen({super.key});

  @override
  State<DashbaordScreen> createState() => _DashbaordScreenState();
}

class _DashbaordScreenState extends State<DashbaordScreen> {
  String selectedDateRange = "Today";
  String selectedLocation = "All";
  DateTime? startDate;
  DateTime? endDate;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SessionManager _sessionManager;
  late DashboardBloc _dashboardBloc;

  @override
  void initState() {
    super.initState();
    _initSessionManager();
    _initDashboardBloc();
  }

  Future<void> _initSessionManager() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _sessionManager = SessionManager(preferences);
    _sessionManager.startSessionMonitoring();

    AuthRepo authRepo = AuthRepo(preferences);
    bool isValid = await authRepo.isLoggedIn();
    if (!isValid && mounted) {
      authRepo.logout(context);
    } else {
      await authRepo.loadPermissions();
    }
  }

  void _initDashboardBloc() {
    _dashboardBloc = BlocProvider.of<DashboardBloc>(context);
    _fetchDashboardData();
  }

  void _fetchDashboardData() {
    final now = DateTime.now();
    String dateFrom;
    String dateTo;

    switch (selectedDateRange) {
      case "Today":
        dateFrom = DateFormat('yyyy-MM-dd').format(now);
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case "Yesterday":
        final yesterday = now.subtract(const Duration(days: 1));
        dateFrom = DateFormat('yyyy-MM-dd').format(yesterday);
        dateTo = DateFormat('yyyy-MM-dd').format(yesterday);
        break;
      case "Last 7 Days":
        dateFrom = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 6)));
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case "Last 30 Days":
        dateFrom = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 29)));
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case "This Month":
        dateFrom = DateFormat('yyyy-MM-01').format(now);
        dateTo = DateFormat('yyyy-MM-dd').format(now);
        break;
      case "Last Month":
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        dateFrom = DateFormat('yyyy-MM-dd').format(lastMonth);
        dateTo = DateFormat('yyyy-MM-dd').format(lastDayOfLastMonth);
        break;
      case "Custom":
        dateFrom = startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : DateFormat('yyyy-MM-dd').format(now);
        dateTo = endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : DateFormat('yyyy-MM-dd').format(now);
        break;
      default:
        dateFrom = DateFormat('yyyy-MM-dd').format(now);
        dateTo = DateFormat('yyyy-MM-dd').format(now);
    }

    _dashboardBloc.add(FetchDashboardSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
      locationCode: selectedLocation,
    ));
  }

  @override
  void dispose() {
    _sessionManager.stopSessionMonitoring();
    super.dispose();
  }

  void _selectDate(BuildContext context, bool isStartDate) async {
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

      if (selectedDateRange == "Custom" && startDate != null && endDate != null) {
        _fetchDashboardData();
      }
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select date";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      key: _scaffoldKey,
      drawer: AppDrawer(),
      bottomNavigationBar: CustomBottomNavBar(currentPage: NavigationPage.dashboard),
      appBar: Appbar(scaffoldKey: _scaffoldKey),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            filterOption(context),
            BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoading) {
                  return Expanded(child: DashboardShimmer.dashboardShimmer(context));
                } else if (state is DashboardError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                        SizedBox(height: 16),
                        Text('Error: ${state.message}', style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchDashboardData,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is DashboardLoaded) {
                  final data = state.dashboardData;
                  final salesSummary = data['salesSummary'] as Map<String, dynamic>? ?? {};
                  final purchaseSummary = data['purchaseSummary'] as Map<String, dynamic>? ?? {};
                  final otherIncomeExpense = data['otherIncomeExpense'] as Map<String, dynamic>? ?? {};
                  final stockSummary = data['stockSummary'] as Map<String, dynamic>? ?? {};
                  final balanceSheet = data['balanceSheet'] as Map<String, dynamic>? ?? {};
                  final formatter = NumberFormat("#,##0.00", "en_US");

                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Financial Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: LayoutBuilder(builder: (context, constraints) {
                            double width = constraints.maxWidth;
                            double cardWidth = width > 600 ? 250 : 200;
                            double cardHeight = width > 600 ? 120 : 100;

                            return Row(
                              children: [
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Net Sales', cost: formatter.format(salesSummary['netSales'] ?? 0.0),
                                  iconPath: 'assets/icons/netsale.png', color: Color(0xFF1976D2),
                                  viewMoreText: 'View More', cardType: FinancialCardType.netSales, data: salesSummary,
                                ),
                                SizedBox(width: 10),
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Net Profit', cost: formatter.format(salesSummary['profitAfterDiscount'] ?? 0.0),
                                  iconPath: 'assets/icons/netprofit.png', color: Color(0xFF2E7D32),
                                  viewMoreText: 'View More', cardType: FinancialCardType.netProfit, data: salesSummary,
                                ),
                                SizedBox(width: 10),
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Net Purchase', cost: formatter.format(purchaseSummary['netPurchase'] ?? 0.0),
                                  iconPath: 'assets/icons/netpurchase.png', color: Color(0xFFD8A713),
                                  viewMoreText: 'View More', cardType: FinancialCardType.netPurchase, data: purchaseSummary,
                                ),
                                SizedBox(width: 10),
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Other Income', cost: formatter.format(otherIncomeExpense['otherIncome'] ?? 0.0),
                                  iconPath: 'assets/icons/income.png', color: Color(0xFFFF9800),
                                  viewMoreText: 'View More', cardType: FinancialCardType.otherIncome, data: otherIncomeExpense,
                                ),
                                SizedBox(width: 10),
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Other Expenses', cost: formatter.format(otherIncomeExpense['otherExpenses'] ?? 0.0),
                                  iconPath: 'assets/icons/expences.png', color: Color(0xFFD32F2F),
                                  viewMoreText: 'View More', cardType: FinancialCardType.otherExpenses, data: otherIncomeExpense,
                                ),
                                SizedBox(width: 10),
                                FinacialOverview(
                                  cardHeight: cardHeight, cardWidth: cardWidth,
                                  title: 'Stock Value', cost: formatter.format(stockSummary['costValue'] ?? 0.0),
                                  iconPath: 'assets/icons/stock.png', color: Color(0xFF9C27B0),
                                  viewMoreText: 'View More', cardType: FinancialCardType.stockValue, data: stockSummary,
                                ),
                              ],
                            );
                          }),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildAmountCards(balanceSheet),
                              const SizedBox(height: 16),
                              PLAccountCard(salesSummary: salesSummary, purchaseSummary: purchaseSummary, otherIncomeExpense: otherIncomeExpense),
                              const SizedBox(height: 16),
                              BalanceSheetCard(balanceSheet: balanceSheet),
                              const SizedBox(height: 16),
                              CashInHandCard(cashInHand: balanceSheet['cashInHand'] ?? 0.0),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Expanded(child: DashboardShimmer.dashboardShimmer(context));
              },
            ),
          ],
        ),
      ),
    );
  }

  Column filterOption(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() { selectedLocation = newValue!; });
                          _fetchDashboardData();
                        },
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        value: selectedDateRange,
                        items: dateRanges.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            selectedDateRange = newValue!;
                            if (selectedDateRange != "Custom") {
                              startDate = null;
                              endDate = null;
                              _fetchDashboardData();
                            }
                          });
                        },
                        isExpanded: true,
                        icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (selectedDateRange == "Custom")
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Date From:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: grayColorForBorader),
                          borderRadius: BorderRadius.circular(radiusValue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(startDate), style: TextStyle(color: Colors.black)),
                            const Icon(Icons.calendar_today, color: grayColorForBorader),
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
                    const Text('Date To:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: grayColorForBorader),
                          borderRadius: BorderRadius.circular(radiusValue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatDate(endDate), style: TextStyle(color: Colors.black)),
                            const Icon(Icons.calendar_today, color: grayColorForBorader),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildAmountCards(Map<String, dynamic> balanceSheet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;

        List<Widget> cards = [
          _buildAmountCard('assets/icons/paybaleamount.png', 'Amount Payable', balanceSheet['amountPayable'] ?? 0.0, Color(0xFFD43434)),
          _buildAmountCard('assets/icons/receivable.png', 'Amount Receivable', balanceSheet['amountReceivable'] ?? 0.0, Color.fromARGB(255, 96, 187, 114)),
          _buildAmountCard('assets/icons/chqpayable.png', 'CHQ Payable', balanceSheet['chqPayable'] ?? 0.0, Color(0xFFD43434)),
          _buildAmountCard('assets/icons/chqreceiavble.png', 'CHQ Receivable', balanceSheet['chqReceivable'] ?? 0.0, Color.fromARGB(255, 96, 187, 114)),
        ];

        if (isTablet) {
          return Column(
            children: [
              Row(children: [Expanded(child: cards[0]), SizedBox(width: 16), Expanded(child: cards[1])]),
              SizedBox(height: 16),
              Row(children: [Expanded(child: cards[2]), SizedBox(width: 16), Expanded(child: cards[3])]),
            ],
          );
        } else {
          return Column(children: [for (var card in cards) ...[card, SizedBox(height: 10)]]);
        }
      },
    );
  }

  Widget _buildAmountCard(String icon, String title, double amount, Color color) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    final formattedAmount = formatter.format(amount);

    return Container(
      height: 80,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              child: Image.asset(icon, fit: BoxFit.cover, gaplessPlayback: true, height: 40, width: 40),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(formattedAmount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}