import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/customers/tab/customer_record.dart';
import 'package:sereports/screen/customers/tab/debitors.dart';
import 'package:sereports/screen/customers/tab/receivable.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/custom_bottom_nav_bar.dart';
import 'package:sereports/widget/drawer.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage>
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
        bottomNavigationBar: CustomBottomNavBar(
          currentPage: NavigationPage.customers,
        ),
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
                Tab(text: 'Customer Record'),
                Tab(text: 'Debitors'),
                Tab(text: 'Receivable'),
              ],
            ),
            Expanded(
                child: TabBarView(controller: _tabController, children: [
              CustomerRecord(),
              Debitors(),
              Receivable(),
            ]))
          ],
        ));
  }
}
