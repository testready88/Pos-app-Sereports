// ignore_for_file: unnecessary_to_list_in_spreads

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:big_decimal/big_decimal.dart';
import 'package:intl/intl.dart';
import '../model/invoiceitem.dart';

class PdfInvoiceService {
  // 80mm width in points (1mm = 2.83465 points)
  static const double receiptWidth = 80 * 2.83465; // ~226.77 points
  static const double fontSize = 9.0;
  static const double smallFontSize = 7.0;
  static const double headerFontSize = 12.0;

  /// Generate 80mm PDF invoice
  static Future<Uint8List> generateInvoice({
    required String companyName,
    required List<InvoiceItem> items,
    required BigDecimal grossTotal,
    required BigDecimal lineDiscount,
    required BigDecimal invoiceTotal,
    required BigDecimal? cashPaid,
    required BigDecimal? change,
    String? invoiceNo,
    String? serialNo,
    String? customerName,
    DateTime? invoiceDate,
  }) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat('#,##0.00');
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(receiptWidth, double.infinity,
            marginAll: 5), // 80mm width, auto height
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Company Name Header - Centered
              pw.Text(
                companyName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: headerFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Invoice Info
              if (invoiceNo != null)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Invoice No:',
                        style: pw.TextStyle(fontSize: fontSize)),
                    pw.Spacer(),
                    pw.Text(invoiceNo, style: pw.TextStyle(fontSize: fontSize)),
                  ],
                ),
              if (serialNo != null) pw.SizedBox(height: 4),
              if (serialNo != null)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Serial No:',
                        style: pw.TextStyle(fontSize: fontSize)),
                    pw.Spacer(),
                    pw.Text(serialNo, style: pw.TextStyle(fontSize: fontSize)),
                  ],
                ),
              pw.SizedBox(height: 4),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Date:', style: pw.TextStyle(fontSize: fontSize)),
                  pw.Spacer(),
                  pw.Text(
                    dateFormatter.format(invoiceDate ?? DateTime.now()),
                    style: pw.TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
              if (customerName != null && customerName.isNotEmpty)
                pw.SizedBox(height: 4),
              if (customerName != null && customerName.isNotEmpty)
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Customer:',
                        style: pw.TextStyle(fontSize: fontSize)),
                    pw.Spacer(),
                    pw.Expanded(
                      child: pw.Text(
                        customerName,
                        style: pw.TextStyle(fontSize: fontSize),
                        textAlign: pw.TextAlign.right,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Table Header
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('#',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text('Desc',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('S.Price',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('D.Price',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text('Qty',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text('Amount',
                        style: pw.TextStyle(
                            fontSize: smallFontSize,
                            fontWeight: pw.FontWeight.bold)),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(),
              pw.SizedBox(height: 4),

              // Items
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final itemSPrice = item.itemSPrice.toDouble();
                final itemDPrice = item.itemDPrice.toDouble();
                final qty = item.qty.toDouble();
                final amount = item.tPrice.toDouble();

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text('${index + 1}',
                              style: pw.TextStyle(fontSize: fontSize)),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                item.itemName,
                                style: pw.TextStyle(fontSize: fontSize),
                                maxLines: 2,
                                overflow: pw.TextOverflow.clip,
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                qty.toStringAsFixed(3),
                                style: pw.TextStyle(fontSize: smallFontSize),
                              ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            currencyFormatter.format(itemSPrice),
                            style: pw.TextStyle(fontSize: fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            currencyFormatter.format(itemDPrice),
                            style: pw.TextStyle(fontSize: fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            qty.toStringAsFixed(0),
                            style: pw.TextStyle(fontSize: fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            currencyFormatter.format(amount),
                            style: pw.TextStyle(fontSize: fontSize),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                  ],
                );
              }).toList(),

              pw.SizedBox(height: 8),
              pw.Divider(),
              pw.SizedBox(height: 8),

              // Summary Section
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Gross Total Rs.',
                      style: pw.TextStyle(fontSize: fontSize)),
                  pw.Spacer(),
                  pw.Text(
                    currencyFormatter.format(grossTotal.toDouble()),
                    style: pw.TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('- Line Discount',
                      style: pw.TextStyle(
                          fontSize: fontSize, fontWeight: pw.FontWeight.bold)),
                  pw.Spacer(),
                  pw.Text(
                    currencyFormatter.format(lineDiscount.toDouble()),
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(),
              pw.SizedBox(height: 4),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Invoice Total Rs.',
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Spacer(),
                  pw.Text(
                    currencyFormatter.format(invoiceTotal.toDouble()),
                    style: pw.TextStyle(
                        fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),

              // Payment Section
              if (cashPaid != null) ...[
                pw.SizedBox(height: 8),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Cash Payment Rs.',
                        style: pw.TextStyle(fontSize: fontSize)),
                    pw.Spacer(),
                    pw.Text(
                      currencyFormatter.format(cashPaid.toDouble()),
                      style: pw.TextStyle(fontSize: fontSize),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Change Rs.',
                        style: pw.TextStyle(
                            fontSize: fontSize,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Spacer(),
                    pw.Text(
                      currencyFormatter
                          .format((change ?? BigDecimal.zero).toDouble()),
                      style: pw.TextStyle(
                          fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Thank You!',
                  style: pw.TextStyle(
                      fontSize: fontSize, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Print invoice to portable printer
  static Future<void> printInvoice(Uint8List pdfBytes) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}
