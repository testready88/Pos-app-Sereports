import 'package:flutter/material.dart';
import 'package:sereports/screen/accounts/assets_page.dart';
import 'package:sereports/screen/accounts/capital_page.dart';
import 'package:sereports/screen/accounts/card_page.dart';
import 'package:sereports/screen/accounts/cash_account_page.dart';
import 'package:sereports/screen/accounts/cheques_page.dart';
import 'package:sereports/screen/accounts/liabilities_page.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';

class AccountsLandingPage extends StatefulWidget {
  const AccountsLandingPage({super.key});

  @override
  State<AccountsLandingPage> createState() => _AccountsLandingPageState();
}

class _AccountsLandingPageState extends State<AccountsLandingPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<_AccountOption> _options = [
    _AccountOption(
      title: 'Assets',
      icon: Icons.account_balance_wallet,
      color: Colors.teal,
    ),
    _AccountOption(
      title: 'Capital',
      icon: Icons.monetization_on,
      color: Colors.amber,
    ),
    _AccountOption(
      title: 'Card',
      icon: Icons.credit_card,
      color: Colors.blue,
    ),
    _AccountOption(
      title: 'Cash Account',
      icon: Icons.money,
      color: Colors.green,
    ),
    _AccountOption(
      title: 'Cheques',
      icon: Icons.receipt,
      color: Colors.indigo,
    ),
    _AccountOption(
      title: 'Liabilities',
      icon: Icons.gavel,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: Appbar(scaffoldKey: scaffoldKey),
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
                  'Accounts',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select an account module',
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
                  children: _options.map((option) {
                    return _buildAccountCard(context, option);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, _AccountOption option) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Widget screen;
          switch (option.title) {
            case 'Assets':
              screen = const AssetsPage();
              break;
            case 'Capital':
              screen = const CapitalPage();
              break;
            case 'Card':
              screen = const CardPage();
              break;
            case 'Cash Account':
              screen = const CashAccountPage();
              break;
            case 'Cheques':
              screen = const ChequesPage();
              break;
            case 'Liabilities':
              screen = const LiabilitiesPage();
              break;
            default:
              return;
          }
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                option.color.withOpacity(0.1),
                option.color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: option.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 40,
                  color: option.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.title,
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

class _AccountOption {
  final String title;
  final IconData icon;
  final Color color;

  const _AccountOption({
    required this.title,
    required this.icon,
    required this.color,
  });
}
