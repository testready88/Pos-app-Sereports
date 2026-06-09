import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/sales/tab/sales_revenue.dart';
import 'package:sereports/screen/sales/tab/sales_summery.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/drawer.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage>
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
                Tab(text: 'Sales Revenue'),
                Tab(text: 'Sales Summery'),
              ],
            ),
            Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: [SalesRevenue(), SalesSummary()]))
          ],
        ));
  }
}
