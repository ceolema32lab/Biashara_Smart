import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../providers/app_state.dart';

class ReportService {
  static Future<void> generatePdf(AppState appState) async {
    final pdf = pw.Document();

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // HEADER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(appState.businessName,
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Ripoti ya Biashara",
                          style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Imetolewa na: ${appState.userName}"),
                      pw.Text("Tarehe: ${DateTime.now().toString().split(' ')[0]}"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 2, color: PdfColors.blueAccent),
              pw.SizedBox(height: 20),

              // SUMMARY BOXES
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryBox("Mauzo", "TSh ${appState.totalSales.toStringAsFixed(0)}"),
                  _buildSummaryBox("Matumizi", "TSh ${appState.totalExpenses.toStringAsFixed(0)}"),
                  _buildSummaryBox("Faida", "TSh ${appState.totalProfit.toStringAsFixed(0)}"),
                ],
              ),
              pw.SizedBox(height: 30),

              // SALES TABLE
              pw.Text("Miamala ya Mauzo",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              
              appState.sales.isEmpty 
                ? pw.Text("Hakuna mauzo yaliyofanyika bado.")
                : pw.TableHelper.fromTextArray(
                    headers: ['Bidhaa', 'Idadi', 'Bei', 'Jumla'],
                    data: appState.sales.map((s) => [
                      s['name'],
                      s['quantity'].toString(),
                      s['price'].toStringAsFixed(0),
                      s['total'].toStringAsFixed(0),
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                        color: PdfColors.white, fontWeight: pw.FontWeight.bold),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey900),
                    cellAlignment: pw.Alignment.centerLeft,
                    // HAPA NDIPO PAMEBADILIKA:
                    rowDecoration: const pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))
                    ),
                  ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Ripoti_ya_${appState.businessName}.pdf',
      );
      
    } catch (e) {
      print("PDF Error: $e");
    }
  }

  static pw.Widget _buildSummaryBox(String label, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue900),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 5),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }
}