import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../services/pdf_service.dart'; // Hakikisha hii ipo

class DashboardPage extends StatelessWidget {
  final VoidCallback? onMenuPressed;
  
  const DashboardPage({super.key, this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    // Tunatumia watch hapa ili UI ijisasishe data zikibadilika
    final appState = context.watch<AppState>();
    final currencyFormat = NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      // Rangi ya background inategemea mode
      backgroundColor: appState.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Kitufe cha Menu
        leading: IconButton(
          icon: Icon(
            Icons.menu, 
            color: appState.isDarkMode ? Colors.white : Colors.black87
          ),
          onPressed: onMenuPressed,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${appState.t("Hello", "Habari")}, ${appState.userName}",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: appState.isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              appState.businessName,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      
      body: RefreshIndicator(
        onRefresh: () => appState.loadProfile(),
        color: const Color(0xFF6366F1),
        child: SingleChildScrollView(
          // AlwaysScrollable inaruhusu RefreshIndicator kufanya kazi hata kama list ni fupi
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KADI KUU YA FAIDA
              _buildMainProfitCard(appState, currencyFormat),
              const SizedBox(height: 20),

              // 2. AI QUICK INSIGHT
              _buildAIInsightBox(appState),
              const SizedBox(height: 25),

              // 3. SEHEMU YA RIPOTI (PDF ICON)
              _buildReportSection(context, appState),
              const SizedBox(height: 25),

              Text(
                appState.t("Business Performance", "Utendaji wa Biashara"),
                style: TextStyle(
                  color: appState.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // 4. GRID YA TAKWIMU (4 Cards)
              Row(
                children: [
                  Expanded(child: _buildSmallStatCard(
                    appState.t("Sales", "Mauzo"),
                    currencyFormat.format(appState.totalSales),
                    Icons.trending_up,
                    Colors.greenAccent,
                    appState.isDarkMode,
                  )),
                  const SizedBox(width: 15),
                  Expanded(child: _buildSmallStatCard(
                    appState.t("Expenses", "Gharama"),
                    currencyFormat.format(appState.totalExpenses),
                    Icons.trending_down,
                    Colors.redAccent,
                    appState.isDarkMode,
                  )),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildSmallStatCard(
                    appState.t("Stock Items", "Bidhaa"),
                    "${appState.items.length}",
                    Icons.inventory_2_outlined,
                    Colors.blueAccent,
                    appState.isDarkMode,
                  )),
                  const SizedBox(width: 15),
                  Expanded(child: _buildSmallStatCard(
                    appState.t("Vendors", "Wauzaji"),
                    "${appState.vendors.length}",
                    Icons.people_outline,
                    Colors.orangeAccent,
                    appState.isDarkMode,
                  )),
                ],
              ),

              const SizedBox(height: 25),

              // 5. STOCK LEVEL PROGRESS
              _buildStockLevelCard(appState),
              const SizedBox(height: 30), // Nafasi ya chini
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER METHODS ---

  Widget _buildReportSection(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appState.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.indigo.withOpacity(appState.isDarkMode ? 0.2 : 0.5)
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.t("Business Report", "Ripoti ya Biashara"),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                appState.t("Export data to PDF", "Toa takwimu kwa PDF"),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          // KITUFE CHA PDF - SASA KINAFANYA KAZI
          IconButton(
            onPressed: () async {
              // Onyesha SnackBar kidogo kumpa mtumiaji feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(appState.t("Preparing Report...", "Inaandaa Ripoti...")),
                  duration: const Duration(seconds: 1),
                ),
              );
              // Ita huduma ya PDF
              await PdfService.generateInventoryReport(appState);
            },
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
            tooltip: "Download PDF",
          ),
        ],
      ),
    );
  }

  Widget _buildMainProfitCard(AppState appState, NumberFormat format) {
    bool isLoss = appState.totalProfit < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLoss 
            ? [const Color(0xFFEF4444), const Color(0xFF991B1B)] 
            : [const Color(0xFF6366F1), const Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isLoss ? Colors.red : Colors.indigo).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.t("Net Profit", "Faida Halisi"),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              format.format(appState.totalProfit),
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 32, 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightBox(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appState.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amberAccent.withOpacity(appState.isDarkMode ? 0.2 : 0.5)
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appState.t(
                "AI: Your sales are up 12% this week. Keep it up!",
                "AI: Mauzo yako yameongezeka kwa 12% wiki hii. Kazana!"
              ),
              style: TextStyle(
                color: appState.isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      height: 100, 
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              FittedBox(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockLevelCard(AppState appState) {
    double pct = appState.stockStatusPercentage.clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appState.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: appState.isDarkMode ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                appState.t("Inventory Status", "Hali ya Stoo"), 
                style: TextStyle(
                  color: appState.isDarkMode ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500
                )
              ),
              Text(
                "${(pct * 100).toStringAsFixed(0)}%", 
                style: TextStyle(
                  color: pct < 0.3 ? Colors.redAccent : Colors.blueAccent, 
                  fontWeight: FontWeight.bold
                )
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.withOpacity(0.2),
              color: pct < 0.3 ? Colors.redAccent : Colors.blueAccent,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}