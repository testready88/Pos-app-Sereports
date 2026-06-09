import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/screen/product/tabbar/category.dart';
import 'package:sereports/screen/product/tabbar/product_list.dart';
import 'package:sereports/screen/product/tabbar/sub_category.dart';
import 'package:sereports/widget/appbar.dart';
import 'package:sereports/widget/custom_bottom_nav_bar.dart';
import 'package:sereports/widget/drawer.dart';

class ProductRecordsPage extends StatefulWidget {
  const ProductRecordsPage({Key? key}) : super(key: key);

  @override
  State<ProductRecordsPage> createState() => _ProductRecordsPageState();
}

class _ProductRecordsPageState extends State<ProductRecordsPage>
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
          currentPage: NavigationPage.products,
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
                Tab(text: 'Products'),
                Tab(text: 'Sub Category'),
                Tab(text: 'Category'),
              ],
            ),
            Expanded(
                child: TabBarView(controller: _tabController, children: [
              ProductListTab(),
              Subcategory(),
              Category(),
            ]))
          ],
        ));
  }
}
