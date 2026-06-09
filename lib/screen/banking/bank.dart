import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/banking/tab/bank_details.dart';
import 'package:sereports/screen/banking/tab/bank_transaction.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        key: _scaffoldKey,
        drawer: AppDrawer(),
        appBar: Appbar(scaffoldKey: _scaffoldKey),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Bank Details'),
                Tab(text: 'Bank Transaction'),
              ],
            ),
            Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: [BankDetails(), BankTransaction()]))
          ],
        ));
  }
}
