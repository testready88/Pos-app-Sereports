import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/repository/user_repo.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
  const Appbar({
    super.key,
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) : _scaffoldKey = scaffoldKey;

  final GlobalKey<ScaffoldState> _scaffoldKey;

  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
  String greeting = "";
  String formattedDateTime = "";
  late Timer _timer;
  String? companyName;

  Future<void> _fetchCompanyName() async {
    try {
      UserRepo userRepo = UserRepo();
      companyName = await userRepo.companyName();
      setState(() {}); // Update UI after fetching company name
    } catch (e) {
      print("Error fetching company name: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    updateDateTime();
    _fetchCompanyName(); // Fetch company name on initialization
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      updateDateTime(); // Update every second
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel timer to prevent memory leaks
    super.dispose();
  }

  void updateDateTime() {
    DateTime now = DateTime.now();
    String formattedDate =
        DateFormat('EEEE, MMM d, y').format(now); // Ex: Monday, Oct 11, 2025
    String formattedTime =
        DateFormat('hh:mm:ss a').format(now); // Ex: 10:45:30 AM

    // Determine Greeting
    int hour = now.hour;
    if (hour < 12) {
      greeting = "Good Morning!";
    } else if (hour < 17) {
      greeting = "Good Afternoon!";
    } else {
      greeting = "Good Evening!";
    }

    setState(() {
      formattedDateTime = "$formattedDate - $formattedTime";
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kBackgroundColor,
      centerTitle: false,
      leadingWidth: 70,
      leading: IconButton(
          onPressed: () {
            widget._scaffoldKey.currentState?.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: Colors.black,
            size: 40,
          )),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting + (companyName != null ? " ! $companyName" : ""),
            style: TextStyle(
              fontSize: 15,
              color: Colors.black,
            ),
          ),
          Text(
            formattedDateTime,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [],
      elevation: 0,
    );
  }
}
