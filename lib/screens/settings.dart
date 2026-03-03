import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Tunatumia Consumer ili screen ijue wakati theme au lugha inabadilika
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Scaffold(
          // Tunatumia rangi ya background kulingana na theme
          backgroundColor: appState.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text(appState.t("Settings", "Mipangilio")),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 1. SEHEMU YA MUONEKANO
              _buildSectionTitle(appState.t("Appearance & Language", "Muonekano na Lugha")),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                color: appState.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                child: Column(
                  children: [
                    // THEME SWITCH (ON/OFF)
                    SwitchListTile(
                      secondary: Icon(
                        appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                        color: appState.isDarkMode ? Colors.amberAccent : Colors.indigo,
                      ),
                      title: Text(appState.t("Dark Mode", "Modi ya Giza")),
                      subtitle: Text(appState.t("Switch between light and dark", "Badili kati ya mwanga na giza")),
                      value: appState.isDarkMode,
                      onChanged: (val) => appState.toggleTheme(),
                      activeColor: const Color(0xFF6366F1),
                    ),
                    const Divider(height: 1),
                    
                    // LANGUAGE SELECTION (ENG/SWA)
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.blueAccent),
                      title: Text(appState.t("Language", "Lugha")),
                      subtitle: Text(appState.languageCode == 'en' ? "English" : "Kiswahili"),
                      trailing: DropdownButton<String>(
                        value: appState.languageCode,
                        underline: const SizedBox(), // Inaondoa mstari wa chini
                        onChanged: (String? val) {
                          if (val != null) appState.setLanguage(val);
                        },
                        items: [
                          DropdownMenuItem(
                            value: 'en', 
                            child: Text(appState.t("English", "Kiingereza")),
                          ),
                          DropdownMenuItem(
                            value: 'sw', 
                            child: Text(appState.t("Swahili", "Kiswahili")),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. SEHEMU YA WASIFU (PROFILE)
              _buildSectionTitle(appState.t("Business Profile", "Wasifu wa Biashara")),
              const SizedBox(height: 10),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: appState.isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(appState.t("User Name", "Jina la Mtumiaji")),
                      subtitle: Text(appState.userName),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.storefront_outlined),
                      title: Text(appState.t("Business Name", "Jina la Biashara")),
                      subtitle: Text(appState.businessName),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // VERSION INFO
              Center(
                child: Text(
                  "Biashara Smart v1.0.0",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget ya kusaidia kutengeneza vichwa vya habari vya sehemu (Sections)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold, 
          color: Color(0xFF6366F1),
          fontSize: 14,
        ),
      ),
    );
  }
}