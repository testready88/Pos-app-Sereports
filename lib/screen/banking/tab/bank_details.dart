// ignore_for_file: annotate_overrides, use_build_context_synchronously, unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sereports/bloc/bank_details/bank_details_bloc.dart';
import 'package:sereports/bloc/bank_details/bank_details_event.dart';
import 'package:sereports/bloc/bank_details/bank_details_state.dart';
import 'package:sereports/bloc/bank_name/bank_name_bloc.dart';
import 'package:sereports/bloc/bank_name/bank_name_event.dart';
import 'package:sereports/bloc/bank_name/bank_name_state.dart';
import 'package:sereports/constants.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({super.key});

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  final currencyFormatter = NumberFormat("#,##0.00", "en_US");
  String selectedBank = "All";
  String selectedLocation = "All";
  DateTime? selectedDate;
  late String formattedDate;

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select date";
  }

  void _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        formattedDate = _formatDate(selectedDate);
        // When date changes, reload bank details with the new date
        _loadBankDetails();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // No default date - let user select if needed
    selectedDate = null;
    formattedDate = _formatDate(selectedDate);

    // Initialize data loading
    Future.microtask(() {
      context.read<BankBloc>().add(const LoadBankNames());
      _loadBankDetails();
    });
  }

  void _loadBankDetails() {
    context.read<BankDetailsBloc>().add(LoadBankDetails(
          dateTo: formattedDate,
        ));
  }

  void _filterBankDetails() {
    context.read<BankDetailsBloc>().add(FilterBankDetails(
          bankName: selectedBank,
          locationCode: selectedLocation,
          dateTo: formattedDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterSection(),
          _buildTotalBalanceCard(),
          Expanded(child: _buildBankDetailsList()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Location Filter
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Location',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedLocation = newValue!;
                          _filterBankDetails();
                        });
                      },
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),

          // Bank Filter
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Bank',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                _buildBankDropdown(),
              ],
            ),
          ),
          const SizedBox(width: 5),

          // Date Filter
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date To:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(context),
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
                        Text(
                          selectedDate != null
                              ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                              : "Select date",
                          style: TextStyle(
                            color: selectedDate != null
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return BlocBuilder<BankDetailsBloc, BankDetailsState>(
      builder: (context, state) {
        if (state is BankDetailsLoaded) {
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
                        'Total Amount in Banks',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(state.totalBankBalance),
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
                      'Total Amount in Banks',
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

  Widget _buildBankDetailsList() {
    return BlocBuilder<BankDetailsBloc, BankDetailsState>(
      builder: (context, state) {
        if (state is BankDetailsInitial || state is BankDetailsLoading) {
          return _buildShimmerList();
        } else if (state is BankDetailsLoaded) {
          if (state.bankDetails.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadBankDetails();
            },
            child: ListView.builder(
              itemCount: state.bankDetails.length,
              itemBuilder: (context, index) {
                final bankDetail = state.bankDetails[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: _buildBankDetailCard(bankDetail, index),
                );
              },
            ),
          );
        } else if (state is BankDetailsError) {
          return _buildErrorWidget(state.message);
        }
        return _buildShimmerList();
      },
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 4,
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
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 100,
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
            'No bank details found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
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
            onPressed: _loadBankDetails,
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

  Widget _buildBankDropdown() {
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
          ];

          // Add divider after "All Banks" if there are other banks
          if (state.bankNames.isNotEmpty) {
            items.add(
              DropdownMenuItem<String>(
                enabled: false,
                value: "__divider_all__",
                child: Container(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
              ),
            );
          }

          // Add all bank names with dividers between them
          for (int i = 0; i < state.bankNames.length; i++) {
            final bankName = state.bankNames[i];

            items.add(
              DropdownMenuItem<String>(
                value: bankName,
                child: Text(bankName),
              ),
            );

            // Add divider between bank names (except after the last one)
            if (i < state.bankNames.length - 1) {
              items.add(
                DropdownMenuItem<String>(
                  enabled: false,
                  value: "__divider_${i}__",
                  child: Container(
                    width: 300,
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: Colors.grey.shade200,
                  ),
                ),
              );
            }
          }

          // If the current selection is not in the list, reset to default
          if (!state.bankNames.contains(selectedBank) &&
              selectedBank != "All") {
            selectedBank = "All";
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
              value: selectedBank,
              items: items,
              onChanged: (state is BankLoading)
                  ? null // Disable during loading
                  : (newValue) {
                      // Ignore divider selections
                      if (newValue != null &&
                          !newValue.startsWith("__divider")) {
                        setState(() {
                          selectedBank = newValue;
                          _filterBankDetails();
                        });
                      }
                    },
              isExpanded: true,
              icon:
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBankDetailCard(dynamic bankDetail, int index) {
    // Alternating card colors: gray for even, white for odd
    final isEven = index % 2 == 0;

    final bankName = bankDetail['bnkName'] ?? 'Unknown Bank';
    final accountNo = bankDetail['acNo'] ?? 'N/A';
    final balance = _formatAmount(bankDetail['amountInBank']);

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
          // Bank header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bankName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a1a1a),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Account: $accountNo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  balance,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bank details with dividers
          ...[
            {'label': 'Bank ID', 'value': bankDetail['bankCode'] ?? 'N/A'},
            {'label': 'Account Type', 'value': bankDetail['acType'] ?? 'N/A'},
            {
              'label': 'Today CHQ Payable',
              'value': _formatAmount(bankDetail['chqPayableToday'])
            },
            {
              'label': 'Today Access/Short',
              'value': _formatAmount(bankDetail['amountShortAccessToday'])
            },
            {
              'label': 'Overall CHQ Payable',
              'value': _formatAmount(bankDetail['chqPayableTotal'])
            },
            {
              'label': 'Overall Access/Short',
              'value': _formatAmount(bankDetail['amountShortAccessTotal'])
            },
          ].asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> detail = entry.value;

            return Column(
              children: [
                _buildBankDetailRow(detail['label']!, detail['value']!),
                // Add divider except for the last item
                if (index < 5)
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

  Widget _buildBankDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is num) {
      return currencyFormatter.format(amount);
    }
    try {
      return currencyFormatter.format(num.parse(amount.toString()));
    } catch (e) {
      return '0.00';
    }
  }
}
