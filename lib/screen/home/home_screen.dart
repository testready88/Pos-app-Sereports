// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:sereports/screen/accounts/assets_page.dart';
import 'package:sereports/screen/accounts/capital_page.dart';
import 'package:sereports/screen/accounts/card_page.dart';
import 'package:sereports/screen/accounts/cash_account_page.dart';
import 'package:sereports/screen/accounts/cheques_page.dart';
import 'package:sereports/screen/accounts/liabilities_page.dart';
import 'package:sereports/screen/banking/bank.dart';
import 'package:sereports/screen/customers/customer.dart';
import 'package:sereports/screen/dashboard/dashbaord.dart';
import 'package:sereports/screen/income/expences/income_and_expences.dart';
import 'package:sereports/screen/invoice/held_invoices_screen.dart';
import 'package:sereports/screen/invoice/invoice_creating.dart';
import 'package:sereports/screen/product/product_record.dart';
import 'package:sereports/screen/purchase/purchase.dart';
import 'package:sereports/screen/sales/sales.dart';
import 'package:sereports/screen/supplier/supplier.dart';
import 'package:sereports/widget/drawer.dart';
import 'package:sereports/widget/appbar.dart';

/// Home screen — acts as the main menu/launcher.
/// Displays a grid of module cards. Previously hidden cards have been restored.
/// After login the app navigates to DashbaordScreen directly, but HomeScreen
/// remains accessible via the drawer's "Home" item.
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: Appbar(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a module to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    // Dashboard
                    _buildMenuCard(
                      context,
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const DashbaordScreen(),
                          ),
                        );
                      },
                    ),

                    // Invoice Creating
                    _buildMenuCard(
                      context,
                      icon: Icons.receipt_long,
                      title: 'Invoice Creating',
                      color: Colors.red,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const InvoiceCreationScreen(),
                          ),
                        );
                      },
                    ),

                    // Held Invoices
                    _buildMenuCard(
                      context,
                      icon: Icons.pause_circle_outline,
                      title: 'Held Invoices',
                      color: Colors.cyan,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HeldInvoicesScreen(),
                          ),
                        );
                      },
                    ),

                    // Products
                    _buildMenuCard(
                      context,
                      icon: Icons.inventory,
                      title: 'Products',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const ProductRecordsPage(),
                          ),
                        );
                      },
                    ),

                    // Suppliers
                    _buildMenuCard(
                      context,
                      icon: Icons.local_shipping,
                      title: 'Suppliers',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SupplierPage(),
                          ),
                        );
                      },
                    ),

                    // Customers
                    _buildMenuCard(
                      context,
                      icon: Icons.people,
                      title: 'Customers',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const CustomerPage(),
                          ),
                        );
                      },
                    ),

                    // Sales
                    _buildMenuCard(
                      context,
                      icon: Icons.trending_up,
                      title: 'Sales',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SalesPage(),
                          ),
                        );
                      },
                    ),

                    // Purchase
                    _buildMenuCard(
                      context,
                      icon: Icons.shopping_cart,
                      title: 'Purchase',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const PurchasePage(),
                          ),
                        );
                      },
                    ),

                    // Income / Expenses
                    _buildMenuCard(
                      context,
                      icon: Icons.attach_money,
                      title: 'Income/Expenses',
                      color: Colors.amber,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const IncomeAndExpences(),
                          ),
                        );
                      },
                    ),

                    // Banking
                    _buildMenuCard(
                      context,
                      icon: Icons.account_balance,
                      title: 'Banking',
                      color: Colors.brown,
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const BankPage(),
                          ),
                        );
                      },
                    ),

                    // Assets
                    _buildMenuCard(
                      context,
                      icon: Icons.account_balance_wallet,
                      title: 'Assets',
                      color: Colors.teal,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AssetsPage(),
                          ),
                        );
                      },
                    ),

                    // Capital
                    _buildMenuCard(
                      context,
                      icon: Icons.monetization_on,
                      title: 'Capital',
                      color: Colors.amber,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CapitalPage(),
                          ),
                        );
                      },
                    ),

                    // Card
                    _buildMenuCard(
                      context,
                      icon: Icons.credit_card,
                      title: 'Card',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CardPage(),
                          ),
                        );
                      },
                    ),

                    // Cash Account
                    _buildMenuCard(
                      context,
                      icon: Icons.money,
                      title: 'Cash Account',
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const CashAccountPage(),
                          ),
                        );
                      },
                    ),

                    // Cheques
                    _buildMenuCard(
                      context,
                      icon: Icons.receipt,
                      title: 'Cheques',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ChequesPage(),
                          ),
                        );
                      },
                    ),

                    // Liabilities
                    _buildMenuCard(
                      context,
                      icon: Icons.gavel,
                      title: 'Liabilities',
                      color: Colors.red,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LiabilitiesPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
