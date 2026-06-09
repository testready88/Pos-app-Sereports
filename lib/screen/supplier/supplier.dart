import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/supplier/tabbar/creditors.dart';
import 'package:sereports/screen/supplier/tabbar/payable.dart';
import 'package:sereports/screen/supplier/tabbar/supplier_record.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/custom_bottom_nav_bar.dart';
import 'package:sereports/widget/drawer.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          currentPage: NavigationPage.suppliers,
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
                Tab(text: 'Supplier Record'),
                Tab(text: 'Creditors'),
                Tab(text: 'Payable'),
              ],
            ),
            Expanded(
                child: TabBarView(controller: _tabController, children: [
              SupplierDetailsScreen(),
              Creditors(),
              Payable(),
            ]))
          ],
        ));
  }
}
