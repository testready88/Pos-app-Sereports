// ignore_for_file: avoid_unnecessary_containers

import 'package:flutter/material.dart';
import 'package:sereports/constants.dart';
import 'package:sereports/widget/bottomsheet.dart'; // Make sure to update this import

class FinacialOverview extends StatelessWidget {
  final String title;
  final String cost;
  final String iconPath;
  final Color color;
  final String viewMoreText;
  final FinancialCardType cardType; // New parameter
  final Map<String, dynamic> data; // New parameter

  const FinacialOverview({
    super.key,
    required this.cardHeight,
    required this.cardWidth,
    required this.title,
    required this.cost,
    required this.iconPath,
    required this.color,
    required this.viewMoreText,
    required this.cardType,
    required this.data,
  });

  final double cardHeight;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Use the new bottom sheet function with the card type and data
        showFinancialDetailBottomSheet(
          context,
          title: title,
          cardType: cardType,
          data: data,
          color: color,
        );
      },
      child: Container(
        height: cardHeight,
        width: cardWidth,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radiusValue),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    child: Text(
                      cost,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  child: ColorFiltered(
                    colorFilter:
                        ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Image.asset(
                      iconPath,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      height: 60,
                      width: 60,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      viewMoreText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.lineTo(size.width * 0.2, size.height * 0.8);
    path.lineTo(size.width * 0.4, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.4);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
