import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class PdfService {
  static Future<void> generateInventoryReport(AppState appState) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // --- HEADER ---
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(appState.businessName.toUpperCase(),
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
                    pw.Text(appState.t("Business Performance Report", "Ripoti ya Utendaji wa Biashara")),
                    pw.Text("${appState.t("Date", "Tarehe")}: $date", style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.PdfLogo(),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1, color: PdfColors.grey300),
            pw.SizedBox(height: 20),

            // --- MUHTASARI (SUMMARY CARDS) ---
            pw.Text(appState.t("Financial Summary", "Muhtasari wa Fedha"),
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(appState.t("Total Sales", "Mauzo"), currencyFormat.format(appState.totalSales)),
                _buildStatItem(appState.t("Expenses", "Gharama"), currencyFormat.format(appState.totalExpenses)),
                _buildStatItem(appState.t("Net Profit", "Faida"), currencyFormat.format(appState.totalProfit), isProfit: true),
              ],
            ),
            pw.SizedBox(height: 30),

            // --- JEDWALI LA BIDHAA (STOCK TABLE) ---
            pw.Text(appState.t("Current Inventory", "Hali ya Stoo kwa Sasa"),
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              headers: [
                appState.t("Item Name", "Jina la Bidhaa"),
                appState.t("Qty", "Idadi"),
                appState.t("Price", "Bei"),
              ],
              data: appState.items.map((item) => [
                item['name'],
                item['quantity'].toString(),
                currencyFormat.format(item['price']),
              ]).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
              cellHeight: 25,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
                2: pw.Alignment.centerRight,
              },
            ),

            pw.Spacer(),

            // --- FOOTER ---
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Biashara Smart App", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey)),
                pw.Text("Developed by: Amana Lema", 
                    style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo)),
              ],
            ),
          ];
        },
      ),
    );

    // Kufungua Print Preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ripoti_${appState.businessName}.pdf',
    );
  }

  static pw.Widget _buildStatItem(String label, String value, {bool isProfit = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value, 
              style: pw.TextStyle(
                fontSize: 12, 
                fontWeight: pw.FontWeight.bold,
                color: isProfit ? PdfColors.green : PdfColors.black,
              )),
        ],
      ),
    );
  }
}