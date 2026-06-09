// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/db/local_invoice_db.dart';
import 'package:sereports/screen/invoice/invoice_creating.dart';

class HeldInvoicesScreen extends StatefulWidget {
  const HeldInvoicesScreen({super.key});

  @override
  State<HeldInvoicesScreen> createState() => _HeldInvoicesScreenState();
}

class _HeldInvoicesScreenState extends State<HeldInvoicesScreen> {
  final LocalInvoiceDatabase _db = LocalInvoiceDatabase();
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
  
  List<Map<String, dynamic>> _heldInvoices = [];
  bool _isLoading = true;
  String? _searchQuery;
  String? _selectedCustomerFilter;

  @override
  void initState() {
    super.initState();
    _loadHeldInvoices();
  }

  Future<void> _loadHeldInvoices() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final invoices = await _db.getHeldInvoices();
      setState(() {
        _heldInvoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading held invoices: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading held invoices: $e')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredInvoices {
    var filtered = _heldInvoices;

    // Filter by search query (customer name or invoice ID)
    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      final query = _searchQuery!.toLowerCase();
      filtered = filtered.where((invoice) {
        final customerName = (invoice['customerName'] as String? ?? '').toLowerCase();
        final invoiceId = (invoice['id'] as String? ?? '').toLowerCase();
        return customerName.contains(query) || invoiceId.contains(query);
      }).toList();
    }

    // Filter by customer
    if (_selectedCustomerFilter != null && _selectedCustomerFilter!.isNotEmpty) {
      filtered = filtered.where((invoice) {
        return invoice['customerCode'] == _selectedCustomerFilter;
      }).toList();
    }

    return filtered;
  }

  List<String> get _uniqueCustomers {
    final customers = <String>{};
    for (var invoice in _heldInvoices) {
      final customerCode = invoice['customerCode'] as String?;
      final customerName = invoice['customerName'] as String?;
      if (customerCode != null && customerCode.isNotEmpty) {
        customers.add('$customerCode - $customerName');
      }
    }
    return customers.toList()..sort();
  }

  Future<void> _deleteHeldInvoice(String invoiceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Held Invoice'),
        content: const Text('Are you sure you want to delete this held invoice? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _db.deleteInvoice(invoiceId);
        await _loadHeldInvoices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Held invoice deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting invoice: $e')),
          );
        }
      }
    }
  }

  Future<void> _loadInvoiceToEdit(Map<String, dynamic> invoice) async {
    // Navigate to invoice creation screen with the held invoice data
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InvoiceCreationScreen(
            heldInvoiceData: invoice,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Held Invoices'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by customer name or invoice ID...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery != null && _searchQuery!.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = null;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.isEmpty ? null : value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Customer filter dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCustomerFilter,
                  decoration: InputDecoration(
                    labelText: 'Filter by Customer',
                    hintText: 'All Customers',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Customers'),
                    ),
                    ..._uniqueCustomers.map((customer) {
                      final parts = customer.split(' - ');
                      final code = parts[0];
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(customer),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCustomerFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Invoice list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredInvoices.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadHeldInvoices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredInvoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _filteredInvoices[index];
                            return _buildInvoiceCard(invoice);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Held Invoices',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Invoices you hold will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice) {
    final customerName = invoice['customerName'] as String? ?? 'No Customer';
    final customerCode = invoice['customerCode'] as String? ?? '';
    final grandTotal = (invoice['grandTotal'] as num?)?.toDouble() ?? 0.0;
    final createdAt = invoice['createdAt'] as String?;
    final invoiceId = invoice['id'] as String? ?? '';
    
    DateTime? dateTime;
    if (createdAt != null) {
      try {
        dateTime = DateTime.parse(createdAt);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Parse items to get count
    final itemsJson = invoice['items'] as String?;
    int itemCount = 0;
    if (itemsJson != null) {
      try {
        final items = (jsonDecode(itemsJson) as List).length;
        itemCount = items;
      } catch (e) {
        print('Error parsing items: $e');
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _loadInvoiceToEdit(invoice),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with customer info and actions
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (customerCode.isNotEmpty)
                          Text(
                            customerCode,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteHeldInvoice(invoiceId),
                    tooltip: 'Delete',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Invoice details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: ₨${currencyFormatter.format(grandTotal)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$itemCount item${itemCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  if (dateTime != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          dateFormatter.format(dateTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getTimeAgo(dateTime),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _loadInvoiceToEdit(invoice),
                  icon: const Icon(Icons.edit),
                  label: const Text('Continue Invoice'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays != 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours != 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes != 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

