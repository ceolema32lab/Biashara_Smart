import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import 'ai_assistant.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen is true kuhakikisha UI inabadilika data ikibadilika
    final appState = Provider.of<AppState>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          "${appState.t("Hello", "Habari")}, ${appState.userName}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Quick Access to AI Assistant
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AIAssistantPage()),
              );
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.businessName,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // 💰 PROFIT CARD (Sasa inatumia totalProfit badala ya profit ya zamani)
              _buildProfitCard(appState, currencyFormat),
              const SizedBox(height: 20),

              // 🤖 QUICK AI INSIGHT SECTION
              _buildAIInsightBar(appState, context),
              const SizedBox(height: 20),

              // 📊 MINI STATS (Sales & Expenses)
              Row(
                children: [
                  Expanded(
                    child: _buildStatTile(
                      appState.t("Sales", "Mauzo"),
                      appState.totalSales,
                      Colors.greenAccent,
                      currencyFormat,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatTile(
                      appState.t("Expenses", "Matumizi"),
                      appState.totalExpenses,
                      Colors.redAccent,
                      currencyFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 📦 STOCK SECTION
              Text(
                appState.t("Inventory Status", "Hali ya Stoo"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildStockSection(appState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfitCard(AppState appState, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appState.t("Real Net Profit", "Faida Halisi"),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            format.format(appState.totalProfit),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            appState.t("After COGS deduction", "Baada ya kutoa gharama ya mzigo"),
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightBar(AppState appState, BuildContext context) {
    String tip = appState.getAIResponse(appState.t("advice", "ushauri"));

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AIAssistantPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amberAccent.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.amberAccent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String label, double value, Color color, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          const SizedBox(height: 5),
          Text(
            format.format(value),
            style: TextStyle(
              color: color, 
              fontSize: 13, 
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSection(AppState appState) {
    double pct = appState.stockStatusPercentage;
    bool isEmpty = appState.items.isEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: pct,
            backgroundColor: Colors.white10,
            color: isEmpty
                ? Colors.grey
                : (pct < 0.2 ? Colors.orangeAccent : Colors.blueAccent),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEmpty ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                size: 16,
                color: isEmpty ? Colors.redAccent : Colors.greenAccent,
              ),
              const SizedBox(width: 8),
              Text(
                isEmpty
                    ? appState.t("No stock added yet.", "Bado hujaweka bidhaa.")
                    : "${(pct * 100).toStringAsFixed(0)}% " +
                        appState.t("Stock Level", "Kiwango cha Stoo"),
                style: TextStyle(
                  color: isEmpty ? Colors.redAccent : Colors.white70,
                  fontSize: 13,
                  fontWeight: isEmpty ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}