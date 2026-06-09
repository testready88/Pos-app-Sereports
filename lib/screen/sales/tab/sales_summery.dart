// ignore_for_file: unused_element, deprecated_member_use, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_bloc.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_event.dart';
import 'package:sereports/bloc/sales_summery/sales_summery_state.dart';
import 'package:sereports/constants.dart';

class SalesSummary extends StatefulWidget {
  const SalesSummary({super.key});

  @override
  State<SalesSummary> createState() => _SalesSummaryState();
}

class _SalesSummaryState extends State<SalesSummary> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedLocation = "All";
  String selectedPaymentType = "All";
  DateTime? startDate; // No default dates
  DateTime? endDate; // No default dates

  @override
  void initState() {
    super.initState();

    // Load initial data without date filters
    Future.microtask(() {
      context.read<SalesSummaryBloc>().add(const LoadSalesSummary());
    });

    // Set up scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final scrollPercentage = currentScroll / maxScroll;

    // Load more when the user scrolls to 80% of the list
    if (scrollPercentage >= 0.8) {
      final state = context.read<SalesSummaryBloc>().state;

      if (state is SalesSummaryLoaded &&
          !state.isLoading &&
          !state.hasReachedMax) {
        context.read<SalesSummaryBloc>().add(LoadMoreSalesSummary());
      }
    }
  }

  // Format date for display
  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('dd/MM/yyyy').format(date) : "Select date";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          _buildSummaryCard(),
          Expanded(child: _buildSalesList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 5),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search customer...',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _applySearch();
                    },
                  ),
                IconButton(
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                  icon: Icon(
                    Icons.tune,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ],
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onSubmitted: (value) {
            _applySearch();
          },
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return BlocBuilder<SalesSummaryBloc, SalesSummaryState>(
      builder: (context, state) {
        if (state is SalesSummaryLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50),
                  const Color(0xFF66BB6A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sales Summary',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Net Sales',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(state.netSales),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Net Profit',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(state.profitAfterDiscount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSalesList() {
    return BlocConsumer<SalesSummaryBloc, SalesSummaryState>(
      listener: (context, state) {
        if (state is SalesSummaryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context
                      .read<SalesSummaryBloc>()
                      .add(const LoadSalesSummary(refresh: true));
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SalesSummaryInitial || state is SalesSummaryLoading) {
          return _buildShimmerList();
        } else if (state is SalesSummaryLoaded) {
          print('Loaded state has ${state.salesData.length} items');

          if (state.salesData.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('Refreshing sales summary list');
              context
                  .read<SalesSummaryBloc>()
                  .add(const LoadSalesSummary(refresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.salesData.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  print(
                      'Building SalesSummary ListView - Total items: ${state.salesData.length}, HasReachedMax: ${state.hasReachedMax}');
                }

                if (index >= state.salesData.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: state.isLoading
                        ? _buildShimmerCard()
                        : const SizedBox.shrink(),
                  );
                }

                final sale = state.salesData[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildSaleCard(sale, index),
                );
              },
            ),
          );
        } else if (state is SalesSummaryError) {
          return _buildErrorWidget(state.message);
        }
        return _buildShimmerList();
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10),
        child: _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(
            12,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No sales data found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<SalesSummaryBloc>()
                  .add(const LoadSalesSummary(refresh: true));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, int cardIndex) {
    final isEven = cardIndex % 2 == 0;

    // Format date if available
    String formatApiDate(String? dateStr) {
      if (dateStr == null) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        return 'N/A';
      }
    }

    final createDate = formatApiDate(sale['createDate']);

    // Helper function to check if payment amount is greater than 0
    bool hasPaymentAmount(dynamic amount) {
      if (amount == null) return false;
      double value = 0.0;
      if (amount is num) {
        value = amount.toDouble();
      } else {
        try {
          value = double.parse(amount.toString());
        } catch (e) {
          return false;
        }
      }
      return value > 0.0;
    }

    // Build payment methods list - only include if amount > 0
    List<Map<String, String>> paymentMethods = [];

    if (hasPaymentAmount(sale['cashPayment'])) {
      paymentMethods.add({
        'label': 'Cash Payment',
        'value': currencyFormatter.format(sale['cashPayment'] ?? 0.0)
      });
    }

    if (hasPaymentAmount(sale['cardPayment'])) {
      paymentMethods.add({
        'label': 'Card Payment',
        'value': currencyFormatter.format(sale['cardPayment'] ?? 0.0)
      });
    }

    if (hasPaymentAmount(sale['creditPay'])) {
      paymentMethods.add({
        'label': 'Credit Payment',
        'value': currencyFormatter.format(sale['creditPay'] ?? 0.0)
      });
    }

    if (hasPaymentAmount(sale['chqPayment'])) {
      paymentMethods.add({
        'label': 'Cheque Payment',
        'value': currencyFormatter.format(sale['chqPayment'] ?? 0.0)
      });
    }

    if (hasPaymentAmount(sale['bankPayment'])) {
      paymentMethods.add({
        'label': 'Bank Payment',
        'value': currencyFormatter.format(sale['bankPayment'] ?? 0.0)
      });
    }

    return Container(
      decoration: BoxDecoration(
        color: isEven ? const Color(0xFFE0E0E0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sale header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 20,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sale #${sale['serialNo'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildSaleDetail(
                  'Date',
                  createDate,
                  isRegular: true,
                  isCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildSaleDetail(
                  'Location',
                  sale['locaCode']?.toString() ?? 'N/A',
                  isRegular: true,
                  isCompact: false,
                ),
              ),
            ],
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Serial No
          _buildSaleDetail(
            'Serial No',
            sale['serialNo'] ?? 'N/A',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Total Qty - Prominent styling
          _buildSaleDetail(
            'Total Qty',
            '${sale['tQty'] ?? 0.0}',
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Total Pcs - Prominent styling
          _buildSaleDetail(
            'Total Pcs',
            '${sale['tPcs'] ?? 0.0}',
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Gross Total - Prominent styling
          _buildSaleDetail(
            'Gross Total',
            currencyFormatter.format(sale['gTotal'] ?? 0.0),
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Item Discount - Prominent styling
          _buildSaleDetail(
            'Item Discount',
            currencyFormatter.format(sale['itemDiscount'] ?? 0.0),
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Net Total - Most prominent styling
          _buildSaleDetail(
            'Net Total',
            currencyFormatter.format(sale['nTotal'] ?? 0.0),
            isTotalAmount: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Gross Profit - Prominent styling
          _buildSaleDetail(
            'Gross Profit',
            currencyFormatter.format(sale['gp'] ?? 0.0),
          ),

          // Payment Methods - Only show if amount > 0
          ...paymentMethods
              .map((payment) => Column(
                    children: [
                      Divider(
                          height: 16,
                          thickness: 1,
                          color: Colors.grey.shade200),
                      _buildSaleDetail(
                        payment['label']!,
                        payment['value']!,
                        isPayment: true,
                      ),
                    ],
                  ))
              .toList(),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Ex Charges
          _buildSaleDetail(
            'Ex Charges',
            currencyFormatter.format(sale['exCharges'] ?? 0.0),
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Due Amount - Prominent styling
          _buildSaleDetail(
            'Due Amount',
            currencyFormatter.format(sale['iDueAmount'] ?? 0.0),
          ),

          // Remark (only show if not empty)
          if (sale['remark'] != null &&
              sale['remark'].toString().isNotEmpty) ...[
            Divider(height: 16, thickness: 1, color: Colors.grey.shade200),
            _buildSaleDetail(
              'Remark',
              sale['remark'].toString(),
              isRegular: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSaleDetail(
    String label,
    String value, {
    bool isHighlight = false,
    bool isRegular = false,
    bool isCompact = false,
    bool isTotalAmount = false,
    bool isPayment = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isCompact
          ?
          // Compact layout for location/date row
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2d2d2d),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          :
          // Regular row layout
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: isTotalAmount
                      ? 130
                      : (isHighlight || isPayment ? 120 : 110),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isTotalAmount
                          ? 16
                          : (isHighlight || isPayment ? 15 : 13),
                      fontWeight: isTotalAmount
                          ? FontWeight.w800
                          : (isHighlight || isPayment
                              ? FontWeight.w700
                              : FontWeight.w500),
                      color: isTotalAmount
                          ? const Color(0xFF4CAF50)
                          : (isPayment
                              ? const Color(0xFF2196F3)
                              : (isHighlight
                                  ? const Color(0xFF4CAF50).withOpacity(0.8)
                                  : Colors.grey.shade600)),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isTotalAmount
                          ? 20
                          : (isHighlight || isPayment ? 18 : 14),
                      fontWeight: isTotalAmount
                          ? FontWeight.w900
                          : (isHighlight || isPayment
                              ? FontWeight.w800
                              : FontWeight.w600),
                      color: isTotalAmount || isHighlight || isPayment
                          ? const Color(0xFF1a1a1a)
                          : const Color(0xFF2d2d2d),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
    );
  }

  void _applySearch() {
    if (_searchController.text.trim().isNotEmpty) {
      print('Searching for customer: ${_searchController.text}');
      context
          .read<SalesSummaryBloc>()
          .add(SearchSalesSummary(_searchController.text.trim()));
    } else {
      context.read<SalesSummaryBloc>().add(const LoadSalesSummary());
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final List<String> locations = location;
    final List<String> paymentTypes = [
      'All',
      'Cash',
      'Credit',
      'Card',
      'Cheque',
      'Bank Transfer',
      'Voucher',
      'Advance'
    ];

    // Set local state for the bottom sheet
    String tempSelectedLocation = selectedLocation;
    String tempSelectedPaymentType = selectedPaymentType;
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.only(top: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.5,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with drag handle
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title and close button
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Filter Sales Summary',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Location & Payment Type Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: tempSelectedLocation,
                                      items: locations,
                                      icon: Icons.location_on_outlined,
                                      iconColor: Colors.red,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          // Update both modal and main state immediately
                                          setState(() {
                                            selectedLocation = newValue;
                                            tempSelectedLocation = newValue;
                                          });
                                          setModalState(() {
                                            tempSelectedLocation = newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: tempSelectedPaymentType,
                                      items: paymentTypes,
                                      icon: Icons.payment_outlined,
                                      iconColor: Colors.blue,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          // Update both modal and main state immediately
                                          setState(() {
                                            selectedPaymentType = newValue;
                                            tempSelectedPaymentType = newValue;
                                          });
                                          setModalState(() {
                                            tempSelectedPaymentType = newValue;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Date Range Filter
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date From',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              tempStartDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (pickedDate != null) {
                                          // Update both modal and main state immediately
                                          setState(() {
                                            startDate = pickedDate;
                                            tempStartDate = pickedDate;
                                          });
                                          setModalState(() {
                                            tempStartDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDate(tempStartDate),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: tempStartDate != null
                                                    ? Colors.black87
                                                    : Colors.grey.shade500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
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
                                    Text(
                                      'Date To',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              tempEndDate ?? DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (pickedDate != null) {
                                          // Update both modal and main state immediately
                                          setState(() {
                                            endDate = pickedDate;
                                            tempEndDate = pickedDate;
                                          });
                                          setModalState(() {
                                            tempEndDate = pickedDate;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatDate(tempEndDate),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: tempEndDate != null
                                                    ? Colors.black87
                                                    : Colors.grey.shade500,
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              color: Colors.grey.shade600,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Filter Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    // Reset all filters immediately
                                    setState(() {
                                      selectedLocation = "All";
                                      selectedPaymentType = "All";
                                      startDate = null;
                                      endDate = null;
                                    });
                                    setModalState(() {
                                      tempSelectedLocation = "All";
                                      tempSelectedPaymentType = "All";
                                      tempStartDate = null;
                                      tempEndDate = null;
                                    });
                                    _applyFilters(reset: true);
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.clear_all),
                                  label: const Text('Reset All'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 2,
                                    ),
                                    foregroundColor:
                                        Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    _applyFilters(
                                      location: tempSelectedLocation,
                                      paymentType: tempSelectedPaymentType,
                                      dateFrom: tempStartDate,
                                      dateTo: tempEndDate,
                                    );
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.check),
                                  label: const Text('Apply Filters'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModernFilterDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true,
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
              ],
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  void _applyFilters({
    bool reset = false,
    String? location,
    String? paymentType,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    if (reset) {
      context.read<SalesSummaryBloc>().add(const LoadSalesSummary());
    } else {
      context.read<SalesSummaryBloc>().add(
            FilterSalesSummary(
              searchCustomer: _searchController.text,
              locaCode: location ?? selectedLocation,
              paymentType: paymentType ?? selectedPaymentType,
              dateFrom: dateFrom,
              dateTo: dateTo,
            ),
          );
    }
  }
}
