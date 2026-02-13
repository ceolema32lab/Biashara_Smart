import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          // SEHEMU YA JUU (HEADER)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF0F172A)),
            accountName: Text(
              appState.userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(appState.businessName),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Color(0xFF6366F1),
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
          ),

          // NAVIGATION LINKS
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: appState.t("Dashboard", "Dashibodi"),
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          _buildDrawerItem(
            icon: Icons.shopping_cart_outlined,
            title: appState.t("Sales", "Mauzo"),
            onTap: () => Navigator.pushNamed(context, '/sales'),
          ),
          _buildDrawerItem(
            icon: Icons.inventory_2_outlined,
            title: appState.t("Stock", "Stoki"),
            onTap: () => Navigator.pushNamed(context, '/stock'),
          ),
          _buildDrawerItem(
            icon: Icons.account_balance_wallet_outlined,
            title: appState.t("Expenses", "Matumizi"),
            onTap: () => Navigator.pushNamed(context, '/expenses'),
          ),

          const Divider(color: Colors.white10),

          // SETTINGS (LANGUAGE & THEME)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  appState.t("Language", "Lugha"),
                  style: const TextStyle(color: Colors.white70),
                ),
                DropdownButton<String>(
                  value: appState.language,
                  dropdownColor: const Color(0xFF1E293B),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text("EN", style: TextStyle(color: Colors.white))),
                    DropdownMenuItem(value: 'sw', child: Text("SW", style: TextStyle(color: Colors.white))),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      appState.setLanguage(newValue);
                    }
                  },
                ),
              ],
            ),
          ),

          ListTile(
            leading: Icon(
              appState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white70,
            ),
            title: Text(
              appState.t("Theme", "Muonekano"),
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (value) => appState.toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}