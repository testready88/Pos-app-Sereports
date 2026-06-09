import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/purchase/tab/purchase_history.dart';
import 'package:sereports/screen/purchase/tab/purchase_summery.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/custom_bottom_nav_bar.dart';
import 'package:sereports/widget/drawer.dart';

class PurchasePage extends StatefulWidget {
  const PurchasePage({super.key});

  @override
  State<PurchasePage> createState() => _PurchasePageState();
}

class _PurchasePageState extends State<PurchasePage>
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
        bottomNavigationBar: CustomBottomNavBar(
          currentPage: NavigationPage.purchase,
        ),
        appBar: Appbar(scaffoldKey: _scaffoldKey),
        body: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Purchase History'),
                Tab(text: 'Purchase Summery'),
              ],
            ),
            Expanded(
                child: TabBarView(
                    controller: _tabController,
                    children: [PurchaseHistory(), PurchaseSummery()]))
          ],
        ));
  }
}
