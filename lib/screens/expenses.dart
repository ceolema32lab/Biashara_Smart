import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currencyFormat = NumberFormat.currency(symbol: 'TZS ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          appState.t("Expense Tracker", "Mfuatiliaji wa Matumizi"),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildTotalExpensesHeader(appState, currencyFormat),
          Expanded(
            child: appState.expenses.isEmpty
                ? _buildEmptyState(appState)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: appState.expenses.length,
                    itemBuilder: (context, index) {
                      // Kuonyesha mpya juu (Reversed)
                      final int originalIndex = appState.expenses.length - 1 - index;
                      final expense = appState.expenses[originalIndex];
                      return _buildExpenseTile(context, expense, originalIndex, appState, currencyFormat);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showExpenseDialog(context, appState),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: Text(
          appState.t("Add Expense", "Ongeza Gharama"), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildTotalExpensesHeader(AppState appState, NumberFormat format) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(appState.t("Total Spending", "Jumla ya Matumizi"), 
            style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            format.format(appState.totalExpenses),
            style: const TextStyle(color: Colors.redAccent, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseTile(BuildContext context, Map<String, dynamic> expense, int index, AppState appState, NumberFormat format) {
    final DateTime date = expense['date'] ?? DateTime.now();

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.redAccent, size: 22),
        ),
        title: Text(
          format.format(expense['amount']), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Text(
          "${expense['category']}\n${DateFormat('d MMM yyyy • HH:mm').format(date)}",
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent, size: 20),
              onPressed: () => _showExpenseDialog(context, appState, index: index, expense: expense),
            ),
            // REKEBISHO: Const imeondolewa hapa kuzuia Error ya withOpacity
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.5), size: 20),
              onPressed: () => _confirmDelete(context, appState, index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(appState.t("No expenses recorded yet", "Bado hujasajili matumizi"), 
            style: const TextStyle(color: Colors.white24, fontSize: 16)),
        ],
      ),
    );
  }

  void _showExpenseDialog(BuildContext context, AppState appState, {int? index, Map<String, dynamic>? expense}) {
    final isEditing = index != null;
    final amountController = TextEditingController(text: isEditing ? expense!['amount'].toString() : "");
    final categoryController = TextEditingController(text: isEditing ? expense!['category'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? appState.t("Edit Expense", "Hariri Matumizi") : appState.t("New Expense", "Matumizi Mapya"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(amountController, appState.t("Amount (TZS)", "Kiasi (TZS)"), Icons.money, isNumeric: true),
            const SizedBox(height: 15),
            _buildTextField(categoryController, appState.t("Category", "Aina"), Icons.category_outlined),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.t("Cancel", "Ghairi"), style: const TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              final double? amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                if (isEditing) {
                  appState.editExpense(index, amount, categoryController.text);
                } else {
                  appState.addExpense(amount, categoryController.text);
                }
                Navigator.pop(context);
              }
            },
            child: Text(appState.t("Save", "Hifadhi"), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumeric = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1))),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(appState.t("Delete?", "Futa?"), style: const TextStyle(color: Colors.white)),
        content: Text(appState.t("Are you sure?", "Una uhakika?"), style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.t("No", "Hapana"))),
          TextButton(
            onPressed: () {
              appState.deleteExpense(index);
              Navigator.pop(context);
            }, 
            child: Text(appState.t("Delete", "Futa"), style: const TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }
}