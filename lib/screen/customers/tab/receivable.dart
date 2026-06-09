// ignore_for_file: unused_element, use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_bloc.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_event.dart';
import 'package:sereports/bloc/customer_receivable/customer_receivable_state.dart';
import 'package:sereports/constants.dart';

class Receivable extends StatefulWidget {
  const Receivable({super.key});

  @override
  State<Receivable> createState() => _ReceivableState();
}

class _ReceivableState extends State<Receivable> {
  final TextEditingController _searchCustomerController =
      TextEditingController();
  final TextEditingController _searchInvoiceController =
      TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedInvGap = "All";
  String selectedLocation = "All";
  DateTime? startDate; // No default date
  DateTime? endDate; // No default date

  @override
  void initState() {
    super.initState();
    print('Receivable screen initialized');

    // DON'T set default dates - let user select them
    // This matches the supplier payable UI behavior

    // Initialize data loading without date filters
    Future.microtask(() {
      print('Loading initial receivables data');
      context.read<ReceivableBloc>().add(LoadReceivables(
            dateFrom: null, // No default date filter
            dateTo: null, // No default date filter
          ));
    });

    // Set up scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCustomerController.dispose();
    _searchInvoiceController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final scrollPercentage = currentScroll / maxScroll;

    // Debug information
    print(
        'Receivable Scroll - Current: $currentScroll, Max: $maxScroll, Percentage: ${(scrollPercentage * 100).toInt()}%');

    // Load more when the user scrolls to 80% of the list
    if (scrollPercentage >= 0.8) {
      final state = context.read<ReceivableBloc>().state;

      if (state is ReceivableLoaded &&
          !state.hasReachedMax &&
          !state.isLoadingMore) {
        print(
            'Triggering LoadMoreReceivables - Current items: ${state.receivables.length}');
        context.read<ReceivableBloc>().add(LoadMoreReceivables(
              searchCustomer: state.searchCustomer,
              searchInvoice: state.searchInvoice,
              locaCode: state.locaCode,
              invGap: state.invGap,
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
            ));
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
          _buildTotalAmountCard(),
          Expanded(child: _buildReceivablesList()),
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
          controller: _searchCustomerController,
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
                if (_searchCustomerController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchCustomerController.clear();
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
    return BlocBuilder<ReceivableBloc, ReceivableState>(
      builder: (context, state) {
        if (state is ReceivableLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF2196F3),
                  const Color(0xFF42A5F5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withOpacity(0.3),
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
                    Icons.receipt_long,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount Receivable',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(state.totalAmount),
                        style: const TextStyle(
                          color: Colors.white,
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

  Widget _buildReceivablesList() {
    return BlocConsumer<ReceivableBloc, ReceivableState>(
      listener: (context, state) {
        if (state is ReceivableError) {
          // Show snackbar with error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context.read<ReceivableBloc>().add(LoadReceivables(
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
        if (state is ReceivableInitial || state is ReceivableLoading) {
          return _buildShimmerList();
        } else if (state is ReceivableLoaded) {
          print('Loaded state has ${state.receivables.length} items');

          if (state.receivables.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('Refreshing receivables list');
              context.read<ReceivableBloc>().add(LoadReceivables(
                    dateFrom: startDate,
                    dateTo: endDate,
                  ));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
                  ? state.receivables.length
                  : state.receivables.length + 1,
              itemBuilder: (context, index) {
                // Add logging to see the exact item count
                if (index == 0) {
                  print(
                      'Building Receivables ListView - Total items: ${state.receivables.length}, HasReachedMax: ${state.hasReachedMax}');
                }

                if (index >= state.receivables.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: state.isLoadingMore
                        ? _buildShimmerCard()
                        : const SizedBox.shrink(),
                  );
                }

                final receivable = state.receivables[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildReceivableCard(receivable, index),
                );
              },
            ),
          );
        } else if (state is ReceivableError) {
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
                    width: 110,
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
            Icons.receipt_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No receivables found',
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
              context.read<ReceivableBloc>().add(LoadReceivables(
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

  Widget _buildReceivableCard(Map<String, dynamic> receivable, int cardIndex) {
    // Alternating card colors: gray for even, white for odd
    final isEven = cardIndex % 2 == 0;

    // Format dates if available
    String formatApiDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return 'N/A';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('dd/MM/yyyy').format(date);
      } catch (e) {
        print('Error formatting date $dateStr: $e');
        return 'N/A';
      }
    }

    // Handle number formatting and null values
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

    // Try multiple field names for each piece of data we want to display

    // Date field: Look for various possible date field names
    String date = 'N/A';
    for (final fieldName in [
      'createDate',
      'date',
      'invoiceDate',
      'createdDate',
      'lastInvoiceDate'
    ]) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        date = formatApiDate(receivable[fieldName]);
        break;
      }
    }

    // Location field: Look for various possible location field names
    String loca = 'N/A';
    for (final fieldName in ['locaCode', 'loca', 'location']) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        loca = receivable[fieldName].toString();
        break;
      }
    }

    // Customer field: Look for various possible customer field names
    String customer = 'N/A';
    for (final fieldName in [
      'cusName',
      'customerName',
      'customer',
      'customerCode'
    ]) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        customer = receivable[fieldName].toString();
        break;
      }
    }

    // Invoice Number field: Look for various possible invoice number field names
    String invoiceNo = 'N/A';
    String serialNo = '';

    // First check for serial number
    for (final fieldName in ['serialNo', 'invoiceSerialNo', 'invoiceSerial']) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        serialNo = receivable[fieldName].toString();
        break;
      }
    }

    // Then check for invoice number
    for (final fieldName in ['invoiceNo', 'invoiceNumber', 'invoice']) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        invoiceNo = receivable[fieldName].toString();
        break;
      }
    }

    // Combine invoice number with serial if available
    final displayInvoiceNo =
        serialNo.isNotEmpty ? '$serialNo (#$invoiceNo)' : invoiceNo;

    // Invoice Amount field: Look for various possible invoice amount field names
    String invoiceAmount = '0.00';
    for (final fieldName in [
      'nTotal',
      'invoiceAmount',
      'lastInvoiceAmount',
      'totalAmount'
    ]) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        invoiceAmount = formatAmount(receivable[fieldName]);
        break;
      }
    }

    // Credit Amount field: Look for various possible credit amount field names
    String creditAmount = '0.00';
    for (final fieldName in [
      'iDueAmount',
      'creditAmount',
      'dueAmount',
      'outstandingAmount',
      'lastPaymentAmount'
    ]) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        creditAmount = formatAmount(receivable[fieldName]);
        break;
      }
    }

    // Invoice Gap field: Look for various possible invoice gap field names
    String invGap = 'N/A';
    for (final fieldName in ['invGap', 'invoiceGap', 'paymentGap']) {
      if (receivable.containsKey(fieldName) && receivable[fieldName] != null) {
        invGap = receivable[fieldName].toString();
        break;
      }
    }

    // Remark field: Look for various possible remark field names
    String remark = '';
    for (final fieldName in [
      'invoiceDescription',
      'remarks',
      'remark',
      'description'
    ]) {
      if (receivable.containsKey(fieldName) &&
          receivable[fieldName] != null &&
          receivable[fieldName].toString().isNotEmpty) {
        remark = receivable[fieldName].toString();
        break;
      }
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
          // Receivable header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  customer,
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

          // Date and Location in one row
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildReceivableDetail(
                  'Date',
                  date,
                  isRegular: true,
                  isCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildReceivableDetail(
                  'Location',
                  loca,
                  isRegular: true,
                  isCompact: false,
                ),
              ),
            ],
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Invoice No
          _buildReceivableDetail(
            'Invoice No',
            displayInvoiceNo,
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Invoice Amount - Prominent styling
          _buildReceivableDetail(
            'Invoice Amount',
            invoiceAmount,
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Credit Amount - Prominent styling
          _buildReceivableDetail(
            'Credit Amount',
            creditAmount,
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Inv. Gap
          _buildReceivableDetail(
            'Inv. Gap',
            '$invGap days',
            isRegular: true,
          ),

          // Remark (only show if not empty)
          if (remark.isNotEmpty) ...[
            Divider(height: 16, thickness: 1, color: Colors.grey.shade200),
            _buildReceivableDetail(
              'Remark',
              remark,
              isRegular: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceivableDetail(
    String label,
    String value, {
    bool isHighlight = false,
    bool isRegular = false,
    bool isCompact = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: isCompact
          ?
          // Compact layout for date/location row
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
                  width: isHighlight ? 120 : 110,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isHighlight ? 15 : 13,
                      fontWeight:
                          isHighlight ? FontWeight.w700 : FontWeight.w500,
                      color: isHighlight
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isHighlight ? 18 : 14,
                      fontWeight:
                          isHighlight ? FontWeight.w800 : FontWeight.w600,
                      color: isHighlight
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
    if (_searchCustomerController.text.trim().isNotEmpty) {
      print('Searching for customer: ${_searchCustomerController.text}');
      context.read<ReceivableBloc>().add(
            SearchReceivables(
              searchCustomer: _searchCustomerController.text.trim(),
              dateFrom: startDate,
              dateTo: endDate,
            ),
          );
    } else {
      context.read<ReceivableBloc>().add(LoadReceivables(
            dateFrom: startDate,
            dateTo: endDate,
          ));
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    // Load locations from your constants or API
    final List<String> locations =
        location; // Assuming 'location' is defined in constants.dart

    // Set local state for the bottom sheet
    String tempSelectedLocation = selectedLocation;
    String tempSelectedInvGap = selectedInvGap;
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    // Create a controller for invoice search
    final invoiceController =
        TextEditingController(text: _searchInvoiceController.text);

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
                initialChildSize: 0.8,
                minChildSize: 0.6,
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
                                  'Filter Receivables',
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

                          // Location & Invoice Gap Row
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
                                          setState(() {
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
                                      'Invoice Gap',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: tempSelectedInvGap,
                                      items: gap,
                                      icon: Icons.schedule_outlined,
                                      iconColor: Colors.orange,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            tempSelectedInvGap = newValue;
                                          });
                                          setModalState(() {
                                            tempSelectedInvGap = newValue;
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

                          // Invoice Number Filter
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Invoice Number',
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
                                  controller: invoiceController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter invoice number',
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
                                        Icons.receipt_outlined,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ),
                                  ),
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
                                          setState(() {
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
                                          setState(() {
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
                                    setState(() {
                                      tempSelectedLocation = "All";
                                      tempSelectedInvGap = "All";
                                      invoiceController.clear();
                                      tempStartDate = null;
                                      tempEndDate = null;
                                    });
                                    setModalState(() {
                                      tempSelectedLocation = "All";
                                      tempSelectedInvGap = "All";
                                      tempStartDate = null;
                                      tempEndDate = null;
                                    });
                                    _applyFilters(reset: true, invoiceNo: '');
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
                                    // Update parent state
                                    setState(() {
                                      selectedLocation = tempSelectedLocation;
                                      selectedInvGap = tempSelectedInvGap;
                                      startDate = tempStartDate;
                                      endDate = tempEndDate;
                                      _searchInvoiceController.text =
                                          invoiceController.text;
                                    });
                                    _applyFilters(
                                      location: tempSelectedLocation,
                                      invGap: tempSelectedInvGap,
                                      dateFrom: tempStartDate,
                                      dateTo: tempEndDate,
                                      invoiceNo: invoiceController.text,
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
    String? invGap,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? invoiceNo,
  }) {
    if (reset) {
      context.read<ReceivableBloc>().add(LoadReceivables(
            dateFrom: null,
            dateTo: null,
          ));
    } else {
      context.read<ReceivableBloc>().add(
            FilterReceivables(
              searchCustomer: _searchCustomerController.text,
              searchInvoice: invoiceNo ?? '',
              locaCode: location ?? selectedLocation,
              invGap: invGap ?? selectedInvGap,
              dateFrom: dateFrom,
              dateTo: dateTo,
            ),
          );
    }
  }
}
