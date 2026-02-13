import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Hakikisha umeongeza: flutter pub add intl
import '../providers/app_state.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  String? selectedItem;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          appState.t("Sales Records", "Kumbukumbu za Mauzo"),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSaleInput(appState),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Colors.white10),
          ),
          Expanded(
            child: appState.sales.isEmpty
                ? _buildEmptyState(appState)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: appState.sales.length,
                    itemBuilder: (context, index) {
                      final sale = appState.sales[index];
                      return _buildSaleCard(sale, index, appState);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleInput(AppState appState) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1E293B),
            value: selectedItem,
            hint: Text(appState.t("Select Item", "Chagua Bidhaa"), 
                style: const TextStyle(color: Colors.white54)),
            items: appState.items.map((item) {
              return DropdownMenuItem<String>(
                value: item['name'],
                child: Text(item['name'], style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedItem = val;
                // Kinga dhidi ya makosa ikiwa bidhaa haipo
                final item = appState.items.firstWhere(
                  (i) => i['name'] == val,
                  orElse: () => {'price': 0.0},
                );
                priceController.text = item['price'].toString();
              });
            },
            decoration: _inputDecoration(""),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(appState.t("Qty", "Idadi")),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(appState.t("Total Price", "Jumla Kuu")),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final double? qty = double.tryParse(qtyController.text);
                final double? total = double.tryParse(priceController.text);

                if (selectedItem != null && qty != null && total != null && qty > 0) {
                  // Tunapitisha 'total' moja kwa moja kama ilivyo kwenye AppState mpya
                  appState.addSale(total, selectedItem!, qty);
                  
                  // Safisha fomu
                  qtyController.clear();
                  priceController.clear();
                  setState(() => selectedItem = null);
                  
                  FocusScope.of(context).unfocus(); // Funga keyboard
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(appState.t("Invalid input", "Ingizo si sahihi")))
                  );
                }
              },
              child: Text(appState.t("Record Sale", "Rekodi Mauzo"), 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaleCard(Map<String, dynamic> sale, int index, AppState appState) {
    // Kutengeneza muundo wa tarehe unaosomeka
    final String formattedDate = sale['date'] != null 
        ? DateFormat('dd MMM, hh:mm a').format(sale['date']) 
        : "--:--";

    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(sale['name'] ?? 'Item', 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${sale['quantity']} x TSh ${sale['price']?.toStringAsFixed(0) ?? '0'}", 
              style: const TextStyle(color: Colors.white60)
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Color(0xFF6366F1)),
                const SizedBox(width: 4),
                Text(formattedDate, style: const TextStyle(color: Color(0xFF6366F1), fontSize: 11)),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "TSh ${sale['total']}", 
              style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => appState.deleteSale(index),
              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
          Icon(Icons.receipt_long, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text(appState.t("No sales recorded", "Hakuna mauzo yaliyorekodiwa"), 
              style: const TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}