import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../services/report_service.dart';
import 'ai_assistant.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      // MUHIMU: Tumeondoa "drawer: const AppDrawer()" hapa 
      // ili kuzuia kutokea kwa Drawer mbili. 
      // Sasa itatumia Drawer iliyopo kwenye MainNavigation.

      appBar: AppBar(
        // Hii inahakikisha icon ya Drawer (Hamburger icon) inaonekana
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Hii inafungua Drawer ya mzazi (MainNavigation)
            Scaffold.of(context).openDrawer();
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${appState.t("Hello", "Habari")}, ${appState.userName}", 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
            ),
            Text(
              appState.businessName, 
              style: const TextStyle(fontSize: 12, color: Colors.white54)
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => ReportService.generatePdf(appState),
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            tooltip: appState.t("Export PDF", "Toa Ripoti"),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const AIAssistantPage())
              );
            }, 
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent)
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.loadProfile(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. PROFIT OVERVIEW
              _buildMainCard(appState, currencyFormat),
              const SizedBox(height: 20),

              // 2. AI QUICK INSIGHT
              _buildAIQuickInsight(appState),
              const SizedBox(height: 25),

              // 3. PERFORMANCE STATS
              Text(
                appState.t("Performance", "Utendaji"), 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.4,
                children: [
                  _buildSmallStatCard(
                    appState.t("Total Sales", "Mauzo"), 
                    currencyFormat.format(appState.totalSales), 
                    Icons.trending_up, Colors.greenAccent
                  ),
                  _buildSmallStatCard(
                    appState.t("Expenses", "Matumizi"), 
                    currencyFormat.format(appState.totalExpenses), 
                    Icons.trending_down, Colors.redAccent
                  ),
                  _buildSmallStatCard(
                    appState.t("Stock Items", "Bidhaa"), 
                    "${appState.items.length}", 
                    Icons.inventory_2, Colors.blueAccent
                  ),
                  _buildSmallStatCard(
                    appState.t("Vendors", "Wauzaji"), 
                    "${appState.vendors.length}", 
                    Icons.people_outline, Colors.orangeAccent
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 4. STOCK HEALTH
              Text(
                appState.t("Inventory Health", "Hali ya Stoo"), 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 15),
              _buildStockCard(appState),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildMainCard(AppState appState, NumberFormat format) {
    bool isLoss = appState.totalProfit < 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLoss 
            ? [const Color(0xFFEF4444), const Color(0xFF991B1B)] 
            : [const Color(0xFF6366F1), const Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLoss ? appState.t("Total Loss", "Hasara ya Jumla") : appState.t("Total Profit", "Faida ya Jumla"), 
            style: const TextStyle(color: Colors.white70, fontSize: 14)
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              format.format(appState.totalProfit),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIQuickInsight(AppState appState) {
    String insight = appState.getAIResponse("insight");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              insight,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(AppState appState) {
    double pct = appState.stockStatusPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), 
        borderRadius: BorderRadius.circular(18)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appState.t("Stock Level", "Kiwango cha Stoo"), style: const TextStyle(color: Colors.white70)),
              Text("${(pct * 100).toStringAsFixed(0)}%", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white10,
            color: Colors.blueAccent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}