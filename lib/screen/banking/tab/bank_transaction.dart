// ignore_for_file: use_build_context_synchronously, unused_element, unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_bloc.dart';
import 'package:sereports/bloc/bank_name/bank_name_bloc.dart';
import 'package:sereports/bloc/bank_name/bank_name_event.dart';
import 'package:sereports/bloc/bank_name/bank_name_state.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_event.dart';
import 'package:sereports/bloc/bank_transaction/bank_transaction_state.dart';
import 'package:sereports/constants.dart';

class BankTransaction extends StatefulWidget {
  const BankTransaction({super.key});

  @override
  State<BankTransaction> createState() => _BankTransactionState();
}

class _BankTransactionState extends State<BankTransaction> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedBank = "All";
  String selectedLocation = "All";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<BankBloc>().add(const LoadBankNames());

      context.read<BankTransactionBloc>().add(LoadBankTransactions(
            dateFrom: startDate, // null - will use today's date in BLoC
            dateTo: endDate, // null - will use today's date in BLoC
          ));
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

    // Load more when the user scrolls to 80% of the list
    if (currentScroll >= (maxScroll * 0.8)) {
      final state = context.read<BankTransactionBloc>().state;

      if (state is BankTransactionLoaded &&
          !state.hasReachedMax &&
          !state.isLoadingMore) {
        context.read<BankTransactionBloc>().add(LoadMoreBankTransactions(
              locaCode: state.locaCode,
              bankName: state.bankName,
              searchText: state.searchText,
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
            ));
      }
    }
  }

  // Check if any filters are currently active

  // Format date for display
  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select date";
  }

  // Select date dialog
  void _selectDate(BuildContext context, bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (startDate ?? DateTime.now())
          : (endDate ?? DateTime.now()),
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          _buildTotalAmountCard(),
          Expanded(child: _buildTransactionsList()),
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
            hintText: 'Search transactions...',
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
                    icon: Icon(
                      Icons.clear,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      context.read<BankTransactionBloc>().add(
                            LoadBankTransactions(
                              dateFrom: startDate,
                              dateTo: endDate,
                            ),
                          );
                      setState(() {});
                    },
                  ),
                Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showFilterBottomSheet(context),
                      icon: Icon(
                        Icons.tune,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                    // Show filter indicator if any filters are active
                  ],
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
            if (value.isNotEmpty) {
              print('Search transaction submitted: $value');
              context.read<BankTransactionBloc>().add(
                    SearchBankTransactions(
                      searchText: value,
                      dateFrom: startDate,
                      dateTo: endDate,
                    ),
                  );
            }
          },
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
          },
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return BlocBuilder<BankTransactionBloc, BankTransactionState>(
      builder: (context, state) {
        if (state is BankTransactionLoaded) {
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
                    Icons.account_balance,
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
                        'Total Amount in Bank',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(state.totalAmount),
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
                  Icons.account_balance,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Amount in Bank',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "0.00",
                      style: TextStyle(
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
      },
    );
  }

  Widget _buildTransactionsList() {
    return BlocConsumer<BankTransactionBloc, BankTransactionState>(
      listener: (context, state) {
        if (state is BankTransactionError) {
          // Show snackbar with error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context.read<BankTransactionBloc>().add(LoadBankTransactions(
                        dateFrom: startDate,
                        dateTo: endDate,
                      ));
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BankTransactionInitial ||
            state is BankTransactionLoading) {
          return _buildShimmerList();
        } else if (state is BankTransactionLoaded) {
          if (state.transactions.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<BankTransactionBloc>().add(LoadBankTransactions(
                    dateFrom: startDate,
                    dateTo: endDate,
                  ));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.transactions.length
                  : state.transactions.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.transactions.length) {
                  // Show loading indicator at the bottom only if we're loading more
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: state.isLoadingMore
                          ? _buildShimmerCard()
                          : const SizedBox.shrink(),
                    ),
                  );
                }

                final transaction = state.transactions[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildTransactionCard(transaction, index),
                );
              },
            ),
          );
        } else if (state is BankTransactionError) {
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
            Icons.account_balance_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bank transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or date range',
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
              context.read<BankTransactionBloc>().add(LoadBankTransactions(
                    dateFrom: startDate,
                    dateTo: endDate,
                  ));
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

  Widget _buildTransactionDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildTransactionCard(Map<String, dynamic> transaction, int index) {
    // Alternating card colors: gray for even, white for odd
    final isEven = index % 2 == 0;

    // Format dates
    String formatApiDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        return 'N/A';
      }
    }

    // Format amounts
    String formatAmount(dynamic amount) {
      if (amount == null) return '0.00';
      if (amount is num) {
        return currencyFormatter.format(amount);
      }
      try {
        return currencyFormatter.format(num.parse(amount.toString()));
      } catch (e) {
        print('Error formatting amount $amount: $e');
        return '0.00';
      }
    }

    // Debug - print transaction data
    print('Transaction data: $transaction');

    // Extract transaction details using the actual field names from your API response
    final date = formatApiDate(transaction['createDate']);
    final serialNo = transaction['serialNo'] ?? 'N/A';
    final bank = transaction['bnkName'] ?? 'N/A';
    final branch = transaction['branchName'] ?? 'N/A';

    // Credit or debit amount
    final creditAmount = transaction['creditAmount'] != null
        ? double.tryParse(transaction['creditAmount'].toString()) ?? 0.0
        : 0.0;
    final debitAmount = transaction['debitAmount'] != null
        ? double.tryParse(transaction['debitAmount'].toString()) ?? 0.0
        : 0.0;

    // Total amount
    final totalAmount = transaction['totalAmount'] != null
        ? double.tryParse(transaction['totalAmount'].toString()) ?? 0.0
        : 0.0;

    // Transaction type and status
    final type = transaction['tranType'] ?? transaction['payMode'] ?? 'N/A';
    final status = transaction['status'] ?? 'N/A';

    // Description & reference
    final description = transaction['invoiceDescription'] ?? '';
    final vendorName =
        transaction['venName'] != null && transaction['venName'] != 'Null'
            ? transaction['venName']
            : 'N/A';
    final tranNo = transaction['tranNo'] ?? '';

    // Determine if transaction is credit or debit
    final isCredit = creditAmount > 0;
    final amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;

    // Formatted amount to display
    final amountToShow =
        isCredit ? formatAmount(creditAmount) : formatAmount(debitAmount);

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
          // Transaction header with icon and amount
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCredit ? Icons.trending_up : Icons.trending_down,
                  size: 20,
                  color: amountColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (branch != 'N/A') ...[
                      const SizedBox(height: 2),
                      Text(
                        branch,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  amountToShow,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction details with dividers
          ...[
            if (date != 'N/A') {'label': 'Date', 'value': date},
            {'label': 'Serial No', 'value': serialNo},
            if (vendorName != 'N/A') {'label': 'Vendor', 'value': vendorName},
            if (tranNo.isNotEmpty) {'label': 'Transaction No', 'value': tranNo},
            {'label': 'Total', 'value': formatAmount(totalAmount)},
            {'label': 'Type', 'value': type},
            {'label': 'Status', 'value': status},
            if (description.isNotEmpty)
              {'label': 'Description', 'value': description},
          ].asMap().entries.map((entry) {
            int detailIndex = entry.key;
            Map<String, dynamic> detail = entry.value;

            return Column(
              children: [
                _buildTransactionDetail(detail['label']!, detail['value']!),
                // Add divider except for the last item
                if (detailIndex <
                    [
                          if (date != 'N/A') {'label': 'Date', 'value': date},
                          {'label': 'Serial No', 'value': serialNo},
                          if (vendorName != 'N/A')
                            {'label': 'Vendor', 'value': vendorName},
                          if (tranNo.isNotEmpty)
                            {'label': 'Transaction No', 'value': tranNo},
                          {
                            'label': 'Total',
                            'value': formatAmount(totalAmount)
                          },
                          {'label': 'Type', 'value': type},
                          {'label': 'Status', 'value': status},
                          if (description.isNotEmpty)
                            {'label': 'Description', 'value': description},
                        ].length -
                        1)
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

  void _showFilterBottomSheet(BuildContext context) {
    // Remember current selections for the bottom sheet
    String tempSelectedLocation = selectedLocation;
    String tempSelectedBank = selectedBank;
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
                initialChildSize: 0.75,
                minChildSize: 0.5,
                maxChildSize: 0.95,
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
                                  'Filter Bank Transactions',
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

                          // Location
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
                            items: location,
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
                          const SizedBox(height: 20),

                          // Bank
                          Text(
                            'Bank ID/Ac No',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildBankDropdown(tempSelectedBank, (newValue) {
                            setModalState(() {
                              tempSelectedBank = newValue!;
                            });
                          }),
                          const SizedBox(height: 20),

                          // Date Range
                          Text(
                            'Date Range',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          tempStartDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null) {
                                      setModalState(() {
                                        tempStartDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: grayColorForBorader),
                                      borderRadius:
                                          BorderRadius.circular(radiusValue),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tempStartDate != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(tempStartDate!)
                                              : "From Date",
                                          style: TextStyle(
                                            color: tempStartDate != null
                                                ? Colors.black
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today,
                                            color: grayColorForBorader),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate:
                                          tempEndDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null) {
                                      setModalState(() {
                                        tempEndDate = pickedDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    height: 45,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: grayColorForBorader),
                                      borderRadius:
                                          BorderRadius.circular(radiusValue),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          tempEndDate != null
                                              ? DateFormat('dd/MM/yyyy')
                                                  .format(tempEndDate!)
                                              : "To Date",
                                          style: TextStyle(
                                            color: tempEndDate != null
                                                ? Colors.black
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_today,
                                            color: grayColorForBorader),
                                      ],
                                    ),
                                  ),
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
                                    setModalState(() {
                                      tempSelectedLocation = "All";
                                      tempSelectedBank = "All";
                                      tempStartDate =
                                          null; // Clear date selection
                                      tempEndDate =
                                          null; // Clear date selection
                                    });
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
                                    setState(() {
                                      selectedLocation = tempSelectedLocation;
                                      selectedBank = tempSelectedBank;
                                      startDate = tempStartDate;
                                      endDate = tempEndDate;
                                    });

                                    context.read<BankTransactionBloc>().add(
                                          FilterBankTransactions(
                                            locaCode: tempSelectedLocation,
                                            bankName: tempSelectedBank,
                                            searchText: _searchController.text,
                                            dateFrom: tempStartDate,
                                            dateTo: tempEndDate,
                                          ),
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

  Widget _buildBankDropdown(String currentValue, Function(String?) onChanged) {
    return BlocBuilder<BankBloc, BankState>(
      builder: (context, state) {
        // Prepare the dropdown items based on the BLoC state
        List<DropdownMenuItem<String>> items = [];

        if (state is BankLoading) {
          // Show loading item
          items = [
            DropdownMenuItem<String>(
              value: "All",
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
            ),
          ];
        } else if (state is BankLoaded) {
          // Add the default "All" item
          items = [
            const DropdownMenuItem<String>(
              value: "All",
              child: Text("All Banks"),
            ),
            // Add all bank names from the loaded state
            ...state.bankNames.map((bankName) {
              return DropdownMenuItem<String>(
                value: bankName,
                child: Text(bankName),
              );
            }).toList(),
          ];

          // If the current selection is not in the list, reset to default
          if (!state.bankNames.contains(currentValue) &&
              currentValue != "All") {
            currentValue = "All";
          }
        } else if (state is BankError) {
          // Show error item
          items = [
            DropdownMenuItem<String>(
              value: "All",
              child: Text("Error: ${state.message}",
                  style: TextStyle(color: Colors.red)),
            ),
          ];
        } else {
          // Initial state
          items = [
            const DropdownMenuItem<String>(
              value: "All",
              child: Text("All Banks"),
            ),
          ];
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 45,
          decoration: BoxDecoration(
            border: Border.all(color: grayColorForBorader),
            borderRadius: BorderRadius.circular(radiusValue),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              items: items,
              onChanged: (state is BankLoading) ? null : onChanged,
              isExpanded: true,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }
}
