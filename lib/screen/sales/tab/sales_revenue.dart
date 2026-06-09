// ignore_for_file: unused_element, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/sales_details/sales_details_bloc.dart';
import 'package:sereports/bloc/sales_details/sales_details_event.dart';
import 'package:sereports/bloc/sales_details/sales_details_state.dart';
import 'package:sereports/constants.dart';

class SalesRevenue extends StatefulWidget {
  const SalesRevenue({super.key});

  @override
  State<SalesRevenue> createState() => _SalesRevenueState();
}

class _SalesRevenueState extends State<SalesRevenue> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedLocation = "All";
  String selectedSalesType = "All";
  DateTime? startDate; // No default dates
  DateTime? endDate; // No default dates

  @override
  void initState() {
    super.initState();
    print('SalesRevenue screen initialized');

    // Load initial data without date filters
    Future.microtask(() {
      print('Loading initial sales details data');
      context.read<SalesDetailsBloc>().add(const LoadSalesDetails());
    });

    // Set up scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoryController.dispose();
    _supplierController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final scrollPercentage = currentScroll / maxScroll;

    print(
        'SalesRevenue Scroll - Current: $currentScroll, Max: $maxScroll, Percentage: ${(scrollPercentage * 100).toInt()}%');

    // Load more when the user scrolls to 80% of the list
    if (scrollPercentage >= 0.8) {
      final state = context.read<SalesDetailsBloc>().state;

      if (state is SalesDetailsLoaded &&
          !state.isLoading &&
          !state.hasReachedMax) {
        print(
            'Triggering LoadMoreSalesDetails - Current items: ${state.salesData.length}');
        context.read<SalesDetailsBloc>().add(LoadMoreSalesDetails());
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
          _buildRevenueCard(),
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
            hintText: 'Search item...',
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

  Widget _buildRevenueCard() {
    return BlocBuilder<SalesDetailsBloc, SalesDetailsState>(
      builder: (context, state) {
        if (state is SalesDetailsLoaded) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35),
                  const Color(0xFFFF8A50),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
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
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Sales Revenue',
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
                            'Net Revenue',
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
    return BlocConsumer<SalesDetailsBloc, SalesDetailsState>(
      listener: (context, state) {
        if (state is SalesDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () {
                  context
                      .read<SalesDetailsBloc>()
                      .add(const LoadSalesDetails(refresh: true));
                },
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is SalesDetailsInitial || state is SalesDetailsLoading) {
          return _buildShimmerList();
        } else if (state is SalesDetailsLoaded) {
          print('Loaded state has ${state.salesData.length} items');

          if (state.salesData.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              print('Refreshing sales details list');
              context
                  .read<SalesDetailsBloc>()
                  .add(const LoadSalesDetails(refresh: true));
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.salesData.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  print(
                      'Building SalesDetails ListView - Total items: ${state.salesData.length}, HasReachedMax: ${state.hasReachedMax}');
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
        } else if (state is SalesDetailsError) {
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
            10,
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
            Icons.inventory_outlined,
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
                  .read<SalesDetailsBloc>()
                  .add(const LoadSalesDetails(refresh: true));
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
                  color: const Color(0xFFFF6B35).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory,
                  size: 20,
                  color: Color(0xFFFF6B35),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sale['itemName'] ?? 'N/A',
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

          // Location and Date in one row

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Barcode
          _buildSaleDetail(
            'Barcode',
            sale['itemBarcode'] ?? 'N/A',
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Quantity - Prominent styling
          _buildSaleDetail(
            'Quantity',
            '${sale['qty'] ?? 0.0}',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Unit Price - Prominent styling
          _buildSaleDetail(
            'Unit Price',
            currencyFormatter.format(sale['itemUPrice'] ?? 0.0),
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Selling Price - Prominent styling
          _buildSaleDetail(
            'Selling Price',
            currencyFormatter.format(sale['itemSPrice'] ?? 0.0),
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Discount Price - Prominent styling
          _buildSaleDetail(
            'Discount Price',
            currencyFormatter.format(sale['itemDPrice'] ?? 0.0),
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Total Amount - Most prominent styling
          _buildSaleDetail(
            'Total Amount',
            currencyFormatter.format(sale['totalAmount'] ?? 0.0),
            isTotalAmount: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // GP Amount - Prominent styling
          _buildSaleDetail(
            'GP Amount',
            currencyFormatter.format(sale['gpAmount'] ?? 0.0),
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
                  width: isTotalAmount ? 130 : (isHighlight ? 120 : 110),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: isTotalAmount ? 16 : (isHighlight ? 15 : 13),
                      fontWeight: isTotalAmount
                          ? FontWeight.w800
                          : (isHighlight ? FontWeight.w700 : FontWeight.w500),
                      color: isTotalAmount
                          ? const Color(0xFFFF6B35)
                          : (isHighlight
                              ? const Color(0xFFFF6B35).withOpacity(0.8)
                              : Colors.grey.shade600),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: isTotalAmount ? 20 : (isHighlight ? 18 : 14),
                      fontWeight: isTotalAmount
                          ? FontWeight.w900
                          : (isHighlight ? FontWeight.w800 : FontWeight.w600),
                      color: isTotalAmount
                          ? const Color(0xFF1a1a1a)
                          : (isHighlight
                              ? const Color(0xFF1a1a1a)
                              : const Color(0xFF2d2d2d)),
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
      print('Searching for item: ${_searchController.text}');
      context
          .read<SalesDetailsBloc>()
          .add(SearchSalesDetails(_searchController.text.trim()));
    } else {
      context.read<SalesDetailsBloc>().add(const LoadSalesDetails());
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    final List<String> locations = location;
    final List<String> salesTypes = [
      'All',
      'Retail',
      'Discounted',
      'Wholesale',
      'Free',
      'Invoice Return',
      'Damage Return',
      'Under Cost'
    ];

    // Set local state for the bottom sheet
    String tempSelectedLocation = selectedLocation;
    String tempSelectedSalesType = selectedSalesType;
    DateTime? tempStartDate = startDate;
    DateTime? tempEndDate = endDate;

    // Create controllers for category and supplier
    final tempCategoryController =
        TextEditingController(text: _categoryController.text);
    final tempSupplierController =
        TextEditingController(text: _supplierController.text);

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
                                  color:
                                      const Color(0xFFFF6B35).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.tune,
                                  color: Color(0xFFFF6B35),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Filter Sales Revenue',
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

                          // Location & Sales Type Row
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
                                      'Sales Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: tempSelectedSalesType,
                                      items: salesTypes,
                                      icon: Icons.point_of_sale_outlined,
                                      iconColor: Colors.blue,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          // Update both modal and main state immediately
                                          setState(() {
                                            selectedSalesType = newValue;
                                            tempSelectedSalesType = newValue;
                                          });
                                          setModalState(() {
                                            tempSelectedSalesType = newValue;
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

                          // Category & Supplier Search Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Category',
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: TextField(
                                        controller: tempCategoryController,
                                        decoration: InputDecoration(
                                          hintText: 'Search category',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          prefixIcon: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.category_outlined,
                                              color: Colors.purple,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          // Update main state immediately
                                          setState(() {
                                            _categoryController.text = value;
                                          });
                                        },
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
                                      'Supplier',
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.white,
                                      ),
                                      child: TextField(
                                        controller: tempSupplierController,
                                        decoration: InputDecoration(
                                          hintText: 'Search supplier',
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          prefixIcon: Container(
                                            padding: const EdgeInsets.all(12),
                                            child: Icon(
                                              Icons.business_outlined,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        onChanged: (value) {
                                          // Update main state immediately
                                          setState(() {
                                            _supplierController.text = value;
                                          });
                                        },
                                      ),
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
                                      selectedSalesType = "All";
                                      _categoryController.clear();
                                      _supplierController.clear();
                                      startDate = null;
                                      endDate = null;
                                    });
                                    setModalState(() {
                                      tempSelectedLocation = "All";
                                      tempSelectedSalesType = "All";
                                      tempCategoryController.clear();
                                      tempSupplierController.clear();
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
                                      salesType: tempSelectedSalesType,
                                      category: tempCategoryController.text,
                                      supplier: tempSupplierController.text,
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
    String? salesType,
    String? category,
    String? supplier,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    if (reset) {
      context.read<SalesDetailsBloc>().add(const LoadSalesDetails());
    } else {
      context.read<SalesDetailsBloc>().add(
            FilterSalesDetails(
              searchItem: _searchController.text,
              searchCategory: category ?? _categoryController.text,
              searchSupplier: supplier ?? _supplierController.text,
              locaCode: location ?? selectedLocation,
              salesType: salesType ?? selectedSalesType,
              dateFrom: dateFrom,
              dateTo: dateTo,
            ),
          );
    }
  }
}
