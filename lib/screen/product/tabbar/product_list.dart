// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/category/category_bloc.dart';
import 'package:sereports/bloc/category/category_event.dart';
import 'package:sereports/bloc/category/category_state.dart';
import 'package:sereports/bloc/subcategory/sub_category_bloc.dart';
import 'package:sereports/bloc/subcategory/sub_category_event.dart';
import 'package:sereports/bloc/subcategory/sub_category_state.dart';
import 'package:sereports/bloc/supplier/supplier_bloc.dart';
import 'package:sereports/bloc/supplier/supplier_event.dart';
import 'package:sereports/bloc/supplier/supplier_state.dart';
import 'package:sereports/widget/dropdown/category_dropdown.dart';
import 'package:sereports/widget/dropdown/sub_category_dropdown.dart';
import 'package:sereports/widget/dropdown/supplier_search_dropdown.dart';
import 'package:sereports/bloc/product/product_bloc.dart';
import 'package:sereports/bloc/product/product_event.dart';
import 'package:sereports/bloc/product/product_state.dart';

class ProductListTab extends StatefulWidget {
  const ProductListTab({Key? key}) : super(key: key);

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Level filter values
  final levelOptions = [
    'All',
    'Status Ok',
    'Out Of Stock',
    'Minus stock',
    'Re Order Stock'
  ];
  String selectedLevel = 'All';

  // Discount/Offer filter values
  final offerOptions = [
    'All',
    'Discounted items',
    'L.Discounted Items',
    'Offer items',
    'Wholesale Items',
    'No Discount Items',
    'New Featured',
    'Hot Sales',
    'Day Of The Day'
  ];
  String selectedOffer = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(LoadMoreProducts());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadFilterData() {
    context.read<SupplierBloc>().add(const LoadSuppliers());
    context.read<CategoryBloc>().add(const LoadCategories());
    context.read<SubCategoryBloc>().add(const LoadSubCategories());
  }

  void _performSearch() {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProduct(searchTerm));
    } else {
      context.read<ProductBloc>().add(LoadProducts());
    }
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      selectedLevel = 'All';
      selectedOffer = 'All';
    });

    // Reset all dropdown selections to "All"
    context
        .read<CategoryBloc>()
        .add(SelectCategory(categoryCode: '', categoryName: 'All'));
    context
        .read<SubCategoryBloc>()
        .add(SelectSubCategory(subCategoryCode: '', subCategoryName: 'All'));
    context
        .read<SupplierBloc>()
        .add(SelectSupplier(supplierCode: '', supplierName: 'All'));

    // Reload products without filters
    context.read<ProductBloc>().add(LoadProducts(refresh: true));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          _buildSearchField(),
          _buildProductList(),
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
            hintText: 'Search products...',
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
                      context.read<ProductBloc>().add(LoadProducts());
                    },
                  ),
                IconButton(
                  onPressed: () {
                    _loadFilterData();
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
            if (value.isNotEmpty) {
              context.read<ProductBloc>().add(SearchProduct(value));
            }
          },
          onChanged: (value) {
            setState(() {}); // Rebuild to show/hide clear button
            if (value.isEmpty) {
              context.read<ProductBloc>().add(LoadProducts());
            }
          },
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductInitial || state is ProductLoading) {
          return _buildShimmerList();
        } else if (state is ProductLoaded) {
          return _buildLoadedProductList(state);
        } else if (state is ProductError) {
          return _buildErrorWidget(state.message);
        } else {
          return _buildShimmerList();
        }
      },
    );
  }

  Widget _buildShimmerList() {
    return Expanded(
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 10.0, bottom: 10),
          child: _buildShimmerCard(),
        ),
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

  Widget _buildLoadedProductList(ProductLoaded state) {
    final products = state.products;

    if (products.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No products found',
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
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(LoadProducts(refresh: true));
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount: products.length + (state.hasReachedMax ? 0 : 1),
          itemBuilder: (context, index) {
            if (index >= products.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _buildShimmerCard(),
              );
            }

            final product = products[index];
            return Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10),
              child: _buildProductCard(product, index),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Expanded(
      child: Center(
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
                context.read<ProductBloc>().add(LoadProducts(refresh: true));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// New widget for Location and Stock ID row
  Widget _buildProductCard(Map<String, dynamic> product, int cardIndex) {
    // Alternating card colors: gray for even, white for odd
    final isEven = cardIndex % 2 == 0;

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
          // Product header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product['itemName']?.toString() ?? 'Unknown Product',
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

          // Location and Stock ID in one row
          Row(
            children: [
              Expanded(
                child: _buildProductDetail(
                  'Location',
                  product['locaCode']?.toString() ?? 'N/A',
                  isRegular: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProductDetail(
                  'Stock ID',
                  product['stockId']?.toString() ?? 'N/A',
                  isRegular: true,
                ),
              ),
            ],
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Barcode
          _buildProductDetail(
            'Barcode',
            product['itemBarcode']?.toString() ?? 'N/A',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Quantity - Prominent styling
          _buildProductDetail(
            'Quantity',
            product['qtyRemain']?.toString() ?? 'N/A',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Unit Price - Prominent styling
          _buildProductDetail(
            'Unit Price',
            product['itemUPrice']?.toString() ?? 'N/A',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // MRP - Prominent styling
          _buildProductDetail(
            'MRP',
            product['itemSPrice']?.toString() ?? 'N/A',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Discount Price - Prominent styling
          _buildProductDetail(
            'Discount Price',
            product['itemDPrice']?.toString() ?? 'N/A',
            isHighlight: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Category
          _buildProductDetail(
            'Category',
            product['itemCatName']?.toString() ?? 'N/A',
            isRegular: true,
          ),

          Divider(height: 16, thickness: 1, color: Colors.grey.shade200),

          // Supplier
          _buildProductDetail(
            'Supplier',
            product['itemSupName']?.toString() ?? 'N/A',
            isRegular: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail(
    String label,
    String value, {
    bool isHighlight = false,
    bool isRegular = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isHighlight ? 120 : 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isHighlight ? 15 : 13,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
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
                fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
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
                                  'Filter Products',
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

                          // Category & Subcategory
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
                                    const CategoryDropdown(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sub Category',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const SubCategoryDropdown(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Supplier & Level
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                                    const SupplierDropdown(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stock Level',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    _buildModernFilterDropdown(
                                      value: selectedLevel,
                                      items: levelOptions,
                                      icon: Icons.assessment_outlined,
                                      iconColor: Colors.green,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            selectedLevel = newValue;
                                          });
                                          setModalState(() {
                                            selectedLevel = newValue;
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

                          // Offer Section
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Discounts & Offers',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildModernFilterDropdown(
                                value: selectedOffer,
                                items: offerOptions,
                                icon: Icons.local_offer_outlined,
                                iconColor: Colors.red,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedOffer = newValue;
                                    });
                                    setModalState(() {
                                      selectedOffer = newValue;
                                    });
                                  }
                                },
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
                                    _resetAllFilters();
                                    setModalState(() {
                                      selectedLevel = 'All';
                                      selectedOffer = 'All';
                                    });
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

  void _applyFilters() {
    // Get values from blocs
    final categoryState = context.read<CategoryBloc>().state;
    final subCategoryState = context.read<SubCategoryBloc>().state;
    final supplierState = context.read<SupplierBloc>().state;

    String? categoryName;
    String? subCategoryName;
    String? supplierName;

    if (categoryState is CategoryLoaded) {
      categoryName = categoryState.selectedCategoryName;
    }

    if (subCategoryState is SubCategoryLoaded) {
      subCategoryName = subCategoryState.selectedSubCategoryName;
    }

    if (supplierState is SupplierLoaded) {
      supplierName = supplierState.selectedSupplierName;
    }

    // Convert UI filter values to API expected values
    String? stockLevel;
    if (selectedLevel != 'All') {
      switch (selectedLevel) {
        case 'Status Ok':
          stockLevel = 'statusOk';
          break;
        case 'Out Of Stock':
          stockLevel = 'outOfStock';
          break;
        case 'Minus stock':
          stockLevel = 'minusStock';
          break;
        case 'Re Order Stock':
          stockLevel = 'reOrderStock';
          break;
      }
    }

    String? itemSaleType;
    if (selectedOffer != 'All') {
      switch (selectedOffer) {
        case 'Discounted items':
          itemSaleType = 'discountedItem';
          break;
        case 'L.Discounted Items':
          itemSaleType = 'lDiscountedItem';
          break;
        case 'Offer items':
          itemSaleType = 'offerItem';
          break;
        case 'Wholesale Items':
          itemSaleType = 'wholesaleItems';
          break;
        case 'No Discount Items':
          itemSaleType = 'nodiscountItem';
          break;
        case 'New Featured':
          itemSaleType = 'newFeatured';
          break;
        case 'Hot Sales':
          itemSaleType = 'hotSales';
          break;
        case 'Day Of The Day':
          itemSaleType = 'dayOfTheDay';
          break;
      }
    }

    // Apply filters
    context.read<ProductBloc>().add(
          ApplyFilters(
            searchProduct:
                _searchController.text.isEmpty ? null : _searchController.text,
            categoryName: categoryName,
            subCategoryName: subCategoryName,
            supplierName: supplierName,
            stockLevel: stockLevel,
            itemSaleType: itemSaleType,
          ),
        );
  }
}
