import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AccountPrintService {
  static const double fontSize = 8.0;
  static const double smallFontSize = 7.0;
  static const double headerSize = 14.0;

  static Future<void> printReport({
    required String title,
    required List<Map<String, dynamic>> ledgerData,
    required String Function(dynamic val) numberFormat,
    required List<Map<String, String>> columns,
    Map<String, String>? summary,
    List<Map<String, String>>? breakdowns,
  }) async {
    final dateStr = DateTime.now().toString().substring(0, 19);

    try {
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
        final pageFormat = PdfPageFormat(PdfPageFormat.a4.width, PdfPageFormat.a4.height, marginAll: 8);

        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            maxPages: 500,
            pageFormat: pageFormat,
            header: (ctx) => pw.Container(
            width: double.infinity,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: headerSize, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 2),
                pw.Text('Printed: $dateStr', style: pw.TextStyle(fontSize: smallFontSize, color: PdfColors.grey)),
                pw.Divider(),
                pw.SizedBox(height: 4),
              ],
            ),
          ),
          build: (ctx) => [
            if (summary != null) _buildSummary(summary, numberFormat),
            if (breakdowns != null && breakdowns.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              _buildBreakdowns(breakdowns, numberFormat),
            ],
            if (ledgerData.isNotEmpty) ...[
              pw.SizedBox(height: 6),
              pw.Divider(),
              pw.Text('Ledger Entries (${ledgerData.length})', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              _buildTable(ledgerData, columns, numberFormat),
            ],
            pw.SizedBox(height: 16),
            pw.Text('--- End of Report ---', style: pw.TextStyle(fontSize: smallFontSize, color: PdfColors.grey), textAlign: pw.TextAlign.center),
          ],
        ),
      );

        return pdf.save();
      });
    } catch (e) {
      throw Exception('Print failed: ${e.toString()}');
    }
  }

  static pw.Widget _buildSummary(Map<String, String> items, String Function(dynamic) nf) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: items.entries.map((e) => pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 1),
          child: pw.Row(children: [
            pw.Text('${e.key}: ', style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold)),
            pw.Text(e.value, style: pw.TextStyle(fontSize: fontSize)),
          ]),
        )).toList(),
      ),
    );
  }

  static pw.Widget _buildBreakdowns(List<Map<String, String>> data, String Function(dynamic) nf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Account Breakdown', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        ...data.map((r) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 1, horizontal: 2),
          decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200))),
          child: pw.Row(children: r.entries.map((e) => pw.Expanded(
            child: pw.Text('${e.key}: ${e.value}', style: pw.TextStyle(fontSize: smallFontSize)),
          )).toList()),
        )),
      ],
    );
  }

  static pw.Widget _buildTable(List<Map<String, dynamic>> data, List<Map<String, String>> columns, String Function(dynamic) nf) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: smallFontSize, fontWeight: pw.FontWeight.bold),
      cellStyle: pw.TextStyle(fontSize: smallFontSize),
      headerDecoration: pw.BoxDecoration(color: PdfColors.grey200),
        columnWidths: Map.fromEntries(columns.asMap().entries.map((e) {
        final key = (e.value['key'] ?? '').toLowerCase();
        final isAmount = e.value['type'] == 'amount';
        if (isAmount) {
          return MapEntry(e.key, const pw.FlexColumnWidth(1.2));
        }
        if (key.contains('name') || key.contains('description') || key.contains('remark')) {
          return MapEntry(e.key, const pw.FlexColumnWidth(3));
        }
        if (key.contains('loca') || key.contains('method') || key.contains('status') || key.contains('type') || key.contains('no')) {
          return MapEntry(e.key, const pw.FlexColumnWidth(1.3));
        }
        if (key.contains('date') || key.contains('code')) {
          return MapEntry(e.key, const pw.FlexColumnWidth(1.5));
        }
        return MapEntry(e.key, const pw.FlexColumnWidth(2));
      })),
      cellAlignments: Map.fromEntries(columns.asMap().entries.map((e) => MapEntry(e.key, pw.Alignment.centerLeft))),
      headers: columns.map((c) => c['label'] ?? '').toList(),
      data: data.map((r) => columns.map((c) {
        final key = c['key'] ?? '';
        final isAmount = c['type'] == 'amount';
        return isAmount ? nf(r[key]) : (r[key]?.toString() ?? '');
      }).toList()).toList(),
    );
  }
}