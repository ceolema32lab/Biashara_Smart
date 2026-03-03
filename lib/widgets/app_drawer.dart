import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Drawer(
      child: Column(
        children: [
          // Sehemu ya juu ya Drawer (Header)
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
              ),
            ),
            accountName: Text(
              appState.businessName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(appState.userName),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.business, size: 40, color: Color(0xFF6366F1)),
            ),
          ),

          // Mpangilio wa Menu
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(appState.t("Dark Mode", "Modi ya Giza")),
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (v) => appState.toggleTheme(),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(appState.t("Language", "Lugha")),
            trailing: DropdownButton<String>(
              value: appState.languageCode,
              underline: const SizedBox(),
              onChanged: (v) => appState.setLanguage(v!),
              items: const [
                DropdownMenuItem(value: 'en', child: Text("🇺🇸 ENG")),
                DropdownMenuItem(value: 'sw', child: Text("🇹🇿 SWA")),
              ],
            ),
          ),

          const Divider(),

          // --- SEHEMU YA "ABOUT US" ILIYOSAHIHISHWA ---
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.indigo),
            title: Text(appState.t("About Us", "Kuhusu Sisi")),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Biashara Smart",
                applicationVersion: "1.0.0",
                applicationIcon: const Icon(Icons.auto_awesome, color: Colors.indigo, size: 40),
                children: [
                  const SizedBox(height: 15),
                  Text(appState.t(
                    "Biashara Smart is an AI-powered business management tool designed to help entrepreneurs track sales, expenses, and growth efficiently.",
                    "Biashara Smart ni mfumo wa usimamizi wa biashara unaotumia akili mnemba (AI) kusaidia wajasiriamali kufuatilia mauzo, gharama, na ukuaji."
                  )),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    "Developed By: Amana Lema",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appState.t("Contact Us:", "Wasiliana nasi:"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text("📞 +255 652 011 049"),
                  const Text("📧 info@biasharasmart.com"),
                  const SizedBox(height: 15),
                  Text(
                    appState.t("#Stay Blessed", "#Barikiwa Sana"),
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}