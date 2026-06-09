// ignore_for_file: unused_element, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_bloc.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_event.dart';
import 'package:sereports/bloc/purchase_details/purchase_details_state.dart';
import 'package:sereports/constants.dart';

class PurchaseHistory extends StatefulWidget {
  const PurchaseHistory({super.key});

  @override
  State<PurchaseHistory> createState() => _PurchaseHistoryState();
}

class _PurchaseHistoryState extends State<PurchaseHistory> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  String selectedLocation = "All";
  String selectedPurchaseType = "All";
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    // Load initial data
    context.read<PurchaseHistoryBloc>().add(const LoadPurchaseHistory());

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

    // Load more when the user scrolls to 80% of the list
    if (currentScroll >= (maxScroll * 0.8)) {
      final state = context.read<PurchaseHistoryBloc>().state;

      if (state is PurchaseHistoryLoaded &&
          !state.isLoading &&
          !state.hasReachedMax) {
        context.read<PurchaseHistoryBloc>().add(LoadMorePurchaseHistory());
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
          Expanded(child: _buildPurchaseList()),
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
            hintText: 'Search items...',
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
    return BlocBuilder<PurchaseHistoryBloc, PurchaseHistoryState>(
      builder: (context, state) {
        if (state is PurchaseHistoryLoaded) {
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
                    Icons.shopping_cart,
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
                        'Net Purchase Amount',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(state.netPurchase),
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
                  Icons.shopping_cart,
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
                      'Net Purchase Amount',
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

  Widget _buildPurchaseList() {
    return BlocBuilder<PurchaseHistoryBloc, PurchaseHistoryState>(
      builder: (context, state) {
        if (state is PurchaseHistoryInitial ||
            state is PurchaseHistoryLoading) {
          return _buildShimmerList();
        } else if (state is PurchaseHistoryLoaded) {
          if (state.purchaseData.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PurchaseHistoryBloc>().add(
                    const LoadPurchaseHistory(refresh: true),
                  );
            },
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  state.purchaseData.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.purchaseData.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: _buildShimmerCard(),
                  );
                }

                final purchase = state.purchaseData[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildPurchaseCard(purchase, index),
                );
              },
            ),
          );
        } else if (state is PurchaseHistoryError) {
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
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No purchase history found',
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
              context.read<PurchaseHistoryBloc>().add(
                    const LoadPurchaseHistory(refresh: true),
                  );
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

  Widget _buildPurchaseCard(Map<String, dynamic> purchase, int cardIndex) {
    // Alternating card colors: gray for even, white for odd
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

    final createDate = formatApiDate(purchase['createDate']);

    // Helper function to format discount as percentage
    String formatDiscountPercent(dynamic value) {
      if (value == null) return '0.00%';
      double discountValue =
          (value is String) ? double.tryParse(value) ?? 0.0 : value.toDouble();
      return '${discountValue.toStringAsFixed(2)}%';
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
          // Purchase header with icon
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
                  purchase['itemName']?.toString() ?? 'Unknown Item',
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
                child: _buildPurchaseDetail(
                  'Date',
                  createDate,
                  isRegular: true,
                  isCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildPurchaseDetail(
                  'Location',
                  purchase['locaCode'] ?? 'N/A',
                  isRegular: true,
                  isCompact: false,
                ),
              ),
            ],
          ),
          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Code
          _buildPurchaseDetail(
            'Code',
            purchase['itemCode'] ?? 'N/A',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Qty - Prominent styling
          _buildPurchaseDetail(
            'Qty',
            '${purchase['qty'] ?? 0.0}',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Free Qty
          _buildPurchaseDetail(
            'Free Qty',
            '${purchase['freeQty'] ?? 0.0}',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Dis1 %
          _buildPurchaseDetail(
            'Dis1 %',
            formatDiscountPercent(purchase['itemDis1']),
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Dis2 %
          _buildPurchaseDetail(
            'Dis2 %',
            formatDiscountPercent(purchase['itemDis2']),
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Pur.Price - Prominent styling
          _buildPurchaseDetail(
            'Pur.Price',
            currencyFormatter.format(purchase['itemUPrice'] ?? 0.0),
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Total
          _buildPurchaseDetail(
            'Total',
            currencyFormatter.format(purchase['totalAmount'] ?? 0.0),
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // GP%
          _buildPurchaseDetail(
            'GP%',
            '${(purchase['gpPer'] ?? 0.0).toStringAsFixed(2)}%',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Supplier
          _buildPurchaseDetail(
            'Supplier',
            purchase['itemSupName'] ?? 'N/A',
            isRegular: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseDetail(
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
    if (_searchController.text.isNotEmpty) {
      context
          .read<PurchaseHistoryBloc>()
          .add(SearchPurchaseHistory(_searchController.text.trim()));
    } else {
      context
          .read<PurchaseHistoryBloc>()
          .add(const LoadPurchaseHistory(refresh: true));
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                initialChildSize: 0.85,
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
                                  'Filter Purchase History',
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

                          // Location & Purchase Type
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
                                      value: selectedLocation,
                                      items: location,
                                      icon: Icons.location_on_outlined,
                                      iconColor: Colors.red,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedLocation = newValue;
                                          });
                                          setModalState(() {
                                            selectedLocation = newValue;
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
                                      'Purchase Type',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: selectedPurchaseType,
                                      items: ['All', 'Cash', 'Credit', 'Mixed'],
                                      icon: Icons.payment_outlined,
                                      iconColor: Colors.green,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedPurchaseType = newValue;
                                          });
                                          setModalState(() {
                                            selectedPurchaseType = newValue;
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

                          // Supplier Name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier Name',
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
                                  controller: _supplierController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter supplier name',
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
                                        Icons.business,
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

                          // Category Name
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category Name',
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
                                  controller: _categoryController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter category name',
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
                                        Icons.category_outlined,
                                        color: Colors.purple,
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
                                child: _buildDateSelector(
                                  'From Date',
                                  startDate,
                                  (date) {
                                    setState(() {
                                      startDate = date;
                                    });
                                  },
                                  setModalState,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildDateSelector(
                                  'To Date',
                                  endDate,
                                  (date) {
                                    setState(() {
                                      endDate = date;
                                    });
                                  },
                                  setModalState,
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
                                      selectedLocation = "All";
                                      selectedPurchaseType = "All";
                                      _categoryController.clear();
                                      _supplierController.clear();
                                      startDate = null;
                                      endDate = null;
                                    });
                                    setModalState(() {
                                      selectedLocation = "All";
                                      selectedPurchaseType = "All";
                                      startDate = null;
                                      endDate = null;
                                    });
                                    _applyFilters();
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

  Widget _buildDateSelector(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
    StateSetter setModalState,
  ) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate);
          setModalState(() {}); // Update modal state to show selected date
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                style: TextStyle(
                  fontSize: 14,
                  color: date != null ? Colors.black87 : Colors.grey.shade500,
                  fontWeight:
                      date != null ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    context.read<PurchaseHistoryBloc>().add(
          FilterPurchaseHistory(
            searchItem: _searchController.text,
            searchCategory: _categoryController.text,
            searchSupplier: _supplierController.text,
            locaCode: selectedLocation,
            purchaseType: selectedPurchaseType,
            dateFrom: startDate,
            dateTo: endDate,
          ),
        );
  }
}
