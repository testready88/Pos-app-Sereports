import 'package:flutter/material.dart';

// =============================================================
// AUTH SERVER
// =============================================================

const String authBaseUrl =
    "https://pos-app-sereports-production.up.railway.app/api/";
      
// =============================================================
// DATA SERVER
// =============================================================

const String dataBaseUrl = "https://pos-app-sereports-production.up.railway.app/api/v1/";

// =============================================================
// APP COLORS
// =============================================================

const kBackgroundColor = Color(0xFFF5F9FA);
const grayColorForBorader = Color(0xFFA5A3A3);
const grayColorForHintText = Color(0xFFD1C9C9);
const kButtonColor = Color(0xFF344CB7);

const successColor = Color(0xFF2E7D32);
const errorColor = Color(0xFFD32F2F);
const warningColor = Color(0xFFFFA000);

const radiusValue = 8.0;

// =============================================================
// INPUT BORDER STYLES
// =============================================================

const kDefaultInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: grayColorForBorader, width: 1),
);

const kDefaultFocusInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
  borderSide: BorderSide(color: grayColorForBorader, width: 1),
);

const kDefaultFocusErrorBorder = OutlineInputBorder(
  borderSide: BorderSide(color: grayColorForBorader),
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

// =============================================================
// DROPDOWN DATA
// =============================================================

final List<String> dateRanges = [
  "Today",
  "Yesterday",
  "Day before yesterday",
  "Last 7 days",
  "Last 14 days",
  "This Month",
  "Last Month",
  "Custom",
];

final List<String> gap = [
  "All",
  "0 to 10 Days",
  "10 to 20 Days",
  "20 to 30 Days",
  "Above 30 Days",
  "Above 60 Days",
  "Above 120 Days",
  "Above 180 Days",
];

final List<String> location = [
  "All",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6"
];