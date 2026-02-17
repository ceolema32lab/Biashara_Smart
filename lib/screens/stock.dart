import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          appState.t("Stock Management", "Udhibiti wa Stoki"),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: appState.items.isEmpty
          ? _buildEmptyState(appState)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: appState.items.length,
              itemBuilder: (context, index) {
                final item = appState.items[index];
                return _buildStockCard(context, item, index, appState);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showStockDialog(context, appState),
        icon: const Icon(Icons.add_box_outlined, color: Colors.white),
        label: Text(
          appState.t("Add Item", "Ongeza Bidhaa"),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStockCard(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
    AppState appState,
  ) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        title: Text(
          item['name'] ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "${appState.t("Qty", "Zilizopo")}: ${item['quantity']} | ${appState.t("Price", "Bei")}: ${item['price']}",
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent),
              onPressed: () =>
                  _showStockDialog(context, appState, index: index, item: item),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () => appState.deleteStock(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppState appState) {
    return Center(
      child: Text(
        appState.t("No stock items yet", "Bado hakuna bidhaa"),
        style: const TextStyle(color: Colors.white24, fontSize: 16),
      ),
    );
  }

  void _showStockDialog(
    BuildContext context,
    AppState appState, {
    int? index,
    Map<String, dynamic>? item,
  }) {
    final isEditing = index != null;
    final nameController = TextEditingController(
      text: isEditing ? item!['name'] : "",
    );
    final qtyController = TextEditingController(
      text: isEditing ? item!['quantity'].toString() : "",
    );
    final priceController = TextEditingController(
      text: isEditing ? item!['price'].toString() : "",
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          isEditing
              ? appState.t("Edit Item", "Hariri Bidhaa")
              : appState.t("New Item", "Bidhaa Mpya"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              nameController,
              appState.t("Item Name", "Jina la Bidhaa"),
              Icons.shopping_bag_outlined,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              qtyController,
              appState.t("Quantity", "Idadi"),
              Icons.numbers,
              isNumber: true,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              priceController,
              appState.t("Buying Price", "Bei ya Kununua"),
              Icons.attach_money,
              isNumber: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(appState.t("Cancel", "Ghairi")),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            onPressed: () {
              // REKEBISHO: Kubadilisha String kwenda Double hapa
              final String name = nameController.text;
              final double qty = double.tryParse(qtyController.text) ?? 0.0;
              final double price = double.tryParse(priceController.text) ?? 0.0;

              if (name.isNotEmpty) {
                if (isEditing) {
                  // Tunatuma qty kama String hapa kwa sababu ya editStock definition yako
                  appState.editStock(index, name, qtyController.text, price);
                } else {
                  // Tunatuma qty kama double hapa
                  appState.addStock(name, qty, price);
                }
                Navigator.pop(context);
              }
            },
            child: Text(
              appState.t("Save", "Hifadhi"),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white30),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }
}
