// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/repository/auth_repo.dart';
import 'package:sereports/screen/accounts/accounts_landing_page.dart';
import 'package:sereports/screen/banking/bank.dart';
import 'package:sereports/screen/customers/customer.dart';
import 'package:sereports/screen/dashboard/dashbaord.dart';
import 'package:sereports/screen/home/home_screen.dart';
import 'package:sereports/screen/income/expences/income_and_expences.dart';
import 'package:sereports/screen/invoice/invoice_creating.dart';
import 'package:sereports/screen/product/product_record.dart';
import 'package:sereports/screen/purchase/purchase.dart';
import 'package:sereports/screen/sales/sales.dart';
import 'package:sereports/screen/supplier/supplier.dart';
import 'package:sereports/utils/permission_guard.dart';   // ✅ added
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(radiusValue),
        bottomRight: Radius.circular(radiusValue),
      ),
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // ---------- HOME (chkViewHome) ----------
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkViewHome',
                        visualOptionName: "Home",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomeScreen()),
                        );
                      }
                    },
                  ),

                  // ---------- DASHBOARD (always accessible) ----------
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const DashbaordScreen()),
                      );
                    },
                  ),

                  // ---------- INVOICE CREATING (chkInvoice) ----------
                  ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: const Text('Invoice Creating'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkInvoice',   // or chkMakeQuotation if you prefer
                        visualOptionName: "Invoice Creating",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const InvoiceCreationScreen()),
                        );
                      }
                    },
                  ),

                  // ---------- PRODUCTS (chkAddItem) ----------
                  ListTile(
                    leading: const Icon(Icons.inventory),
                    title: const Text('Products'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkAddItem',   // or chkEditItem / chkDelItem
                        visualOptionName: "Products",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const ProductRecordsPage()),
                        );
                      }
                    },
                  ),

                  // ---------- SUPPLIERS (chkAddSup) ----------
                  ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: const Text('Suppliers'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkAddSup',
                        visualOptionName: "Suppliers",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SupplierPage()),
                        );
                      }
                    },
                  ),

                  // ---------- CUSTOMERS (chkAddCus) ----------
                  ListTile(
                    leading: const Icon(Icons.people),
                    title: const Text('Customers'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkAddCus',
                        visualOptionName: "Customers",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const CustomerPage()),
                        );
                      }
                    },
                  ),

                  // ---------- SALES (chkInvoice or dedicated sales report permission) ----------
                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text('Sales'),
                    onTap: () {
                      // Choose a suitable permission; here we use chkInvoice as a proxy.
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkInvoice',   // or maybe chkPrintInvoice?
                        visualOptionName: "Sales",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const SalesPage()),
                        );
                      }
                    },
                  ),

                  // ---------- PURCHASE (chkPurchase) ----------
                  ListTile(
                    leading: const Icon(Icons.shopping_cart),
                    title: const Text('Purchase'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkPurchase',
                        visualOptionName: "Purchase",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const PurchasePage()),
                        );
                      }
                    },
                  ),

                  // ---------- INCOME / EXPENSES (chkAddIncome) ----------
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: const Text('Income/Expenses'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkAddIncome',   // or chkAddExpenses
                        visualOptionName: "Income/Expenses",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const IncomeAndExpences()),
                        );
                      }
                    },
                  ),

                  // ---------- BANKING (chkAddBank) ----------
                  ListTile(
                    leading: const Icon(Icons.account_balance),
                    title: const Text('Banking'),
                    onTap: () {
                      bool allowed = PermissionGuard.verifyAccess(
                        context: context,
                        permissionKey: 'chkAddBank',
                        visualOptionName: "Banking",
                      );
                      if (allowed) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const BankPage()),
                        );
                      }
                    },
                  ),

                  // ---------- ACCOUNTS (always accessible) ----------
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet),
                    title: const Text('Accounts'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const AccountsLandingPage()),
                      );
                    },
                  ),

                  const Divider(),

                  // ---------- LOGOUT ----------
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      SharedPreferences preferences = await SharedPreferences.getInstance();
                      await AuthRepo(preferences).logout(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}