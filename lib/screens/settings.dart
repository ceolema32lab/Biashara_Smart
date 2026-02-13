import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(appState.t("Settings", "Mipangilio"))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(appState.t("Appearance & Language", "Muonekano na Lugha"), 
               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          const SizedBox(height: 10),
          Card(
            child: Column(
              children: [
                // THEME SWITCH
                SwitchListTile(
                  secondary: Icon(appState.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  title: Text(appState.t("Dark Mode", "Modi ya Giza")),
                  value: appState.isDarkMode,
                  onChanged: (val) => appState.toggleTheme(),
                ),
                const Divider(),
                // LANGUAGE DROPDOWN
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(appState.t("Language", "Lugha")),
                  trailing: DropdownButton<String>(
                    value: appState.language,
                    onChanged: (String? val) => appState.setLanguage(val!),
                    items: ['English', 'Swahili'].map((String lang) {
                      return DropdownMenuItem(value: lang, child: Text(lang));
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}