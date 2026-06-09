// ignore_for_file: unnecessary_brace_in_string_interps, curly_braces_in_flow_control_structures, unnecessary_to_list_in_spreads, unused_element

import 'dart:async';
import 'dart:convert';
import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_bloc.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_state.dart';
import 'package:sereports/model/invoiceitem.dart';
import 'package:sereports/model/item_detail_model.dart';
import 'package:sereports/model/price_link_model.dart';
import 'package:sereports/model/calculate_price_model.dart';
import 'package:sereports/bloc/invoice_create/invoice_create_event.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/bloc/product/product_bloc.dart';
import 'package:sereports/bloc/product/product_event.dart';
import 'package:sereports/bloc/product/product_state.dart';
import 'package:sereports/repository/invoice_create_repo.dart';
import 'package:sereports/repository/customer_repo.dart';
import 'package:sereports/repository/user_repo.dart';
import 'package:sereports/model/cheque_payment_dto.dart';
import 'package:sereports/model/card_payment_dto.dart';
import 'package:sereports/model/bank_transfer_dto.dart';
import 'package:sereports/service/pdf_invoice_service.dart';
import 'package:shimmer/shimmer.dart';

class InvoiceCreationScreen extends StatefulWidget {
  final Map<String, dynamic>? heldInvoiceData;

  const InvoiceCreationScreen({super.key, this.heldInvoiceData});

  @override
  State<InvoiceCreationScreen> createState() => _InvoiceCreationScreenState();
}

class _InvoiceCreationScreenState extends State<InvoiceCreationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _barcodeController = TextEditingController();
  final TextEditingController _customerSearchController =
      TextEditingController();

  final _scrollController = ScrollController();
  final ScrollController _itemListController = ScrollController();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");

  late InvoiceCreationBloc _bloc;
  StreamSubscription? _connectivitySub;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;

  // Product search variables
  bool _showProductDropdown = false;

  // Customer selection
  String? _selectedCustomerCode;
  String? _selectedCustomerName;
  String? _selectedCustomerPriceCategory; // Price category from customer
  double? _selectedCustomerBalance; // Customer outstanding balance
  bool _showCustomerDropdown = false;
  List<dynamic> _customerSearchResults = [];

  // Price category selection (when no customer selected)
  String? _selectedPriceCategory = 'RETAIL'; // Default to RETAIL

  // Store payment info for printing
  BigDecimal? _lastCashPaid;
  String? _lastPaymentType;

  // Store invoice items before submission for printing
  List<InvoiceItem>? _lastSubmittedItems;
  BigDecimal? _lastSubmittedGrandTotal;

  // Last invoice price for Add Item dialog (from product search selection)
  Map<String, dynamic>? _lastInvPriceData;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<InvoiceCreationBloc>();

    // Load held invoice data if provided (delay ScaffoldMessenger calls until after first frame)
    if (widget.heldInvoiceData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadHeldInvoiceData(widget.heldInvoiceData!);
      });
    } else {
      // Initialize invoice - customer will be selected by user
      _bloc.add(InitializeInvoiceCreation(
        customerCode: '',
        customerName: '',
      ));
    }
    _scrollController.addListener(_onScroll);
    // Load products for search
    context.read<ProductBloc>().add(LoadProducts());

    _setupConnectivityListener();
    _barcodeController.addListener(_onSearchProductChanged);
    _customerSearchController.addListener(_onSearchCustomerChanged);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _customerSearchController.dispose();
    _itemListController.dispose();
    _connectivitySub?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ProductBloc>().add(LoadMoreProducts());
    }
  }

  /// Load held invoice data into the invoice creation screen
  void _loadHeldInvoiceData(Map<String, dynamic> invoiceData) {
    if (!mounted) return;

    try {
      // Extract customer info
      final customerCode = invoiceData['customerCode'] as String? ?? '';
      final customerName = invoiceData['customerName'] as String? ?? '';

      // Set customer selection
      setState(() {
        _selectedCustomerCode = customerCode;
        _selectedCustomerName = customerName;
        _customerSearchController.text = customerName;
      });

      // Parse items - handle both string and num types
      final itemsJson = invoiceData['items'] as String?;
      if (itemsJson != null) {
        final itemsList = jsonDecode(itemsJson) as List<dynamic>;
        final invoiceItems = itemsList.map((item) {
          // Helper function to safely parse numeric values (handles both string and num)
          num? parseNum(dynamic value) {
            if (value == null) return null;
            if (value is num) return value;
            if (value is String) {
              final parsed = num.tryParse(value);
              return parsed;
            }
            return null;
          }

          return InvoiceItem(
            itemCode: item['itemCode']?.toString() ?? '',
            itemBarcode: item['itemBarcode']?.toString() ?? '',
            itemName: item['itemName']?.toString() ?? '',
            stockId: item['stockId']?.toString() ?? '',
            qty: (parseNum(item['qty'])?.toInt()) ?? 1,
            itemUPrice: BigDecimal.parse(
                (parseNum(item['itemUPrice']) ?? 0).toString()),
            itemSPrice: BigDecimal.parse(
                (parseNum(item['itemSPrice']) ?? 0).toString()),
            itemDPrice: BigDecimal.parse(
                (parseNum(item['itemDPrice']) ?? 0).toString()),
            tPrice:
                BigDecimal.parse((parseNum(item['tPrice']) ?? 0).toString()),
            invType: item['invType']?.toString() ?? 'STD',
            priceCategory: item['priceCategory']?.toString() ?? 'RETAIL',
          );
        }).toList();

        // Add items to invoice
        for (var item in invoiceItems) {
          _bloc.add(AddItemToInvoice(item));
        }
      }

      // Initialize invoice with customer
      _bloc.add(InitializeInvoiceCreation(
        customerCode: customerCode,
        customerName: customerName,
      ));

      // Show success message - only after widget is mounted and built
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Held invoice loaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error loading held invoice data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading held invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupConnectivityListener() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      setState(() {
        _connectionStatus =
            result.isNotEmpty ? result.first : ConnectivityResult.none;
      });
    });
  }

  /// Called when user types in the search field
  void _onSearchProductChanged() {
    final searchText = _barcodeController.text.trim();

    if (searchText.isEmpty) {
      setState(() {
        _showProductDropdown = false;
      });
      // Reload all products when search is cleared
      context.read<ProductBloc>().add(LoadProducts());
      return;
    }

    // Use ProductBloc to search products (similar to product_list.dart)
    context.read<ProductBloc>().add(SearchProduct(searchText));
    setState(() {
      _showProductDropdown = true;
    });
  }

  /// Called when user types in the customer search field
  void _onSearchCustomerChanged() async {
    final searchText = _customerSearchController.text.trim();

    if (searchText.isEmpty) {
      setState(() {
        _showCustomerDropdown = false;
        _customerSearchResults = [];
      });
      return;
    }

    try {
      final customerRepo = CustomerRepo();
      final response = await customerRepo.getCustomerDetails(
        page: 0,
        size: 10,
        searchText: searchText,
      );

      // Filter out duplicate customers based on customerCode
      final allCustomers = response['data'] ?? [];
      final Map<String, dynamic> uniqueCustomers = {};

      for (var customer in allCustomers) {
        final customerCode = customer['cusCode']?.toString() ??
            customer['customerCode']?.toString() ??
            '';

        // Only add if we haven't seen this customerCode before
        if (customerCode.isNotEmpty &&
            !uniqueCustomers.containsKey(customerCode)) {
          uniqueCustomers[customerCode] = customer;
        }
      }

      setState(() {
        _customerSearchResults = uniqueCustomers.values.toList();
        _showCustomerDropdown = _customerSearchResults.isNotEmpty;
      });
    } catch (e) {
      print('Error searching customers: $e');
      setState(() {
        _showCustomerDropdown = false;
        _customerSearchResults = [];
      });
    }
  }

  /// Select customer from search results
  /// Ensures uniqueness by customerCode - if same customer is already selected, don't re-initialize
  void _selectCustomer(Map<String, dynamic> customer) {
    final customerCode = customer['cusCode']?.toString() ??
        customer['customerCode']?.toString() ??
        '';
    final customerName = customer['cusName']?.toString() ??
        customer['customerName']?.toString() ??
        '';
    final priceCategory = customer['priceCategory']?.toString() ??
        customer['PriceCategory']?.toString() ??
        'RETAIL';
    // Get outstanding balance (calculated as OpeningBalance + DueAmount + CreditAdjust - DebitAdjust - AdvanceAmount)
    final outstandingAmount =
        (customer['outstandingAmount'] as num?)?.toDouble();

    // Check if this customer is already selected (by customerCode)
    if (_selectedCustomerCode == customerCode && customerCode.isNotEmpty) {
      // Customer already selected, just close dropdown
      setState(() {
        _showCustomerDropdown = false;
        _customerSearchResults = [];
      });
      return;
    }

    setState(() {
      _selectedCustomerCode = customerCode;
      _selectedCustomerName = customerName;
      _selectedCustomerPriceCategory = priceCategory;
      _selectedPriceCategory = priceCategory; // Use customer's price category
      _selectedCustomerBalance = outstandingAmount;
      _customerSearchController.text = customerName;
      _showCustomerDropdown = false;
      _customerSearchResults = [];
    });

    // Update invoice with selected customer (only if customerCode changed)
    if (customerCode.isNotEmpty) {
      _bloc.add(InitializeInvoiceCreation(
        customerCode: customerCode,
        customerName: customerName,
      ));
    }
  }

  /// Load product from dropdown selection
  void _selectProductFromDropdown(Map<String, dynamic> product) {
    // Use default locaCode - backend will handle it
    final locaCode = product['locaCode']?.toString() ?? 'DEFAULT';
    final barcode = product['itemBarcode']?.toString() ??
        product['itemBarcode1']?.toString() ??
        product['itemBarcode2']?.toString() ??
        product['itemBarcode3']?.toString() ??
        product['itemBarcode4']?.toString() ??
        '';
    final productName = product['itemName']?.toString() ?? '';
    final itemCode = product['itemCode']?.toString() ?? '';

    // Fetch last invoice price (ItemDPrice, Qty) - for Add Item dialog
    _lastInvPriceData = null;
    _fetchLastInvPriceAndThenAddProduct(
      product: product,
      itemCode: itemCode,
      barcode: barcode,
      locaCode: locaCode,
      productName: productName,
    );
  }

  /// Fetch last invoice price from API, then proceed to add product
  Future<void> _fetchLastInvPriceAndThenAddProduct({
    required Map<String, dynamic> product,
    required String itemCode,
    required String barcode,
    required String locaCode,
    String? productName,
  }) async {
    try {
      final repository = RepositoryProvider.of<InvoiceRepository>(context);
      if (_selectedCustomerCode != null && _selectedCustomerCode!.isNotEmpty) {
        _lastInvPriceData = await repository.fetchLastInvPriceByCustomer(
          cusCode: _selectedCustomerCode!,
          itemCode: itemCode,
          barcode: barcode.isNotEmpty ? barcode : null,
        );
      } else {
        _lastInvPriceData = await repository.fetchLastInvPriceByItem(
          itemCode: itemCode,
          barcode: barcode.isNotEmpty ? barcode : null,
        );
      }
    } catch (e) {
      print('Error fetching last inv price: $e');
      _lastInvPriceData = null;
    }

    if (!mounted) return;

    // Always try to fetch price links to get all price fields (itemWPrice, itemLDPrice, etc.)
    if (barcode.isNotEmpty || (productName ?? '').isNotEmpty || itemCode.isNotEmpty) {
      _fetchProductWithPriceLinks(
        product,
        barcode.isNotEmpty ? barcode : itemCode,
        locaCode,
        productName: productName,
      );
    } else {
      _addProductDirectly(product);
    }
  }

  /// Fetch product with price links from item-lookup endpoint
  /// This matches the Item_Detect() logic from .NET code
  /// After getting item detail, calls checkPriceLink to get full price link data with all price fields
  Future<void> _fetchProductWithPriceLinks(
    Map<String, dynamic> product,
    String barcode,
    String locaCode, {
    String? productName,
  }) async {
    // Show loading
    setState(() {
      _showProductDropdown = false;
    });

    try {
      // Get repository from context
      final repository = RepositoryProvider.of<InvoiceRepository>(context);

      // Lookup item with price links (matches Item_Detect logic)
      // Get itemCode from product if available
      final itemCode = product['itemCode']?.toString();
      final stockId = product['stockId']?.toString() ?? '';
      final itemDetail = await repository.lookupItemWithPriceLinks(
        barcode: barcode,
        locaCode: locaCode,
        productName: productName,
        itemCode: itemCode,
      );

      if (itemDetail == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item not found')),
        );
        return;
      }

      // Call checkPriceLink to get full price link data with all price fields
      // This matches VB6 Check_PriceLink() logic
      List<PriceLinkModel> priceLinksFromCheck = [];
      try {
        priceLinksFromCheck = await repository.checkPriceLink(
          itemBarcode: barcode,
          locaCode: locaCode,
          stockId: stockId.isNotEmpty
              ? stockId
              : (itemDetail.priceLinks.isNotEmpty
                  ? itemDetail.priceLinks.first.stockId
                  : ''),
        );

        // Filter price links where ItemUPrice > 0 AND ItemSPrice > 0
        // Order by QtyRemain ASC (matches Check_PriceLink logic)
        priceLinksFromCheck = priceLinksFromCheck
            .where((pl) =>
                pl.itemUPrice > BigDecimal.zero &&
                pl.itemSPrice > BigDecimal.zero)
            .toList()
          ..sort((a, b) {
            final qtyA = a.qtyRemain ?? BigDecimal.zero;
            final qtyB = b.qtyRemain ?? BigDecimal.zero;
            return qtyA.compareTo(qtyB);
          });
      } catch (e) {
        print(
            'Error calling checkPriceLink, using price links from lookup: $e');
        // Fallback to price links from lookupItemWithPriceLinks
        priceLinksFromCheck = itemDetail.priceLinks
            .where((pl) =>
                pl.itemUPrice > BigDecimal.zero &&
                pl.itemSPrice > BigDecimal.zero)
            .toList()
          ..sort((a, b) {
            final qtyA = a.qtyRemain ?? BigDecimal.zero;
            final qtyB = b.qtyRemain ?? BigDecimal.zero;
            return qtyA.compareTo(qtyB);
          });
      }

      if (priceLinksFromCheck.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No price links found for this item. Please update the item with non-zero prices.',
            ),
          ),
        );
        return;
      }

      // Get current price category to determine behavior
      // Priority: User's current selection > Customer's price category > RETAIL
      final priceCategory =
          _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

      // For RETAIL category: Apply priority logic automatically
      // Priority: Offer (if valid) > Discount (if valid) > Selling
      // For other categories: Only show dialog if multiple price links or showPriceLink is true
      if (priceCategory.toUpperCase() == 'RETAIL') {
        // RETAIL: Automatically determine price based on priority logic
        final priceLink = priceLinksFromCheck.first;
        final recommendedPrice =
            _getRetailPriceByPriority(itemDetail, priceLink);

        if (recommendedPrice != null) {
          print(
              'RETAIL category: Auto-selected price = ${recommendedPrice['price']}, key = ${recommendedPrice['key']}');
          _addItemWithPriceLinkAndSelectedPrice(
            itemDetail,
            priceLink,
            recommendedPrice['price'] as BigDecimal,
            recommendedPrice['key'] as String,
          );
        } else {
          // Fallback: Use selling price
          print('RETAIL category: Using fallback selling price');
          _addItemWithPriceLink(itemDetail, priceLink);
        }
      } else if (priceLinksFromCheck.length > 1 && itemDetail.showPriceLink) {
        // Multiple price links and showPriceLink is true - show selection dialog
        _showPriceLinkSelectionDialog(itemDetail, priceLinksFromCheck);
      } else {
        // Single price link or showPriceLink is false - use first price link
        // Calculate price using price category (matches Get_ItemPriceDet logic)
        print(
            'Auto-adding item with price category: $priceCategory (non-RETAIL)');
        _addItemWithPriceLink(itemDetail, priceLinksFromCheck.first);
      }
    } catch (e) {
      print('Error fetching product with price links: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Map<String, dynamic>? _pendingProductSelection;

  /// Add product directly from product list (without price links)
  /// This is a fallback when price links cannot be fetched
  /// Note: This method doesn't have access to wholesale prices, so it uses available prices
  void _addProductDirectly(Map<String, dynamic> product) {
    // Get current price category
    // Priority: User's current selection > Customer's price category > RETAIL
    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    // Try to get price based on category from available fields
    // Note: Product search API doesn't return itemWPrice, so we use fallback prices
    BigDecimal selectedPrice;
    if (priceCategory == 'WHOLESALE') {
      // If wholesale is selected but itemWPrice is not available, use itemDPrice or itemSPrice
      selectedPrice = BigDecimal.parse(
        ((product['itemWPrice'] as num?) ??
                product['itemDPrice'] as num? ??
                product['itemSPrice'] as num? ??
                0)
            .toString(),
      );
    } else if (priceCategory == 'LOYALTY DISCOUNT') {
      selectedPrice = BigDecimal.parse(
        ((product['itemLDPrice'] as num?) ??
                product['itemDPrice'] as num? ??
                product['itemSPrice'] as num? ??
                0)
            .toString(),
      );
    } else if (priceCategory.startsWith('CATEGORY')) {
      // Try to get category price
      final catNum = priceCategory.replaceAll('CATEGORY', '');
      final catPriceKey = 'itemCusCatPrice$catNum';
      selectedPrice = BigDecimal.parse(
        ((product[catPriceKey] as num?) ??
                product['itemDPrice'] as num? ??
                product['itemSPrice'] as num? ??
                0)
            .toString(),
      );
    } else {
      // RETAIL or default: use itemDPrice, itemSPrice, or itemOPrice
      selectedPrice = BigDecimal.parse(
        ((product['itemDPrice'] as num?) ??
                product['itemOPrice'] as num? ??
                product['itemSPrice'] as num? ??
                0)
            .toString(),
      );
    }

    final item = InvoiceItem(
      itemCode: product['itemCode']?.toString() ?? '',
      itemBarcode: product['itemBarcode']?.toString() ?? '',
      itemName: product['itemName']?.toString() ?? '',
      stockId: product['stockId']?.toString() ?? '',
      qty: 1,
      itemUPrice: BigDecimal.parse(
        ((product['itemUPrice'] as num?) ?? 0).toString(),
      ),
      itemSPrice: BigDecimal.parse(
        ((product['itemSPrice'] as num?) ?? 0).toString(),
      ),
      itemDPrice: selectedPrice,
      tPrice: selectedPrice,
      invType: product['invType']?.toString() ?? 'STD',
      priceCategory: priceCategory,
    );

    _barcodeController.clear();
    _showProductDropdown = false;
    _showAddItemDialog(item);
  }

  /// Add product from search result (with price link data)
  /// NOTE: This method should not be used directly - use _fetchProductWithPriceLinks instead
  /// to ensure correct product name from itemDetail (filtered by CompID)
  void _addProductFromSearchResult(
    Map<String, dynamic> searchResult,
    Map<String, dynamic> originalProduct,
  ) {
    // Get current price category
    // Priority: User's current selection > Customer's price category > RETAIL
    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    // IMPORTANT: Use itemName from searchResult (which comes from lookupItemByBarcode)
    // instead of originalProduct (which comes from product search) to ensure correct
    // product name filtered by CompID
    final item = InvoiceItem(
      itemCode: searchResult['itemCode']?.toString() ??
          originalProduct['itemCode']?.toString() ??
          '',
      itemBarcode: searchResult['itemBarcode']?.toString() ??
          originalProduct['itemBarcode']?.toString() ??
          '',
      // Use searchResult itemName first (from lookupItemByBarcode - filtered by CompID)
      // Only fallback to originalProduct if searchResult doesn't have it
      itemName: searchResult['itemName']?.toString() ??
          originalProduct['itemName']?.toString() ??
          '',
      stockId: searchResult['stockId']?.toString() ?? '',
      qty: 1,
      itemUPrice: BigDecimal.parse(
        ((searchResult['itemUPrice'] as num?) ?? 0).toString(),
      ),
      itemSPrice: BigDecimal.parse(
        ((searchResult['itemSPrice'] as num?) ?? 0).toString(),
      ),
      itemDPrice: BigDecimal.parse(
        ((searchResult['itemDPrice'] as num?) ?? 0).toString(),
      ),
      tPrice: BigDecimal.parse(
        ((searchResult['itemDPrice'] as num?) ?? 0).toString(),
      ),
      invType: searchResult['invType']?.toString() ?? 'STD',
      priceCategory: priceCategory,
    );

    _barcodeController.clear();
    _showProductDropdown = false;
    _showAddItemDialog(item);
  }

  /// Show price selection from multiple search results
  void _showPriceSelectionFromResults(
    Map<String, dynamic> originalProduct,
    List<Map<String, dynamic>> results,
  ) {
    if (results.length == 1 && results.first['priceLink'] != null) {
      // Single result with price link - show price options
      _showPriceSelectionDialog(results.first);
    } else {
      // Multiple results - show selection dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              originalProduct['itemName']?.toString() ?? 'Select Price Option'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final result = results[index];
                final price = (result['itemDPrice'] as num?) ??
                    (result['itemSPrice'] as num?) ??
                    (result['itemUPrice'] as num?) ??
                    0;
                return ListTile(
                  title: Text('Stock ID: ${result['stockId'] ?? ''}'),
                  subtitle: Text(
                      'Price: ₨${currencyFormatter.format(price.toDouble())}'),
                  onTap: () {
                    Navigator.pop(context);
                    _addProductFromSearchResult(result, originalProduct);
                  },
                );
              },
            ),
          ),
        ),
      );
    }
  }

  /// Show price link selection dialog (matches lstPriceLink in .NET)
  void _showPriceLinkSelectionDialog(
    ItemDetailModel itemDetail,
    List<PriceLinkModel> priceLinks,
  ) {
    // Get current price category
    // Priority: User's current selection > Customer's price category > RETAIL
    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    // For RETAIL: Price is automatically selected based on priority logic
    // For others: Show stock location selection with price links
    if (priceCategory.toUpperCase() == 'RETAIL' && priceLinks.isNotEmpty) {
      // RETAIL price should already be handled in _fetchProductWithPriceLinks
      // This dialog is only for non-RETAIL categories
      print('WARNING: RETAIL category should not reach this dialog');
      return;
    }

    // For non-RETAIL categories: Show stock location selection
    showDialog(
        context: context,
        builder: (stockLocationDialogContext) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.inventory_2, color: Color(0xFF2196F3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    itemDetail.itemName,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(stockLocationDialogContext),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(stockLocationDialogContext).size.height * 0.6,
              ),
              child: SizedBox(
                width: double.maxFinite,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text(
                    'Select Stock Location:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: priceLinks.length,
                      itemBuilder: (itemBuilderContext, index) {
                        final priceLink = priceLinks[index];
                        final isInStock = priceLink.qtyRemain != null &&
                            priceLink.qtyRemain! > BigDecimal.zero;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isInStock
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isInStock
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: Builder(
                              builder: (cardContext) {
                                final priceCategory = _selectedPriceCategory ??
                                    _selectedCustomerPriceCategory ??
                                    'RETAIL';
                                return InkWell(
                                  onTap: () {
                                    // For non-RETAIL categories, use default logic
                                    // For RETAIL, the individual price buttons handle selection
                                    if (priceCategory.toUpperCase() !=
                                        'RETAIL') {
                                      Navigator.pop(stockLocationDialogContext);
                                      _addItemWithPriceLink(
                                          itemDetail, priceLink);
                                    }
                                    // For RETAIL, do nothing on card tap - prices are clickable directly
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Builder(builder: (context) {
                                      // Item Name (full name) - use from itemDetail if priceLink doesn't have it
                                      final displayItemName =
                                          priceLink.itemName ??
                                              itemDetail.itemName;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (displayItemName.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8),
                                              child: Text(
                                                displayItemName,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade800,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.store,
                                                color: isInStock
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Stock ID: ${priceLink.stockId}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isInStock
                                                            ? Colors
                                                                .green.shade700
                                                            : Colors
                                                                .red.shade700,
                                                      ),
                                                    ),
                                                    // Show ItemBarcode instead of itemCode
                                                    if (priceLink.itemBarcode !=
                                                            null &&
                                                        priceLink.itemBarcode!
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 4),
                                                        child: Text(
                                                          'Barcode: ${priceLink.itemBarcode}',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Unit Price',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade600,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      '₨${currencyFormatter.format(priceLink.itemUPrice.toDouble())}',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              // Show price based on selected category
                                              // For RETAIL: Show all three prices as selectable buttons
                                              // For others: Show single calculated price
                                              Expanded(
                                                child: Builder(
                                                  builder:
                                                      (priceDisplayContext) {
                                                    final priceCategory =
                                                        _selectedPriceCategory ??
                                                            _selectedCustomerPriceCategory ??
                                                            'RETAIL';

                                                    print(
                                                        '=== Price Display for RETAIL ===');
                                                    print(
                                                        'priceCategory: $priceCategory');
                                                    print(
                                                        'priceLink.itemSPrice: ${priceLink.itemSPrice}');
                                                    print(
                                                        'priceLink.itemOPrice: ${priceLink.itemOPrice}');
                                                    print(
                                                        'priceLink.itemDPrice: ${priceLink.itemDPrice}');

                                                    // For RETAIL: Show all three prices (itemSPrice, itemOPrice, itemDPrice) as selectable buttons
                                                    if (priceCategory
                                                            .toUpperCase() ==
                                                        'RETAIL') {
                                                      final retailPrices = <Map<
                                                          String, dynamic>>[];

                                                      // Debug: Print price values
                                                      print(
                                                          '=== RETAIL Price Selection ===');
                                                      print(
                                                          'itemSPrice: ${priceLink.itemSPrice}');
                                                      print(
                                                          'itemOPrice: ${priceLink.itemOPrice}');
                                                      print(
                                                          'itemDPrice: ${priceLink.itemDPrice}');
                                                      print(
                                                          'itemSPrice > 0: ${priceLink.itemSPrice > BigDecimal.zero}');
                                                      print(
                                                          'itemOPrice != null: ${priceLink.itemOPrice != null}');
                                                      print(
                                                          'itemOPrice > 0: ${priceLink.itemOPrice != null && priceLink.itemOPrice! > BigDecimal.zero}');
                                                      print(
                                                          'itemDPrice != null: ${priceLink.itemDPrice != null}');
                                                      print(
                                                          'itemDPrice > 0: ${priceLink.itemDPrice != null && priceLink.itemDPrice! > BigDecimal.zero}');

                                                      // ALWAYS show all three prices for RETAIL in this order:
                                                      // 1. itemSPrice (Selling Price) - always show first
                                                      // 2. itemOPrice (Offer Price) - show second if not null
                                                      // 3. itemDPrice (Discount Price) - show third if not null
                                                      // Enable only if > 0

                                                      // 1. Always add itemSPrice (Selling Price) FIRST
                                                      retailPrices.add({
                                                        'label': 'Selling',
                                                        'price': priceLink
                                                            .itemSPrice,
                                                        'key': 'itemSPrice',
                                                        'enabled': priceLink
                                                                .itemSPrice >
                                                            BigDecimal.zero,
                                                      });
                                                      print(
                                                          '✓ Added Selling price: ${priceLink.itemSPrice} (enabled: ${priceLink.itemSPrice > BigDecimal.zero})');

                                                      // 2. Add itemOPrice (Offer Price) SECOND if exists
                                                      if (priceLink
                                                              .itemOPrice !=
                                                          null) {
                                                        final isEnabled =
                                                            priceLink
                                                                    .itemOPrice! >
                                                                BigDecimal.zero;
                                                        retailPrices.add({
                                                          'label': 'Offer',
                                                          'price': priceLink
                                                              .itemOPrice!,
                                                          'key': 'itemOPrice',
                                                          'enabled': isEnabled,
                                                        });
                                                        print(
                                                            '✓ Added Offer price: ${priceLink.itemOPrice} (enabled: $isEnabled)');
                                                      } else {
                                                        print(
                                                            '✗ Skipped Offer price: null or missing');
                                                      }

                                                      // 3. Add itemDPrice (Discount Price) THIRD if exists
                                                      if (priceLink
                                                              .itemDPrice !=
                                                          null) {
                                                        final isEnabled =
                                                            priceLink
                                                                    .itemDPrice! >
                                                                BigDecimal.zero;
                                                        retailPrices.add({
                                                          'label': 'Discount',
                                                          'price': priceLink
                                                              .itemDPrice!,
                                                          'key': 'itemDPrice',
                                                          'enabled': isEnabled,
                                                        });
                                                        print(
                                                            '✓ Added Discount price: ${priceLink.itemDPrice} (enabled: $isEnabled)');
                                                      } else {
                                                        print(
                                                            '✗ Skipped Discount price: null or missing');
                                                      }

                                                      print(
                                                          '=== Final retail prices list ===');
                                                      print(
                                                          'Total count: ${retailPrices.length}');
                                                      for (int i = 0;
                                                          i <
                                                              retailPrices
                                                                  .length;
                                                          i++) {
                                                        final p =
                                                            retailPrices[i];
                                                        print(
                                                            '  [${i + 1}] ${p['label']}: ${p['price']} (enabled: ${p['enabled']})');
                                                      }

                                                      // Ensure we always have at least itemSPrice as fallback
                                                      if (retailPrices
                                                          .isEmpty) {
                                                        print(
                                                            'WARNING: No prices in list! Adding Selling price as fallback.');
                                                        retailPrices.add({
                                                          'label': 'Selling',
                                                          'price': priceLink
                                                              .itemSPrice,
                                                          'key': 'itemSPrice',
                                                          'enabled': true,
                                                        });
                                                      }

                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width:
                                                                double.infinity,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        6),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors.blue
                                                                  .shade100,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          6),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .blue
                                                                      .shade300,
                                                                  width: 1.5),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .price_check,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .blue
                                                                        .shade900),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Expanded(
                                                                  child: Text(
                                                                    'RETAIL Prices - Tap to Select (${retailPrices.length} options):',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .blue
                                                                          .shade900,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 10),
                                                          // Show all three price buttons in a scrollable horizontal row
                                                          // This ensures all buttons are visible and accessible
                                                          SizedBox(
                                                            height:
                                                                85, // Fixed height to show buttons
                                                            child: ListView(
                                                              scrollDirection:
                                                                  Axis.horizontal,
                                                              shrinkWrap: true,
                                                              children:
                                                                  retailPrices.map(
                                                                      (priceInfo) {
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              10),
                                                                  child:
                                                                      _buildRetailPriceButton(
                                                                    priceInfo,
                                                                    priceDisplayContext,
                                                                    stockLocationDialogContext,
                                                                    itemDetail,
                                                                    priceLink,
                                                                  ),
                                                                );
                                                              }).toList(),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    } else {
                                                      // For other categories, show single calculated price
                                                      final categoryPrice =
                                                          priceLink
                                                              .getPriceByCategory(
                                                                  priceCategory);
                                                      final displayPrice =
                                                          categoryPrice ??
                                                              priceLink
                                                                  .itemSPrice;

                                                      return Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Price ($priceCategory)',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors.grey
                                                                  .shade600,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          Text(
                                                            '₨${currencyFormatter.format(displayPrice.toDouble())}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Theme.of(
                                                                      priceDisplayContext)
                                                                  .primaryColor,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Rest of the card content continues here...
                                          if (priceLink.qtyRemain != null) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  isInStock
                                                      ? Icons.check_circle
                                                      : Icons.cancel,
                                                  color: isInStock
                                                      ? Colors.green
                                                      : Colors.red,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Qty Remain: ${currencyFormatter.format(priceLink.qtyRemain!.toDouble())}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: isInStock
                                                        ? Colors.green.shade700
                                                        : Colors.red.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      );
                                    }),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]),
              ),
            )));
  }

  /// Get RETAIL price based on priority logic (matching VB6 Get_ItemPriceDet)
  /// Priority: Offer (if valid) > Discount (if valid) > Selling
  /// Returns Map with 'price' (BigDecimal) and 'key' (String) or null
  Map<String, dynamic>? _getRetailPriceByPriority(
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
  ) {
    // Get invoice creation date (current date)
    final invoiceDate = DateTime.now();

    // Apply RETAIL priority logic based on VB6 code:
    // Priority 1: Offer Price if chkOffer=1 AND itemOPrice != 0 AND OfferValidTill >= invoice date
    // Priority 2: Discount Price if chkDiscount=1 AND itemDPrice != 0 AND DiscountValidTill >= invoice date
    // Priority 3: Selling Price (always available)

    // Check if Offer is valid
    if (itemDetail.offer &&
        priceLink.itemOPrice != null &&
        priceLink.itemOPrice! > BigDecimal.zero) {
      bool isOfferValid = false;
      if (itemDetail.offerValidTill == null) {
        // If no expiry date, offer is always valid
        isOfferValid = true;
      } else {
        // Check if offer hasn't expired (offerValidTill >= invoice date)
        final offerExpiry = itemDetail.offerValidTill!;
        final offerExpiryDate =
            DateTime(offerExpiry.year, offerExpiry.month, offerExpiry.day);
        final invoiceDateOnly =
            DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
        isOfferValid = offerExpiryDate.isAfter(invoiceDateOnly) ||
            offerExpiryDate.isAtSameMomentAs(invoiceDateOnly);
      }

      if (isOfferValid) {
        print(
            'RETAIL Priority: Offer Price is valid and selected (${priceLink.itemOPrice})');
        return {
          'price': priceLink.itemOPrice!,
          'key': 'itemOPrice',
        };
      }
    }

    // Check if Discount is valid (only if Offer is not valid)
    if (itemDetail.discount &&
        priceLink.itemDPrice != null &&
        priceLink.itemDPrice! > BigDecimal.zero) {
      bool isDiscountValid = false;
      if (itemDetail.discountValidTill == null) {
        // If no expiry date, discount is always valid
        isDiscountValid = true;
      } else {
        // Check if discount hasn't expired (discountValidTill >= invoice date)
        final discountExpiry = itemDetail.discountValidTill!;
        final discountExpiryDate = DateTime(
            discountExpiry.year, discountExpiry.month, discountExpiry.day);
        final invoiceDateOnly =
            DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
        isDiscountValid = discountExpiryDate.isAfter(invoiceDateOnly) ||
            discountExpiryDate.isAtSameMomentAs(invoiceDateOnly);
      }

      if (isDiscountValid) {
        print(
            'RETAIL Priority: Discount Price is valid and selected (${priceLink.itemDPrice})');
        return {
          'price': priceLink.itemDPrice!,
          'key': 'itemDPrice',
        };
      }
    }

    // Fallback to Selling Price
    print(
        'RETAIL Priority: Using Selling Price as fallback (${priceLink.itemSPrice})');
    return {
      'price': priceLink.itemSPrice,
      'key': 'itemSPrice',
    };
  }

  /// Build a retail price selection button
  /// Show RETAIL price selection dialog with 3 separate cards (DEPRECATED - no longer used)
  /// Each card represents one price option (Selling, Offer, Discount)
  /// Applies priority logic: Offer (if valid) > Discount (if valid) > Selling
  /// NOTE: Price is now automatically selected based on priority - this method is kept for reference
  void _showRetailPriceCardsDialog(
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
  ) {
    // Get invoice creation date (current date)
    final invoiceDate = DateTime.now();

    // Apply RETAIL priority logic based on VB6 code:
    // Priority 1: Offer Price if chkOffer=1 AND itemOPrice != 0 AND OfferValidTill >= invoice date
    // Priority 2: Discount Price if chkDiscount=1 AND itemDPrice != 0 AND DiscountValidTill >= invoice date
    // Priority 3: Selling Price (always available)

    bool isOfferValid = false;
    bool isDiscountValid = false;

    // Check if Offer is valid
    if (itemDetail.offer &&
        priceLink.itemOPrice != null &&
        priceLink.itemOPrice! > BigDecimal.zero) {
      if (itemDetail.offerValidTill == null) {
        // If no expiry date, offer is always valid
        isOfferValid = true;
      } else {
        // Check if offer hasn't expired (offerValidTill >= invoice date)
        final offerExpiry = itemDetail.offerValidTill!;
        // Compare dates (ignore time)
        final offerExpiryDate =
            DateTime(offerExpiry.year, offerExpiry.month, offerExpiry.day);
        final invoiceDateOnly =
            DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
        isOfferValid = offerExpiryDate.isAfter(invoiceDateOnly) ||
            offerExpiryDate.isAtSameMomentAs(invoiceDateOnly);
      }
    }

    // Check if Discount is valid (only if Offer is not valid)
    if (!isOfferValid &&
        itemDetail.discount &&
        priceLink.itemDPrice != null &&
        priceLink.itemDPrice! > BigDecimal.zero) {
      if (itemDetail.discountValidTill == null) {
        // If no expiry date, discount is always valid
        isDiscountValid = true;
      } else {
        // Check if discount hasn't expired (discountValidTill >= invoice date)
        final discountExpiry = itemDetail.discountValidTill!;
        // Compare dates (ignore time)
        final discountExpiryDate = DateTime(
            discountExpiry.year, discountExpiry.month, discountExpiry.day);
        final invoiceDateOnly =
            DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
        isDiscountValid = discountExpiryDate.isAfter(invoiceDateOnly) ||
            discountExpiryDate.isAtSameMomentAs(invoiceDateOnly);
      }
    }

    // Determine recommended price based on priority
    String? recommendedPriceKey;
    if (isOfferValid) {
      recommendedPriceKey = 'itemOPrice';
    } else if (isDiscountValid) {
      recommendedPriceKey = 'itemDPrice';
    } else {
      recommendedPriceKey = 'itemSPrice';
    }

    print('=== RETAIL Price Priority Logic ===');
    print('Invoice Date: $invoiceDate');
    print('Offer Enabled: ${itemDetail.offer}');
    print('Offer Valid Till: ${itemDetail.offerValidTill}');
    print('Discount Enabled: ${itemDetail.discount}');
    print('Discount Valid Till: ${itemDetail.discountValidTill}');
    print('Is Offer Valid: $isOfferValid');
    print('Is Discount Valid: $isDiscountValid');
    print('Recommended Price Key: $recommendedPriceKey');

    // Build list of available price cards
    final priceCards = <Map<String, dynamic>>[];

    // 1. Selling Price (itemSPrice) - always available
    if (priceLink.itemSPrice > BigDecimal.zero) {
      priceCards.add({
        'label': 'Selling Price',
        'price': priceLink.itemSPrice,
        'key': 'itemSPrice',
        'icon': Icons.sell,
        'color': Colors.blue,
        'enabled': true,
        'isRecommended': recommendedPriceKey == 'itemSPrice',
      });
    }

    // 2. Offer Price (itemOPrice) - if available
    if (priceLink.itemOPrice != null &&
        priceLink.itemOPrice! > BigDecimal.zero) {
      priceCards.add({
        'label': 'Offer Price',
        'price': priceLink.itemOPrice!,
        'key': 'itemOPrice',
        'icon': Icons.local_offer,
        'color': Colors.orange,
        'enabled': true,
        'isRecommended': recommendedPriceKey == 'itemOPrice',
        'isValid': isOfferValid,
      });
    }

    // 3. Discount Price (itemDPrice) - if available
    if (priceLink.itemDPrice != null &&
        priceLink.itemDPrice! > BigDecimal.zero) {
      priceCards.add({
        'label': 'Discount Price',
        'price': priceLink.itemDPrice!,
        'key': 'itemDPrice',
        'icon': Icons.discount,
        'color': Colors.green,
        'enabled': true,
        'isRecommended': recommendedPriceKey == 'itemDPrice',
        'isValid': isDiscountValid,
      });
    }

    if (priceCards.isEmpty) {
      // Fallback: Show selling price even if 0
      priceCards.add({
        'label': 'Selling Price',
        'price': priceLink.itemSPrice,
        'key': 'itemSPrice',
        'icon': Icons.sell,
        'color': Colors.blue,
        'enabled': true,
        'isRecommended': true,
      });
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.price_check, color: Color(0xFF2196F3)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                itemDetail.itemName,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(dialogContext),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(dialogContext).size.height * 0.6,
          ),
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Price Type:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: priceCards.length,
                    itemBuilder: (context, index) {
                      final card = priceCards[index];
                      final isEnabled = card['enabled'] as bool;
                      final price = card['price'] as BigDecimal;
                      final label = card['label'] as String;
                      final icon = card['icon'] as IconData;
                      final color = card['color'] as Color;
                      final priceValue = price.toDouble();
                      final isRecommended =
                          card['isRecommended'] as bool? ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: isEnabled
                                ? () {
                                    Navigator.pop(dialogContext);
                                    _addItemWithPriceLinkAndSelectedPrice(
                                      itemDetail,
                                      priceLink,
                                      price,
                                      card['key'] as String,
                                    );
                                  }
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? (isRecommended
                                        ? color.withOpacity(0.15)
                                        : color.withOpacity(0.1))
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isEnabled
                                      ? (isRecommended
                                          ? color
                                          : color.withOpacity(0.7))
                                      : Colors.grey.shade400,
                                  width: isRecommended ? 3.0 : 2.5,
                                ),
                                boxShadow: isEnabled
                                    ? [
                                        BoxShadow(
                                          color: isRecommended
                                              ? color.withOpacity(0.4)
                                              : color.withOpacity(0.3),
                                          blurRadius: isRecommended ? 12 : 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isEnabled
                                          ? (isRecommended
                                              ? color.withOpacity(0.3)
                                              : color.withOpacity(0.2))
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      icon,
                                      color: isEnabled
                                          ? color
                                          : Colors.grey.shade600,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isEnabled
                                                      ? color
                                                      : Colors.grey.shade600,
                                                ),
                                              ),
                                            ),
                                            if (isRecommended)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.amber,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'RECOMMENDED',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₨${currencyFormatter.format(priceValue)}',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isEnabled
                                                ? color
                                                : Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: isEnabled
                                        ? color
                                        : Colors.grey.shade400,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRetailPriceButton(
    Map<String, dynamic> priceInfo,
    BuildContext priceDisplayContext,
    BuildContext stockLocationDialogContext,
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
  ) {
    final isEnabled = priceInfo['enabled'] as bool;
    final price = priceInfo['price'] as BigDecimal;
    final priceValue = price.toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                print(
                    'User tapped price button: ${priceInfo['label']} = $priceValue');
                Navigator.pop(stockLocationDialogContext);
                _addItemWithPriceLinkAndSelectedPrice(
                  itemDetail,
                  priceLink,
                  price,
                  priceInfo['key'] as String,
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100, // Fixed width for consistent button size
          constraints: const BoxConstraints(
            minHeight: 75,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled
                ? Theme.of(priceDisplayContext).primaryColor.withOpacity(0.2)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled
                  ? Theme.of(priceDisplayContext).primaryColor
                  : Colors.grey.shade400,
              width: 2.5,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: Theme.of(priceDisplayContext)
                          .primaryColor
                          .withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEnabled ? Icons.attach_money : Icons.money_off,
                size: 20,
                color: isEnabled
                    ? Theme.of(priceDisplayContext).primaryColor
                    : Colors.grey.shade600,
              ),
              const SizedBox(height: 4),
              Text(
                priceInfo['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? Theme.of(priceDisplayContext).primaryColor
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 3),
              Text(
                '₨${currencyFormatter.format(priceValue)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isEnabled
                      ? Theme.of(priceDisplayContext).primaryColor
                      : Colors.grey.shade400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Add item with calculated price using PriceCalculator
  /// This matches Get_ItemPriceDet logic from .NET code
  Future<void> _addItemWithPriceLink(
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
  ) async {
    // Get price based on selected price category
    // Priority: User's current selection > Customer's price category > RETAIL
    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    print('_addItemWithPriceLink: priceCategory = $priceCategory');
    print('  _selectedCustomerPriceCategory = $_selectedCustomerPriceCategory');
    print('  _selectedPriceCategory = $_selectedPriceCategory');

    // Get price using VB6 logic (matches Get_ItemPriceDet)
    final selectedPrice = priceLink.getPriceByCategory(priceCategory);

    print(
        '_addItemWithPriceLink: selectedPrice = ${selectedPrice?.toString() ?? "null"}');

    // Fallback to itemDPrice or itemSPrice if category price is null
    final itemDPrice =
        selectedPrice ?? priceLink.itemDPrice ?? priceLink.itemSPrice;

    print('_addItemWithPriceLink: final itemDPrice = ${itemDPrice.toString()}');

    // Create invoice item
    final item = InvoiceItem(
      itemCode: itemDetail.itemCode,
      itemBarcode: itemDetail.itemBarcode,
      itemName: itemDetail.itemName,
      stockId: priceLink.stockId,
      qty: 1,
      itemUPrice: priceLink.itemUPrice,
      itemSPrice: priceLink.itemSPrice,
      itemDPrice: itemDPrice,
      tPrice: itemDPrice, // Initial total = price * 1
      invType: 'STD',
      priceCategory: priceCategory,
    );

    _barcodeController.clear();
    _showProductDropdown = false;
    _showAddItemDialog(item, itemDetail, priceLink);
  }

  /// Show price selection dialog for RETAIL category
  /// Displays itemSPrice, itemOPrice, and itemDPrice for user selection
  void _showRetailPriceSelectionDialog(
    BuildContext stockLocationDialogContext,
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
  ) {
    print('=== _showRetailPriceSelectionDialog called ===');
    print('itemSPrice: ${priceLink.itemSPrice}');
    print('itemOPrice: ${priceLink.itemOPrice}');
    print('itemDPrice: ${priceLink.itemDPrice}');
    print('itemOPrice is null: ${priceLink.itemOPrice == null}');
    print('itemDPrice is null: ${priceLink.itemDPrice == null}');
    print(
        'itemOPrice > 0: ${priceLink.itemOPrice != null ? priceLink.itemOPrice! > BigDecimal.zero : false}');
    print(
        'itemDPrice > 0: ${priceLink.itemDPrice != null ? priceLink.itemDPrice! > BigDecimal.zero : false}');

    final availablePrices = <Map<String, dynamic>>[];

    // For RETAIL category, show all three prices:
    // 1. itemSPrice (Selling Price) - always show (required)
    // 2. itemOPrice (Offer Price) - show if exists (even if 0, but disabled)
    // 3. itemDPrice (Discount Price) - show if exists (even if 0, but disabled)

    // itemSPrice is always available (required field) - always show it
    availablePrices.add({
      'label': 'Selling Price (ItemSPrice)',
      'price': priceLink.itemSPrice,
      'key': 'itemSPrice',
      'enabled': priceLink.itemSPrice > BigDecimal.zero,
    });
    print(
        'Added itemSPrice: ${priceLink.itemSPrice} (enabled: ${priceLink.itemSPrice > BigDecimal.zero})');

    // itemOPrice - show if not null (enable only if > 0, but show even if 0)
    if (priceLink.itemOPrice != null) {
      final isEnabled = priceLink.itemOPrice! > BigDecimal.zero;
      availablePrices.add({
        'label': 'Offer Price (ItemOPrice)',
        'price': priceLink.itemOPrice!,
        'key': 'itemOPrice',
        'enabled': isEnabled,
      });
      print('Added itemOPrice: ${priceLink.itemOPrice} (enabled: $isEnabled)');
    } else {
      print('itemOPrice is null, skipping');
    }

    // itemDPrice - show if not null (enable only if > 0, but show even if 0)
    if (priceLink.itemDPrice != null) {
      final isEnabled = priceLink.itemDPrice! > BigDecimal.zero;
      availablePrices.add({
        'label': 'Discount Price (ItemDPrice)',
        'price': priceLink.itemDPrice!,
        'key': 'itemDPrice',
        'enabled': isEnabled,
      });
      print('Added itemDPrice: ${priceLink.itemDPrice} (enabled: $isEnabled)');
    } else {
      print('itemDPrice is null, skipping');
    }

    print('Total available prices count: ${availablePrices.length}');
    print(
        'All prices: ${availablePrices.map((p) => '${p['label']}: ${p['price']} (enabled: ${p['enabled']})').join(", ")}');

    // Ensure at least itemSPrice is always available (should never be empty, but safety check)
    if (availablePrices.isEmpty) {
      print(
          'ERROR: No prices available! This should not happen. Adding itemSPrice as fallback.');
      availablePrices.add({
        'label': 'Selling Price (ItemSPrice)',
        'price': priceLink.itemSPrice,
        'key': 'itemSPrice',
        'enabled': true,
      });
    }

    // Show price selection dialog using the stock location dialog context
    // This ensures the dialog appears on top of the stock location dialog
    showDialog(
      context: stockLocationDialogContext,
      barrierDismissible: true,
      builder: (priceSelectionDialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.price_check, color: Color(0xFF2196F3)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                itemDetail.itemName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select a price for RETAIL category:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (availablePrices.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No prices available for selection',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...availablePrices.map((priceInfo) {
                    final isEnabled = priceInfo['enabled'] as bool;
                    final price = priceInfo['price'] as BigDecimal;
                    final priceValue = price.toDouble();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: isEnabled ? 3 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isEnabled
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      color: isEnabled ? Colors.white : Colors.grey.shade50,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isEnabled
                            ? () {
                                print(
                                    'User selected price: ${priceInfo['label']} = ${priceValue}');
                                Navigator.pop(
                                    priceSelectionDialogContext); // Close price selection dialog
                                Navigator.pop(
                                    stockLocationDialogContext); // Close stock location dialog
                                _addItemWithPriceLinkAndSelectedPrice(
                                  itemDetail,
                                  priceLink,
                                  price,
                                  priceInfo['key'] as String,
                                );
                              }
                            : () {
                                // Show message if price is 0 or not available
                                ScaffoldMessenger.of(
                                        priceSelectionDialogContext)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${priceInfo['label']} is not available (price is 0)'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isEnabled
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isEnabled
                                      ? Icons.attach_money
                                      : Icons.money_off,
                                  color: isEnabled
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey.shade400,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      priceInfo['label'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isEnabled
                                            ? Colors.black87
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₨${currencyFormatter.format(priceValue)}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isEnabled
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isEnabled)
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 18,
                                  color: Theme.of(context).primaryColor,
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'N/A',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(priceSelectionDialogContext);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Add item with selected price for RETAIL category
  void _addItemWithPriceLinkAndSelectedPrice(
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
    BigDecimal selectedPrice,
    String priceKey,
  ) async {
    print(
        '_addItemWithPriceLinkAndSelectedPrice: selectedPrice = $selectedPrice, priceKey = $priceKey');

    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    // Create invoice item with selected price
    final item = InvoiceItem(
      itemCode: itemDetail.itemCode,
      itemBarcode: itemDetail.itemBarcode,
      itemName: itemDetail.itemName,
      stockId: priceLink.stockId,
      qty: 1,
      itemUPrice: priceLink.itemUPrice,
      itemSPrice: priceLink.itemSPrice,
      itemDPrice: selectedPrice,
      tPrice: selectedPrice, // Initial total = price * 1
      invType: 'STD',
      priceCategory: priceCategory,
    );

    _barcodeController.clear();
    _showProductDropdown = false;
    _showAddItemDialog(item, itemDetail, priceLink);
  }

  void _showPriceSelectionDialog(Map<String, dynamic> product) {
    final priceLink = product['priceLink'] as Map<String, dynamic>?;
    if (priceLink == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product['itemName'] ?? 'Select Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select price option:'),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Unit Price'),
              subtitle: Text(
                  '₨${currencyFormatter.format((priceLink['itemUPrice'] as num? ?? 0).toDouble())}'),
              onTap: () {
                Navigator.pop(context);
                _addProductWithPrice(product, priceLink['itemUPrice'], 'U');
              },
            ),
            ListTile(
              title: Text('Sale Price'),
              subtitle: Text(
                  '₨${currencyFormatter.format((priceLink['itemSPrice'] as num? ?? 0).toDouble())}'),
              onTap: () {
                Navigator.pop(context);
                _addProductWithPrice(product, priceLink['itemSPrice'], 'S');
              },
            ),
            if (priceLink['itemDPrice'] != null)
              ListTile(
                title: Text('Discount Price'),
                subtitle: Text(
                    '₨${currencyFormatter.format((priceLink['itemDPrice'] as num? ?? 0).toDouble())}'),
                onTap: () {
                  Navigator.pop(context);
                  _addProductWithPrice(product, priceLink['itemDPrice'], 'D');
                },
              ),
          ],
        ),
      ),
    );
  }

  void _addProductWithPrice(
      Map<String, dynamic> product, dynamic price, String priceType) {
    // Get current price category
    // Priority: User's current selection > Customer's price category > RETAIL
    final priceCategory =
        _selectedPriceCategory ?? _selectedCustomerPriceCategory ?? 'RETAIL';

    final item = InvoiceItem(
      itemCode: product['itemCode'] ?? '',
      itemBarcode: product['itemBarcode'] ?? '',
      itemName: product['itemName'] ?? '',
      stockId: product['stockId'] ?? '',
      qty: 1,
      itemUPrice: BigDecimal.parse(
        ((product['itemUPrice'] as num?) ?? 0).toString(),
      ),
      itemSPrice: BigDecimal.parse(
        ((product['itemSPrice'] as num?) ?? 0).toString(),
      ),
      itemDPrice: BigDecimal.parse(
        ((price as num?) ?? 0).toString(),
      ),
      tPrice: BigDecimal.parse(
        (price ?? 0).toString(),
      ),
      invType: product['invType'] ?? 'STD',
      priceCategory: priceCategory,
    );

    _barcodeController.clear();
    _showProductDropdown = false;
    _showAddItemDialog(item);
  }

  void _submitInvoice() {
    // Customer is optional - proceed even if not selected
    // Show payment type selection dialog
    _showPaymentTypeDialog();
  }

  void _saveAndHoldInvoice() {
    // Save invoice with hold status without payment
    final state = _bloc.state;
    if (state is! InvoiceCreationReady || state.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add items to the invoice first')),
      );
      return;
    }

    _bloc.add(const SaveAndHoldInvoice());
  }

  void _showPaymentTypeDialog() {
    String? selectedPaymentType;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(
                child: Text('Select Payment Type'),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose payment method:'),
                const SizedBox(height: 16),
                RadioListTile<String>(
                  title: const Text('Cash'),
                  value: 'CASH',
                  groupValue: selectedPaymentType,
                  onChanged: (value) {
                    setModalState(() => selectedPaymentType = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Cheque'),
                  value: 'CHEQUE',
                  groupValue: selectedPaymentType,
                  onChanged: (value) {
                    setModalState(() => selectedPaymentType = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Card'),
                  value: 'CARD',
                  groupValue: selectedPaymentType,
                  onChanged: (value) {
                    setModalState(() => selectedPaymentType = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Credit'),
                  value: 'CREDIT',
                  groupValue: selectedPaymentType,
                  onChanged: (value) {
                    setModalState(() => selectedPaymentType = value);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Bank Transfer'),
                  value: 'BANK_TRANSFER',
                  groupValue: selectedPaymentType,
                  onChanged: (value) {
                    setModalState(() => selectedPaymentType = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPaymentType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select a payment type')),
                  );
                  return;
                }

                Navigator.pop(context);

                // Show detailed payment dialog based on selection
                if (selectedPaymentType == 'CASH') {
                  _showCashPaymentDialog();
                } else if (selectedPaymentType == 'CHEQUE') {
                  _showChequePaymentDialog();
                } else if (selectedPaymentType == 'CARD') {
                  _showCardPaymentDialog();
                } else if (selectedPaymentType == 'CREDIT') {
                  _showCreditPaymentDialog();
                } else if (selectedPaymentType == 'BANK_TRANSFER') {
                  _showBankTransferDialog();
                }
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCashPaymentDialog() {
    final cashController = TextEditingController();
    final state = _bloc.state;
    BigDecimal grandTotal = BigDecimal.zero;
    if (state is InvoiceCreationReady) {
      grandTotal = state.grandTotal;
      cashController.text = grandTotal.toString();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Cash Payment')),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                cashController.dispose();
                Navigator.pop(context);
              },
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Net Total: ${grandTotal.toString()}'),
              const SizedBox(height: 16),
              TextField(
                controller: cashController,
                decoration: const InputDecoration(
                  labelText: 'Cash Amount *',
                  hintText: 'Enter cash amount',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              cashController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final cashPaid = BigDecimal.parse(cashController.text);
                // Store invoice items and payment info for printing
                final currentState = _bloc.state;
                if (currentState is InvoiceCreationReady) {
                  setState(() {
                    _lastSubmittedItems = List.from(currentState.items);
                    _lastSubmittedGrandTotal = currentState.grandTotal;
                    _lastCashPaid = cashPaid;
                    _lastPaymentType = 'CASH';
                  });
                }
                cashController.dispose();
                Navigator.pop(context);
                _bloc.add(SubmitInvoice(
                  paymentType: 'CASH',
                  cashPaid: cashPaid,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid amount: $e')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    ).then((_) {
      // Ensure controller is disposed even if dialog is dismissed another way
      try {
        cashController.dispose();
      } catch (e) {
        // Controller already disposed, ignore
      }
    });
  }

  void _showChequePaymentDialog() {
    final chequeNoController = TextEditingController();
    final paidAmountController = TextEditingController();
    final remarkController = TextEditingController();
    final bankNameController = TextEditingController();

    String? status = 'PENDING';
    String? transactionType = 'IN HAND';
    String? chequeType = 'OWN CHQ';
    String? paymentType = 'CROSS CHQ';

    DateTime createDate = DateTime.now();
    DateTime chequeDate = DateTime.now();

    final state = _bloc.state;
    BigDecimal grandTotal = BigDecimal.zero;
    if (state is InvoiceCreationReady) {
      grandTotal = state.grandTotal;
      paidAmountController.text = grandTotal.toString();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Cheque Payment Details')),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Total: ${grandTotal.toString()}'),
                const SizedBox(height: 16),
                TextField(
                  controller: chequeNoController,
                  decoration: const InputDecoration(
                    labelText: 'Cheque Number *',
                    hintText: 'Enter cheque number',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Create Date: ${DateFormat('dd/MM/yyyy').format(createDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: createDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => createDate = picked);
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Cheque Date: ${DateFormat('dd/MM/yyyy').format(chequeDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: chequeDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => chequeDate = picked);
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status *'),
                  items: ['PENDING', 'CLEARED', 'BOUNCED']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setModalState(() => status = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: transactionType,
                  decoration:
                      const InputDecoration(labelText: 'Transaction Type *'),
                  items: ['IN HAND', 'RECEIVED']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => transactionType = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: chequeType,
                  decoration: const InputDecoration(labelText: 'Cheque Type *'),
                  items: ['OWN CHQ', 'RECEIVED CHQ', 'PARTY CHQ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setModalState(() => chequeType = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: paymentType,
                  decoration:
                      const InputDecoration(labelText: 'Payment Type *'),
                  items: ['CROSS CHQ', 'CASH CHQ']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) =>
                      setModalState(() => paymentType = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Paid Amount *',
                    hintText: 'Enter paid amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name *',
                    hintText: 'Enter bank name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: remarkController,
                  decoration: const InputDecoration(
                    labelText: 'Remark',
                    hintText: 'Enter remarks',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (chequeNoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter cheque number')),
                  );
                  return;
                }
                if (bankNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter bank name')),
                  );
                  return;
                }
                try {
                  final paidAmount =
                      BigDecimal.parse(paidAmountController.text);
                  final chequePayment = ChequePaymentDTO(
                    chequeNumber: chequeNoController.text,
                    createDate: createDate,
                    chequeDate: chequeDate,
                    status: status ?? 'PENDING',
                    transactionType: transactionType ?? 'IN HAND',
                    chequeType: chequeType ?? 'OWN CHQ',
                    paymentType: paymentType ?? 'CROSS CHQ',
                    bankCode: null,
                    bankName: bankNameController.text.trim(),
                    branchCode: null,
                    branchName: null,
                    accountType: null,
                    accountNo: '',
                    paidAmount: paidAmount.toString(),
                    remark: remarkController.text.isEmpty
                        ? null
                        : remarkController.text,
                  );
                  // Store invoice items for printing
                  final currentState = _bloc.state;
                  if (currentState is InvoiceCreationReady) {
                    setState(() {
                      _lastSubmittedItems = List.from(currentState.items);
                      _lastSubmittedGrandTotal = currentState.grandTotal;
                      _lastPaymentType = 'CHEQUE';
                    });
                  }
                  Navigator.pop(context);
                  _bloc.add(SubmitInvoice(
                    paymentType: 'CHEQUE',
                    chequePayment: chequePayment,
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid amount: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardPaymentDialog() {
    final cardNoController = TextEditingController();
    final cardHolderController = TextEditingController();
    final bankNameController = TextEditingController();
    final paidAmountController = TextEditingController();

    String? cardType;

    final state = _bloc.state;
    BigDecimal grandTotal = BigDecimal.zero;
    if (state is InvoiceCreationReady) {
      grandTotal = state.grandTotal;
      paidAmountController.text = grandTotal.toString();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Card Payment Details')),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  cardNoController.dispose();
                  cardHolderController.dispose();
                  bankNameController.dispose();
                  paidAmountController.dispose();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Total: ${grandTotal.toString()}'),
                const SizedBox(height: 16),
                TextField(
                  controller: cardNoController,
                  decoration: const InputDecoration(
                    labelText: 'Card Number *',
                    hintText: 'Enter card number',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      String detectedType = 'OTHER';
                      if (value.startsWith('3'))
                        detectedType = 'AMERICAN EXPRESS';
                      else if (value.startsWith('4'))
                        detectedType = 'VISA CARD';
                      else if (value.startsWith('5'))
                        detectedType = 'MASTER CARD';
                      else if (value.startsWith('0')) detectedType = 'IPAY';
                      setModalState(() => cardType = detectedType);
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: cardType,
                  decoration: const InputDecoration(labelText: 'Card Type *'),
                  items: [
                    'VISA CARD',
                    'MASTER CARD',
                    'AMERICAN EXPRESS',
                    'IPAY',
                    'OTHER'
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) => setModalState(() => cardType = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: cardHolderController,
                  decoration: const InputDecoration(
                    labelText: 'Card Holder Name',
                    hintText: 'Enter card holder name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name *',
                    hintText: 'Enter bank name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Paid Amount *',
                    hintText: 'Enter paid amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                cardNoController.dispose();
                cardHolderController.dispose();
                bankNameController.dispose();
                paidAmountController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (cardNoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter card number')),
                  );
                  return;
                }
                if (cardType == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select card type')),
                  );
                  return;
                }
                if (bankNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter bank name')),
                  );
                  return;
                }
                try {
                  final paidAmount =
                      BigDecimal.parse(paidAmountController.text);
                  final cardPayment = CardPaymentDTO(
                    cardNumber: cardNoController.text,
                    cardType: cardType ?? 'OTHER',
                    expMonth: DateTime.now().month,
                    expYear: DateTime.now().year,
                    cardHolderName: cardHolderController.text.isEmpty
                        ? null
                        : cardHolderController.text,
                    pin: null,
                    paidAmount: paidAmount.toString(),
                    bankCode: null,
                    bankName: bankNameController.text.trim(),
                    branchCode: null,
                    branchName: null,
                    accountType: null,
                    accountNo: null,
                  );
                  // Store invoice items for printing
                  final currentState = _bloc.state;
                  if (currentState is InvoiceCreationReady) {
                    setState(() {
                      _lastSubmittedItems = List.from(currentState.items);
                      _lastSubmittedGrandTotal = currentState.grandTotal;
                      _lastPaymentType = 'CARD';
                    });
                  }
                  cardNoController.dispose();
                  cardHolderController.dispose();
                  bankNameController.dispose();
                  paidAmountController.dispose();
                  Navigator.pop(context);
                  _bloc.add(SubmitInvoice(
                    paymentType: 'CARD',
                    cardPayment: cardPayment,
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid amount: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Ensure controllers are disposed even if dialog is dismissed another way
      try {
        cardNoController.dispose();
        cardHolderController.dispose();
        bankNameController.dispose();
        paidAmountController.dispose();
      } catch (e) {
        // Controllers already disposed, ignore
      }
    });
  }

  void _showCreditPaymentDialog() {
    final creditController = TextEditingController();
    final state = _bloc.state;
    BigDecimal grandTotal = BigDecimal.zero;
    if (state is InvoiceCreationReady) {
      grandTotal = state.grandTotal;
      creditController.text = grandTotal.toString();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Credit Payment')),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Net Total: ${grandTotal.toString()}'),
              const SizedBox(height: 16),
              const Text('This invoice will be added to customer credit.'),
              const SizedBox(height: 16),
              TextField(
                controller: creditController,
                decoration: const InputDecoration(
                  labelText: 'Credit Amount *',
                  hintText: 'Enter credit amount',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              try {
                final creditPaid = BigDecimal.parse(creditController.text);
                // Store invoice items for printing
                final currentState = _bloc.state;
                if (currentState is InvoiceCreationReady) {
                  setState(() {
                    _lastSubmittedItems = List.from(currentState.items);
                    _lastSubmittedGrandTotal = currentState.grandTotal;
                    _lastPaymentType = 'CREDIT';
                  });
                }
                Navigator.pop(context);
                _bloc.add(SubmitInvoice(
                  paymentType: 'CREDIT',
                  creditPaid: creditPaid,
                ));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invalid amount: $e')),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showBankTransferDialog() {
    final refNoController = TextEditingController();
    final paidAmountController = TextEditingController();
    final serviceChargeController = TextEditingController(text: '0.00');
    final bankNameController = TextEditingController();
    final branchNameController = TextEditingController();
    final accountNoController = TextEditingController();

    String? accountType;
    String? bankCode;
    String? branchCode;

    DateTime createDate = DateTime.now();

    final state = _bloc.state;
    BigDecimal grandTotal = BigDecimal.zero;
    if (state is InvoiceCreationReady) {
      grandTotal = state.grandTotal;
      paidAmountController.text = grandTotal.toString();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Expanded(child: Text('Bank Transfer Details')),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Invoice Total: ${grandTotal.toString()}'),
                const SizedBox(height: 16),
                TextField(
                  controller: refNoController,
                  decoration: const InputDecoration(
                    labelText: 'Reference Number *',
                    hintText: 'Enter reference number',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          'Date: ${DateFormat('dd/MM/yyyy').format(createDate)}'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: createDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => createDate = picked);
                        }
                      },
                      child: const Text('Select'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Name *',
                    hintText: 'Enter bank name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: branchNameController,
                  decoration: const InputDecoration(
                    labelText: 'Branch Name',
                    hintText: 'Enter branch name',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: accountNoController,
                  decoration: const InputDecoration(
                    labelText: 'Account Number *',
                    hintText: 'Enter account number',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidAmountController,
                  decoration: const InputDecoration(
                    labelText: 'Paid Amount *',
                    hintText: 'Enter paid amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: serviceChargeController,
                  decoration: const InputDecoration(
                    labelText: 'Service Charge',
                    hintText: 'Enter service charge (optional)',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (refNoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter reference number')),
                  );
                  return;
                }
                if (bankNameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter bank name')),
                  );
                  return;
                }
                if (accountNoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter account number')),
                  );
                  return;
                }
                try {
                  final paidAmount =
                      BigDecimal.parse(paidAmountController.text);
                  final serviceCharge = serviceChargeController.text.isNotEmpty
                      ? BigDecimal.parse(serviceChargeController.text)
                      : BigDecimal.zero;
                  final bankTransfer = BankTransferDTO(
                    referenceNo: refNoController.text,
                    createDate: createDate,
                    paidAmount: paidAmount.toString(),
                    serviceCharge: serviceCharge.toString(),
                    bankCode: bankCode,
                    bankName: bankNameController.text,
                    branchCode: branchCode,
                    branchName: branchNameController.text.isEmpty
                        ? null
                        : branchNameController.text,
                    accountType: accountType,
                    accountNo: accountNoController.text,
                  );
                  // Store invoice items for printing
                  final currentState = _bloc.state;
                  if (currentState is InvoiceCreationReady) {
                    setState(() {
                      _lastSubmittedItems = List.from(currentState.items);
                      _lastSubmittedGrandTotal = currentState.grandTotal;
                      _lastPaymentType = 'BANK_TRANSFER';
                    });
                  }
                  Navigator.pop(context);
                  _bloc.add(SubmitInvoice(
                    paymentType: 'BANK_TRANSFER',
                    bankTransfer: bankTransfer,
                  ));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid amount: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      key: _scaffoldKey,
      drawer: AppDrawer(),
      // bottomNavigationBar: CustomBottomNavBar(
      //   currentPage: NavigationPage.dashboard,
      // ),
      appBar: Appbar(scaffoldKey: _scaffoldKey),
      body: BlocListener<InvoiceCreationBloc, InvoiceCreationState>(
        listener: (context, state) {
          if (state is ItemLoaded) {
            // Auto-add the item without dialog
            _bloc.add(AddItemToInvoice(state.item));
            _barcodeController.clear();
          } else if (state is InvoiceSubmitSuccess) {
            _showSuccessDialog(state);
            // Note: State will be cleared when dialog is closed (in dialog buttons)
          } else if (state is InvoiceCreationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
            // Fallback to direct product data on error
            if (_pendingProductSelection != null) {
              _addProductDirectly(_pendingProductSelection!);
              _pendingProductSelection = null;
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                _buildCustomerSelectionSection(),
                _buildPriceCategorySection(),
                const SizedBox(height: 16),
                _buildWelcomeCard(),
                const SizedBox(height: 16),
                _buildProductSearchSection(),
                const SizedBox(height: 16),
                _buildItemsSection(),
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Customer (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            if (_selectedCustomerCode == null || _selectedCustomerCode!.isEmpty)
              const Text(
                '(Optional)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                controller: _customerSearchController,
                decoration: InputDecoration(
                  hintText: _selectedCustomerName?.isNotEmpty == true
                      ? _selectedCustomerName
                      : 'Search customer by name, NIC, mobile or address...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.person_search,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                  ),
                  suffixIcon: _selectedCustomerCode != null &&
                          _selectedCustomerCode!.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCustomerCode = null;
                              _selectedCustomerName = null;
                              _selectedCustomerPriceCategory = null;
                              _selectedCustomerBalance = null;
                              _selectedPriceCategory =
                                  'RETAIL'; // Reset to default
                              _customerSearchController.clear();
                              _showCustomerDropdown = false;
                            });
                            _bloc.add(InitializeInvoiceCreation(
                              customerCode: '',
                              customerName: '',
                            ));
                          },
                        )
                      : _customerSearchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                _customerSearchController.clear();
                                setState(() {
                                  _showCustomerDropdown = false;
                                  _customerSearchResults = [];
                                });
                              },
                            )
                          : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: (_selectedCustomerCode == null ||
                              _selectedCustomerCode!.isEmpty)
                          ? Colors.red.shade300
                          : Colors.grey.shade200,
                    ),
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
                readOnly: _selectedCustomerCode != null &&
                    _selectedCustomerCode!.isNotEmpty,
                onChanged: (value) {
                  setState(() {}); // Rebuild to show/hide clear button
                  _onSearchCustomerChanged();
                },
              ),
            ),
            // Customer dropdown list - positioned below search field
            if (_showCustomerDropdown && _customerSearchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _customerSearchResults.length,
                  itemBuilder: (context, index) {
                    final customer = _customerSearchResults[index];
                    final name = customer['customerName']?.toString() ??
                        customer['cusName']?.toString() ??
                        'Unknown';
                    final code = customer['customerCode']?.toString() ??
                        customer['cusCode']?.toString() ??
                        '';
                    final nic = customer['customerNic']?.toString() ??
                        customer['cusNIC']?.toString() ??
                        '';
                    final mobile = customer['contactDetails']?.toString() ??
                        customer['cusMob1']?.toString() ??
                        customer['mobile']?.toString() ??
                        '';
                    final address = customer['addressDetails']?.toString() ??
                        customer['cusAddress']?.toString() ??
                        '';

                    return InkWell(
                      onTap: () => _selectCustomer(customer),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person,
                              color: Color(0xFF2196F3)),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              if (code.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    code,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (nic.isNotEmpty)
                                Text(
                                  'NIC: $nic',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                              if (mobile.isNotEmpty)
                                Text(
                                  'Mobile: $mobile',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                              if (address.isNotEmpty)
                                Text(
                                  'Address: $address',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700),
                                ),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceCategorySection() {
    // Show price category dropdown (editable) when customer is selected
    if (_selectedCustomerCode != null && _selectedCustomerCode!.isNotEmpty) {
      // Show customer's price category as editable dropdown and balance as read-only
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Customer: $_selectedCustomerName',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.category,
                        color: Colors.green.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Price Category *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPriceCategory ??
                      _selectedCustomerPriceCategory ??
                      'RETAIL',
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    hintText: 'Select price category',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'RETAIL', child: Text('RETAIL')),
                    DropdownMenuItem(
                        value: 'WHOLESALE', child: Text('WHOLESALE')),
                    DropdownMenuItem(
                        value: 'CATEGORY1', child: Text('CATEGORY1')),
                    DropdownMenuItem(
                        value: 'CATEGORY2', child: Text('CATEGORY2')),
                    DropdownMenuItem(
                        value: 'CATEGORY3', child: Text('CATEGORY3')),
                    DropdownMenuItem(
                        value: 'CATEGORY4', child: Text('CATEGORY4')),
                    DropdownMenuItem(
                        value: 'CATEGORY5', child: Text('CATEGORY5')),
                    DropdownMenuItem(
                        value: 'LOYALTY DISCOUNT',
                        child: Text('LOYALTY DISCOUNT')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedPriceCategory = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          // Show customer balance
          if (_selectedCustomerBalance != null)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _selectedCustomerBalance! >= 0
                    ? Colors.orange.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedCustomerBalance! >= 0
                      ? Colors.orange.shade200
                      : Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedCustomerBalance! >= 0
                        ? Icons.account_balance_wallet
                        : Icons.account_balance,
                    color: _selectedCustomerBalance! >= 0
                        ? Colors.orange.shade700
                        : Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Outstanding Balance: ₨${currencyFormatter.format(_selectedCustomerBalance!.abs())}',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedCustomerBalance! >= 0
                            ? Colors.orange.shade700
                            : Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Show dropdown when no customer selected
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                'Price Category *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedPriceCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'RETAIL', child: Text('RETAIL')),
              DropdownMenuItem(value: 'WHOLESALE', child: Text('WHOLESALE')),
              DropdownMenuItem(value: 'CATEGORY1', child: Text('CATEGORY1')),
              DropdownMenuItem(value: 'CATEGORY2', child: Text('CATEGORY2')),
              DropdownMenuItem(value: 'CATEGORY3', child: Text('CATEGORY3')),
              DropdownMenuItem(value: 'CATEGORY4', child: Text('CATEGORY4')),
              DropdownMenuItem(value: 'CATEGORY5', child: Text('CATEGORY5')),
              DropdownMenuItem(
                  value: 'LOYALTY DISCOUNT', child: Text('LOYALTY DISCOUNT')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPriceCategory = value ?? 'RETAIL';
              });
            },
          ),
          const SizedBox(height: 4),
          Text(
            'Select price category for items (required when no customer selected)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF2196F3), const Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create New Invoice',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  children: [
                    if (_connectionStatus == ConnectivityResult.none)
                      Tooltip(
                        message:
                            'Offline Mode - Invoice saved locally. Will sync automatically when connection is restored.',
                        child: Chip(
                          label: const Text('Offline - Auto-sync',
                              style: TextStyle(fontSize: 10)),
                          backgroundColor: Colors.orange.shade200,
                          avatar: const Icon(Icons.cloud_off, size: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      )
                    else
                      Chip(
                        label: const Text('Online',
                            style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.green.shade200,
                        avatar: const Icon(Icons.cloud_done, size: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSearchSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
              controller: _barcodeController,
              decoration: InputDecoration(
                hintText: 'Search product by name, code or barcode...',
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
                suffixIcon: _barcodeController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () {
                          _barcodeController.clear();
                          setState(() {
                            _showProductDropdown = false;
                          });
                          context.read<ProductBloc>().add(LoadProducts());
                        },
                      )
                    : null,
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
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
                _onSearchProductChanged();
              },
            ),
          ),
          // Product dropdown list - positioned below search field
          if (_showProductDropdown)
            Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'No products found',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    // return ListView.separated(
                    //   shrinkWrap: true,
                    //   physics: const AlwaysScrollableScrollPhysics(),
                    //   padding: const EdgeInsets.symmetric(vertical: 4),
                    //   itemCount: products.length > 10 ? 10 : products.length,
                    //   separatorBuilder: (context, index) => Divider(
                    //     height: 1,
                    //     thickness: 1,
                    //     color: Colors.grey.shade200,
                    //   ),
                    //   itemBuilder: (context, index) {
                    //     final product = products[index];
                    //     return _buildProductDropdownItem(product);
                    //   },
                    // );

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<ProductBloc>()
                            .add(LoadProducts(refresh: true));
                      },
                      child: ListView.builder(
                        // shrinkWrap: true,
                        // physics: const AlwaysScrollableScrollPhysics(),
                        controller: _scrollController,
                        itemCount:
                            products.length + (state.hasReachedMax ? 0 : 1),
                        itemBuilder: (context, index) {
                          if (index >= products.length) {
                            return const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          print('Products list length: ${products.length}');
                          final product = products[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 10),
                            child: _buildProductDropdownItem(product),
                          );
                        },
                      ),
                    );
                  } else if (state is ProductLoading) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
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

  Widget _buildProductDropdownItem(Map<String, dynamic> product) {
    final itemName = product['itemName']?.toString() ?? 'Unknown Product';
    final itemCode = product['itemCode']?.toString() ?? '';
    final barcode = product['itemBarcode']?.toString() ?? '';
    final price = (product['itemSPrice'] as num?) ?? 0;

    return InkWell(
      onTap: () => _selectProductFromDropdown(product),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.inventory_2,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product name - prominent
                  Text(
                    itemName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a1a1a),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Product code and barcode
                  Row(
                    children: [
                      if (itemCode.isNotEmpty) ...[
                        Text(
                          'Code: $itemCode',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (barcode.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ],
                      if (barcode.isNotEmpty)
                        Flexible(
                          child: Text(
                            'Barcode: $barcode',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '₨${currencyFormatter.format(price.toDouble())}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tap to add',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return BlocBuilder<InvoiceCreationBloc, InvoiceCreationState>(
      builder: (context, state) {
        List<InvoiceItem> items = [];
        BigDecimal grandTotal = BigDecimal.zero;

        if (state is InvoiceCreationReady) {
          items = state.items;
          grandTotal = state.grandTotal;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Invoice Items (${items.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (items.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _bloc.add(const ClearInvoice()),
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No items added yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) =>
                    _buildItemCard(items[index], index),
              ),
            const SizedBox(height: 16),
            if (items.isNotEmpty) _buildGrandTotalCard(grandTotal),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(InvoiceItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.itemBarcode.isNotEmpty
                            ? 'Barcode: ${item.itemBarcode}'
                            : 'Code: ${item.itemCode}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _bloc.add(RemoveItemFromInvoice(index)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Expanded(
                //   child: _buildPriceRow('Unit Price', item.itemUPrice),
                // ),
                // const SizedBox(width: 12),
                Expanded(
                  child: _buildPriceRow('Discount Price', item.itemDPrice),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child:
                      _buildPriceRow('Total', item.tPrice, isHighlighted: true),
                ),
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: item.qty > 1
                            ? () => _bloc.add(UpdateItemQuantity(
                                  itemIndex: index,
                                  newQty: item.qty - 1,
                                ))
                            : null,
                        child: Icon(Icons.remove,
                            size: 18,
                            color: item.qty > 1
                                ? Colors.grey
                                : Colors.grey.shade300),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${item.qty}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _bloc.add(UpdateItemQuantity(
                          itemIndex: index,
                          newQty: item.qty + 1,
                        )),
                        child:
                            const Icon(Icons.add, size: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, BigDecimal price,
      {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
            color: isHighlighted ? Colors.blue.shade700 : Colors.grey.shade700,
          ),
        ),
        Text(
          currencyFormatter.format(price.toDouble()),
          style: TextStyle(
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
            color: isHighlighted ? Colors.blue.shade700 : Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Widget _buildGrandTotalCard(BigDecimal grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF4CAF50), const Color(0xFF45a049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                currencyFormatter.format(grandTotal.toDouble()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.attach_money, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // Removed _buildInvoiceDetailsSection - no longer needed
  // Location code, unit number, and company ID are extracted from token in backend
  // Invoice type uses default 'RETAIL' if not provided

  // Removed _buildTextField and _buildInvoiceTypeDropdown - no longer needed
  // Location code, unit number, company ID, and invoice type are handled by backend

  Widget _buildActionButtons() {
    return BlocBuilder<InvoiceCreationBloc, InvoiceCreationState>(
      builder: (context, state) {
        bool isSubmitting = state is InvoiceSubmitting;
        bool hasItems = false;
        if (state is InvoiceCreationReady) {
          hasItems = state.items.isNotEmpty;
        }

        return Row(
          children: [
            // Only show Cancel button if there are items
            if (hasItems) ...[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          // Clear invoice state and refresh screen
                          _bloc.add(const ClearInvoice());
                          setState(() {
                            _selectedCustomerCode = null;
                            _selectedCustomerName = null;
                            _customerSearchController.clear();
                            _barcodeController.clear();
                            _showProductDropdown = false;
                            _showCustomerDropdown = false;
                            _customerSearchResults = [];
                            _lastSubmittedItems = null;
                            _lastSubmittedGrandTotal = null;
                            _lastCashPaid = null;
                            _lastPaymentType = null;
                          });
                          // Safely navigate back - check if we can pop first
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            // If we can't pop, navigate to a safe route
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          }
                        },
                  icon: const Icon(Icons.close),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _saveAndHoldInvoice,
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitInvoice,
                icon: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(isSubmitting ? 'Submitting...' : 'Submit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFF2196F3),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddItemDialog(
    InvoiceItem item, [
    ItemDetailModel? itemDetail,
    PriceLinkModel? priceLink,
  ]) {
    int quantity = item.qty;
    // Use selling price if discount price is 0
    BigDecimal currentPrice = (item.itemDPrice == BigDecimal.zero)
        ? item.itemSPrice
        : item.itemDPrice;

    // Last invoice preview only - for display in container, do NOT override price/qty
    BigDecimal? lastInvPriceDisplay;
    int? lastInvQtyDisplay;
    final lastInvData = _lastInvPriceData;
    if (lastInvData != null) {
      final lastPrice = lastInvData['itemDPrice'];
      final lastQty = lastInvData['qty'];
      if (lastPrice != null) {
        final p = (lastPrice is num) ? BigDecimal.parse(lastPrice.toString()) : BigDecimal.parse(lastPrice.toString());
        if (p > BigDecimal.zero) lastInvPriceDisplay = p;
      }
      if (lastQty != null && lastQty is num && lastQty.toInt() > 0) {
        lastInvQtyDisplay = lastQty.toInt();
      }
      _lastInvPriceData = null; // Clear after use
    }

    BigDecimal totalPrice =
        currentPrice * BigDecimal.parse(quantity.toString());
    final priceController =
        TextEditingController(text: currentPrice.toString());
    final TextEditingController qtyController =
        TextEditingController(text: quantity.toString());
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Color(0xFF2196F3)),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Add Item to Invoice',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  priceController.dispose();
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Info Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.itemName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Code: ${item.itemCode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (item.itemBarcode.isNotEmpty)
                        Text(
                          'Barcode: ${item.itemBarcode}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
                // Last Invoice info - small container (load only correct compId from token)
                if (lastInvPriceDisplay != null || lastInvQtyDisplay != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Last Invoice',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade900,
                          ),
                        ),
                        Row(
                          children: [
                            if (lastInvPriceDisplay != null)
                              Text(
                                'Price: ₨${currencyFormatter.format(lastInvPriceDisplay.toDouble())}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            if (lastInvPriceDisplay != null && lastInvQtyDisplay != null)
                              Text(
                                '  •  ',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            if (lastInvQtyDisplay != null)
                              Text(
                                'Qty: $lastInvQtyDisplay',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                // Price Details Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      // _buildPriceRow('Unit Price', item.itemUPrice),
                      const Divider(height: 16),
                      _buildPriceRow('Selling Price', item.itemSPrice),
                      const Divider(height: 16),
                      _buildPriceRow(
                        'Discount Price',
                        currentPrice,
                        isHighlighted: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Editable Price Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit,
                              color: Color(0xFF2196F3), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Selling Price (Editable):',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          prefixText: '₨ ',
                          hintText: 'Enter price',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        controller: priceController,
                        onChanged: (value) {
                          try {
                            if (value.isEmpty) return;
                            final newPrice = BigDecimal.parse(value);
                            if (newPrice >= BigDecimal.zero) {
                              setModalState(() {
                                currentPrice = newPrice;
                                totalPrice = newPrice *
                                    BigDecimal.parse(quantity.toString());
                              });
                            }
                          } catch (e) {
                            // Invalid input, ignore
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Total Price Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        currencyFormatter.format(totalPrice.toDouble()),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Quantity Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shopping_bag, color: Color(0xFF2196F3)),
                      const SizedBox(width: 8),
                      const Text(
                        'Quantity:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),

                      /// Quantity Box
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            /// Minus
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: quantity > 1
                                  ? () {
                                      setModalState(() {
                                        quantity--;
                                        qtyController.text =
                                            quantity.toString();
                                        totalPrice = currentPrice *
                                            BigDecimal.parse(
                                                quantity.toString());
                                      });
                                    }
                                  : null,
                            ),

                            /// TextField (TYPE quantity)
                            SizedBox(
                              width: 45,
                              child: TextField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onChanged: (value) {
                                  final int? typedQty = int.tryParse(value);

                                  if (typedQty != null && typedQty > 0) {
                                    setModalState(() {
                                      quantity = typedQty;
                                      totalPrice = currentPrice *
                                          BigDecimal.parse(quantity.toString());
                                    });
                                  }
                                },
                              ),
                            ),

                            /// Plus
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () {
                                setModalState(() {
                                  quantity++;
                                  qtyController.text = quantity.toString();
                                  totalPrice = currentPrice *
                                      BigDecimal.parse(quantity.toString());
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Get final values
                final finalPrice = currentPrice;
                final finalQty = quantity;
                final finalTotal = totalPrice;

                // Close dialog first
                Navigator.pop(context);

                // Then add item and show message
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Preserve price category when updating item
                  // Priority: Item's existing category > User's current selection > Customer's price category > RETAIL
                  final currentPriceCategory = item.priceCategory ??
                      _selectedPriceCategory ??
                      _selectedCustomerPriceCategory ??
                      'RETAIL';
                  _bloc.add(AddItemToInvoice(
                    item.copyWith(
                      qty: finalQty,
                      itemDPrice: finalPrice,
                      tPrice: finalTotal,
                      priceCategory: currentPriceCategory,
                    ),
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Item added to invoice')),
                  );
                });
              },
              child: const Text('Add Item'),
            ),
          ],
        ),
      ),
    ).then((_) {
      // Ensure controller is disposed when dialog closes
      priceController.dispose();
    });
  }

  /// Recalculate price for quantity using calculate-price API
  /// This matches txtQty_Change() and Display_GetPrice logic from .NET
  Future<void> _recalculatePriceForQuantity(
    ItemDetailModel itemDetail,
    PriceLinkModel priceLink,
    int quantity,
    StateSetter setModalState,
    void Function(BigDecimal newPrice, BigDecimal newTotal) onComplete,
  ) async {
    try {
      final repository = RepositoryProvider.of<InvoiceRepository>(context);
      // Use default locaCode - backend will handle it
      final locaCode = 'DEFAULT';

      // Create calculate price request
      final request = CalculatePriceRequest(
        itemCode: itemDetail.itemCode,
        itemBarcode: itemDetail.itemBarcode,
        locaCode: locaCode,
        qty: BigDecimal.parse(quantity.toString()),
        priceType: null,
        customerCode: null,
        itemUPrice: priceLink.itemUPrice,
        itemSPrice: priceLink.itemSPrice,
        itemDPrice: priceLink.itemDPrice,
        askOfferDate: false,
        askDiscountDate: false,
        askWholeSaleDate: false,
        prevCusPrice: false,
        cusPriceWithoutPriceLink: false,
      );

      // Call calculate-price API
      final response = await repository.calculatePrice(request);

      // Update price and total
      setModalState(() {
        final finalPrice = response.itemDPrice;
        final totalPrice = finalPrice * BigDecimal.parse(quantity.toString());
        onComplete(finalPrice, totalPrice);
      });
    } catch (e) {
      print('Error recalculating price: $e');
      // Fallback to simple calculation
      setModalState(() {
        final simplePrice = priceLink.itemSPrice;
        final simpleTotal = simplePrice * BigDecimal.parse(quantity.toString());
        onComplete(simplePrice, simpleTotal);
      });
    }
  }

  Widget _buildItemDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(InvoiceSubmitSuccess state) async {
    // Get invoice data for printing from stored items
    List<InvoiceItem> items = _lastSubmittedItems ?? [];
    BigDecimal grandTotal = _lastSubmittedGrandTotal ?? BigDecimal.zero;

    // If items are empty, we can't print - show message
    if (items.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot Print'),
          content: const Text('Invoice items are not available for printing.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Calculate gross total: sum of (S.Price * qty) for all items
    BigDecimal calculatedGrossTotal = BigDecimal.zero;
    for (var item in items) {
      final sPrice = item.itemSPrice;
      final qty = BigDecimal.parse(item.qty.toString());
      calculatedGrossTotal = calculatedGrossTotal + (sPrice * qty);
    }

    // Calculate line discount: sum of ((S.Price - D.Price) * qty) for all items
    BigDecimal lineDiscount = BigDecimal.zero;
    for (var item in items) {
      final sPrice = item.itemSPrice;
      final dPrice = item.itemDPrice;
      final discount = sPrice - dPrice;
      if (discount > BigDecimal.zero) {
        final qty = BigDecimal.parse(item.qty.toString());
        lineDiscount = lineDiscount + (discount * qty);
      }
    }

    // Invoice total = Gross total - Line discount
    final invoiceTotal = calculatedGrossTotal - lineDiscount;

    // Get company name
    String companyName = 'Company Name';
    try {
      final userRepo = UserRepo();
      companyName = await userRepo.companyName();
    } catch (e) {
      print('Error fetching company name: $e');
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Expanded(
              child: Text('Invoice Created Successfully'),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Invoice Status:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        state.isSynced ? 'Synced to Server' : 'Saved Locally',
                        style: TextStyle(
                          color: state.isSynced ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Invoice No:', state.invoiceNo),
            _buildDetailRow('Serial No:', state.serialNo),
            const SizedBox(height: 16),
            const Text(
              'Do you want to print the invoice?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear invoice state and refresh
              _bloc.add(const ClearInvoice());
              setState(() {
                _selectedCustomerCode = null;
                _selectedCustomerName = null;
                _customerSearchController.clear();
                _barcodeController.clear();
                _showProductDropdown = false;
                _showCustomerDropdown = false;
                _customerSearchResults = [];
                _lastSubmittedItems = null;
                _lastSubmittedGrandTotal = null;
                _lastCashPaid = null;
                _lastPaymentType = null;
              });
              Navigator.pop(context); // Close dialog
              // Use a post-frame callback to ensure dialog is closed before navigation
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              });
            },
            child: const Text('No'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                // Get cash payment amount and calculate change
                BigDecimal? cashPaidAmount =
                    _lastPaymentType == 'CASH' ? _lastCashPaid : null;
                BigDecimal changeAmount = BigDecimal.zero;
                if (cashPaidAmount != null) {
                  if (cashPaidAmount > invoiceTotal) {
                    changeAmount = cashPaidAmount - invoiceTotal;
                  } else {
                    changeAmount = BigDecimal.zero;
                  }
                }

                // Generate PDF
                final pdfBytes = await PdfInvoiceService.generateInvoice(
                  companyName: companyName,
                  items: items,
                  grossTotal: calculatedGrossTotal,
                  lineDiscount: lineDiscount,
                  invoiceTotal: invoiceTotal,
                  cashPaid: cashPaidAmount,
                  change: changeAmount,
                  invoiceNo: state.invoiceNo,
                  serialNo: state.serialNo,
                  customerName: _selectedCustomerName,
                  invoiceDate: DateTime.now(),
                );

                // Print invoice
                await PdfInvoiceService.printInvoice(pdfBytes);

                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice sent to printer'),
                    backgroundColor: Colors.green,
                  ),
                );

                // Clear invoice state and refresh
                _bloc.add(const ClearInvoice());
                setState(() {
                  _selectedCustomerCode = null;
                  _selectedCustomerName = null;
                  _customerSearchController.clear();
                  _barcodeController.clear();
                  _showProductDropdown = false;
                  _showCustomerDropdown = false;
                  _customerSearchResults = [];
                  _lastSubmittedItems = null;
                  _lastSubmittedGrandTotal = null;
                  _lastCashPaid = null;
                  _lastPaymentType = null;
                });
                // Use a post-frame callback to ensure dialog is closed before navigation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              } catch (e) {
                print('Error printing invoice: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error printing invoice: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.print),
            label: const Text('Yes, Print'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
