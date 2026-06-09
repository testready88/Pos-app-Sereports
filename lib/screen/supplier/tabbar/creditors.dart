// ignore_for_file: deprecated_member_use, curly_braces_in_flow_control_structures, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_bloc.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_event.dart';
import 'package:sereports/bloc/supplier_creditor/creditor_state.dart';

class Creditors extends StatefulWidget {
  const Creditors({super.key});

  @override
  State<Creditors> createState() => _CreditorsState();
}

class _CreditorsState extends State<Creditors> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _creditAmountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedInvGap = "All";
  String selectedSettlementGap = "All";

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<CreditorBloc>().add(const LoadCreditors());

    // Set up scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _creditAmountController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Load more when the user scrolls to 80% of the list
    if (currentScroll >= (maxScroll * 0.8)) {
      final state = context.read<CreditorBloc>().state;

      if (state is CreditorLoaded && !state.isLoading && !state.hasReachedMax) {
        context.read<CreditorBloc>().add(LoadMoreCreditors());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          _buildTotalAmountCard(),
          Expanded(child: _buildCreditorsList()),
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
            hintText: 'Search creditors...',
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

  Widget _buildTotalAmountCard() {
    return BlocBuilder<CreditorBloc, CreditorState>(
      builder: (context, state) {
        if (state is CreditorLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD8A713),
                  const Color(0xFFE6B91A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD8A713).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount Payable',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(state.totalOutstandingAmount),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCreditorsList() {
    return BlocBuilder<CreditorBloc, CreditorState>(
      builder: (context, state) {
        if (state is CreditorInitial || state is CreditorLoading) {
          return _buildShimmerList();
        } else if (state is CreditorLoaded) {
          if (state.creditors.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<CreditorBloc>()
                  .add(const LoadCreditors(refresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.creditors.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.creditors.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _buildShimmerCard(),
                  );
                }

                final creditor = state.creditors[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildCreditorCard(creditor, index),
                );
              },
            ),
          );
        } else if (state is CreditorError) {
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
            8,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 80,
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
            Icons.credit_card_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No creditors found',
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
                  .read<CreditorBloc>()
                  .add(const LoadCreditors(refresh: true));
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

  Widget _buildCreditorCard(Map<String, dynamic> creditor, int cardIndex) {
    // Alternating card colors: gray for even, white for odd
    final isEven = cardIndex % 2 == 0;

    // Format dates
    String formatDate(String? dateStr) {
      if (dateStr == null) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        return 'N/A';
      }
    }

    // Parse dates from creditor
    final lastInvDate = formatDate(creditor['lastInvDate']);
    final lastPayDate = formatDate(creditor['lastPayDate']);

    // Create list of creditor details
    final List<Map<String, String>> creditorDetails = [
      {'label': 'ID', 'value': creditor['supUniqID']?.toString() ?? 'N/A'},
      {
        'label': 'Creditor Name',
        'value': creditor['supName']?.toString() ?? 'N/A'
      },
      {
        'label': 'Outstanding',
        'value': currencyFormatter.format(creditor['outstandingAmount'] ?? 0.0)
      },
      {
        'label': 'Address',
        'value': creditor['addressDetails']?.toString() ?? 'N/A'
      },
      {
        'label': 'Contact',
        'value': creditor['contactDetails']?.toString() ?? 'N/A'
      },
      {'label': 'Last Inv Date', 'value': lastInvDate},
      {'label': 'Last Paid Date', 'value': lastPayDate},
      {
        'label': 'Last Paid Amount',
        'value': currencyFormatter.format(creditor['lastPayAmount'] ?? 0.0)
      },
      {
        'label': 'Payment Gap',
        'value': '${creditor['paymentGap'] ?? 'N/A'} days'
      },
    ];

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
          // Creditor header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.credit_card,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  creditor['supName']?.toString() ?? 'Unknown Creditor',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Creditor details with dividers
          ...creditorDetails.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, String> detail = entry.value;

            // Skip creditor name as it's already shown in header
            if (detail['label'] == 'Creditor Name')
              return const SizedBox.shrink();

            return Column(
              children: [
                _buildCreditorDetail(detail['label']!, detail['value']!),
                // Add divider except for the last item
                if (index < creditorDetails.length - 1)
                  Divider(
                    height: 16,
                    thickness: 1,
                    color: Colors.grey.shade200,
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCreditorDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2d2d2d),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _applySearch() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      context.read<CreditorBloc>().add(SearchCreditor(searchText));
    } else {
      context.read<CreditorBloc>().add(const LoadCreditors(refresh: true));
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final List<String> gapOptions = [
      'All',
      '0 to 10 Days',
      '10 to 20 Days',
      '20 to 30 Days',
      'Above 30 Days',
      'Above 60 Days',
      'Above 90 Days',
      'Above 180 Days',
    ];

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
                maxChildSize: 0.85,
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
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.tune,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Filter Creditors',
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

                          // Credit Amount Filter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Credit Amount >=',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  controller: _creditAmountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter minimum credit amount',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 14,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    prefixIcon: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        Icons.attach_money,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Invoice Gap & Settlement Gap
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Invoice Gap',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: selectedInvGap,
                                      items: gapOptions,
                                      icon: Icons.schedule_outlined,
                                      iconColor: Colors.blue,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedInvGap = newValue;
                                          });
                                          setModalState(() {
                                            selectedInvGap = newValue;
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
                                      'Settlement Gap',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: selectedSettlementGap,
                                      items: gapOptions,
                                      icon: Icons.payment_outlined,
                                      iconColor: Colors.orange,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedSettlementGap = newValue;
                                          });
                                          setModalState(() {
                                            selectedSettlementGap = newValue;
                                          });
                                        }
                                      },
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
                                    setState(() {
                                      selectedInvGap = "All";
                                      selectedSettlementGap = "All";
                                      _creditAmountController.clear();
                                    });
                                    setModalState(() {
                                      selectedInvGap = "All";
                                      selectedSettlementGap = "All";
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
                                    _applyFilters();
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

  void _applyFilters({bool reset = false}) {
    if (reset) {
      context.read<CreditorBloc>().add(const LoadCreditors(refresh: true));
    } else {
      context.read<CreditorBloc>().add(
            FilterCreditors(
              supplierSearch: _searchController.text,
              creditAmount: _creditAmountController.text,
              invGap: selectedInvGap,
              settlementGap: selectedSettlementGap,
            ),
          );
    }
  }
}
