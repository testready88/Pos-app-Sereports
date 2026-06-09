// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// Reusable shimmer widget
class ShimmerWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    required this.height,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  }) : shapeBorder = const CircleBorder();

  ShimmerWidget.rounded({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    double radius = 8,
  }) : shapeBorder = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[300]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

// Dashboard specific shimmer widgets
class DashboardShimmer {
  // Shimmer for financial overview cards
  static Widget financialOverviewShimmer(BuildContext context) {
    return Container(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ShimmerWidget.rounded(
                width: 220,
                height: 100,
                radius: 8,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer for amount cards
  static Widget amountCardsShimmer(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: ShimmerWidget.rounded(height: 80)),
              SizedBox(width: 16),
              Expanded(child: ShimmerWidget.rounded(height: 80)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ShimmerWidget.rounded(height: 80)),
              SizedBox(width: 16),
              Expanded(child: ShimmerWidget.rounded(height: 80)),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < 3 ? 10 : 0),
            child: ShimmerWidget.rounded(height: 80),
          ),
        ),
      );
    }
  }

  // Shimmer for P&L Account Card
  static Widget plCardShimmer() {
    return ShimmerWidget.rounded(height: 250);
  }

  // Shimmer for Balance Sheet Card
  static Widget balanceSheetShimmer() {
    return ShimmerWidget.rounded(height: 400);
  }

  // Shimmer for Cash in Hand Card
  static Widget cashInHandShimmer() {
    return ShimmerWidget.rounded(height: 80);
  }

  // Complete dashboard shimmer
  static Widget dashboardShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Financial Overview Title Shimmer
        ShimmerWidget.rectangular(height: 20, width: 160),
        const SizedBox(height: 10),

        // Financial Overview Cards Shimmer
        financialOverviewShimmer(context),
        const SizedBox(height: 20),

        // Expanded list of other cards
        Expanded(
          child: ListView(
            children: [
              // Amount Cards Shimmer
              amountCardsShimmer(context),

              const SizedBox(height: 16),
              // P&L Account Card Shimmer
              plCardShimmer(),

              const SizedBox(height: 16),
              // Balance Sheet Card Shimmer
              balanceSheetShimmer(),

              const SizedBox(height: 16),
              // Cash In Hand Card Shimmer
              cashInHandShimmer(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
