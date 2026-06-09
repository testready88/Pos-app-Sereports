// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sereports/screen/customers/customer.dart';
import 'package:sereports/screen/dashboard/dashbaord.dart';
import 'package:sereports/screen/income/expences/income_and_expences.dart';
import 'package:sereports/screen/product/product_record.dart';
import 'package:sereports/screen/purchase/purchase.dart';
import 'package:sereports/screen/supplier/supplier.dart';

enum NavigationPage {
  dashboard,
  products,
  customers,
  purchase,
  incomeExpenses,
  suppliers
}

class CustomBottomNavBar extends StatelessWidget {
  final NavigationPage currentPage;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const CustomBottomNavBar({
    Key? key,
    required this.currentPage,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultSelectedColor = selectedColor ?? theme.primaryColor;
    final defaultUnselectedColor = unselectedColor ?? Colors.grey.shade600;
    final defaultBackgroundColor = backgroundColor ?? Colors.white;

    // Define navigation items with individual colors
    final List<NavigationItem> navItems = [
      NavigationItem(
        page: NavigationPage.dashboard,
        icon: Icons.dashboard,
        label: 'Dashboard',
        color: const Color(0xFF1976D2), // Blue
        onTap: () => _navigateToPage(context, NavigationPage.dashboard),
      ),
      NavigationItem(
        page: NavigationPage.products,
        icon: Icons.inventory_2,
        label: 'Products',
        color: const Color(0xFF9C27B0), // Purple
        onTap: () => _navigateToPage(context, NavigationPage.products),
      ),
      NavigationItem(
        page: NavigationPage.customers,
        icon: Icons.people,
        label: 'Customers',
        color: const Color(0xFF2E7D32), // Green
        onTap: () => _navigateToPage(context, NavigationPage.customers),
      ),
      NavigationItem(
        page: NavigationPage.suppliers,
        icon: Icons.local_shipping,
        label: 'Suppliers',
        color: const Color(0xFFFF9800), // Orange
        onTap: () => _navigateToPage(context, NavigationPage.suppliers),
      ),
      NavigationItem(
        page: NavigationPage.purchase,
        icon: Icons.shopping_cart,
        label: 'Purchase',
        color: const Color(0xFFD32F2F), // Red
        onTap: () => _navigateToPage(context, NavigationPage.purchase),
      ),
      NavigationItem(
        page: NavigationPage.incomeExpenses,
        icon: Icons.account_balance_wallet,
        label: 'Income/Exp',
        color: const Color(0xFF795548), // Brown
        onTap: () => _navigateToPage(context, NavigationPage.incomeExpenses),
      ),
    ];
    // Filter out the current page
    final visibleItems =
        navItems.where((item) => item.page != currentPage).toList();

    return Container(
      decoration: BoxDecoration(
        color: defaultBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 75,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: visibleItems.map((item) {
              final isSelected = item.page == currentPage;

              return Expanded(
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? item.color.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          size: isSelected ? 28 : 24,
                          color: isSelected
                              ? item.color
                              : item.color.withOpacity(0.7),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: isSelected ? 12 : 10,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? item.color
                                : item.color.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, NavigationPage page) {
    Widget destinationPage;

    switch (page) {
      case NavigationPage.dashboard:
        destinationPage = const DashbaordScreen();
        break;
      case NavigationPage.products:
        destinationPage = const ProductRecordsPage();
        break;
      case NavigationPage.customers:
        destinationPage = const CustomerPage();
        break;
      case NavigationPage.suppliers:
        destinationPage = const SupplierPage();
        break;
      case NavigationPage.purchase:
        destinationPage = const PurchasePage();
        break;
      case NavigationPage.incomeExpenses:
        destinationPage = const IncomeAndExpences();
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => destinationPage),
    );
  }
}

class NavigationItem {
  final NavigationPage page;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  NavigationItem({
    required this.page,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
