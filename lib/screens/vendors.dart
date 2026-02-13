import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(
          appState.t("Suppliers & Vendors", "Wauzaji & Masupulaya"),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: appState.vendors.isEmpty
          ? _buildEmptyState(appState)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: appState.vendors.length,
              itemBuilder: (context, index) {
                final vendor = appState.vendors[index];
                return _buildVendorCard(context, vendor, index, appState);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => _showVendorDialog(context, appState),
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          appState.t("Add Vendor", "Ongeza Muuzaji"), 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }

  Widget _buildVendorCard(BuildContext context, Map<String, dynamic> vendor, int index, AppState appState) {
    return Card(
      color: const Color(0xFF1E293B),
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.storefront_outlined, color: Color(0xFF818CF8)),
        ),
        title: Text(
          vendor['name'] ?? 'Unknown', 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vendor['category'] ?? 'General', 
                style: const TextStyle(color: Colors.white54, fontSize: 13)
              ),
              const SizedBox(height: 2),
              Text(
                vendor['phone'] ?? 'No number', 
                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 12, fontWeight: FontWeight.w500)
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📞 CALL BUTTON
            IconButton(
              icon: const Icon(Icons.phone_forwarded_rounded, color: Colors.greenAccent, size: 20),
              onPressed: () async {
                final phone = vendor['phone']?.toString().replaceAll(RegExp(r'\s+'), '');
                if (phone != null && phone.isNotEmpty) {
                  final Uri url = Uri.parse("tel:$phone");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                }
              },
            ),
            // 🗑️ DELETE BUTTON (REKEBISHO: Const imeondolewa)
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.redAccent.withOpacity(0.6), size: 20),
              onPressed: () => _confirmDelete(context, appState, index),
            ),
          ],
        ),
        onTap: () => _showVendorDialog(context, appState, index: index, vendor: vendor),
      ),
    );
  }

  Widget _buildEmptyState(AppState appState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contact_phone_outlined, size: 80, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text(
            appState.t("No vendors added yet", "Bado hakuna wauzaji"), 
            style: const TextStyle(color: Colors.white24, fontSize: 16)
          ),
        ],
      ),
    );
  }

  void _showVendorDialog(BuildContext context, AppState appState, {int? index, Map<String, dynamic>? vendor}) {
    final isEditing = index != null;
    final nameController = TextEditingController(text: isEditing ? vendor!['name'] : "");
    final phoneController = TextEditingController(text: isEditing ? vendor!['phone'] : "");
    final catController = TextEditingController(text: isEditing ? vendor!['category'] : "");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isEditing ? appState.t("Edit Vendor", "Sahihisha Muuzaji") : appState.t("New Vendor", "Muuzaji Mpya"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nameController, appState.t("Vendor Name", "Jina la Muuzaji"), Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField(phoneController, appState.t("Phone Number", "Namba ya Simu"), Icons.phone_android, isPhone: true),
              const SizedBox(height: 15),
              _buildTextField(catController, appState.t("Category (e.g. Wholesaler)", "Aina (mf. Jumla)"), Icons.tag_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(appState.t("Cancel", "Ghairi"), style: const TextStyle(color: Colors.white38))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // REKEBISHO: Kutumia majina sahihi ya methods
                if (isEditing) {
                  appState.updateVendor(index, nameController.text, phoneController.text, catController.text);
                } else {
                  appState.addVendor(nameController.text, phoneController.text, catController.text);
                }
                Navigator.pop(context);
              }
            },
            child: Text(
              appState.t("Save", "Hifadhi"), 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPhone = false}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.white30, size: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1)),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState appState, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(appState.t("Remove Vendor?", "Mtoe Muuzaji?"), style: const TextStyle(color: Colors.white)),
        content: Text(
          appState.t("This will delete the vendor's contact details.", "Hii itafuta mawasiliano ya muuzaji huyu."),
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(appState.t("No", "Hapana"))),
          TextButton(
            onPressed: () {
              // REKEBISHO: Kutumia removeVendor badala ya deleteVendor
              appState.removevendor (index);
              Navigator.pop(context);
            },
            child: Text(appState.t("Delete", "Futa"), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}