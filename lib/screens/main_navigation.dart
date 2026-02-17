// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'dashboard.dart';
import 'sales.dart';
import 'expenses.dart';
import 'stock.dart';
import 'ai_assistant.dart';
import 'vendors.dart'; // Hakikisha hii ipo!

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const SalesPage(),
    const ExpensesPage(),
    const StockPage(),
    const VendorsPage(), // Tumeirudisha hapa namba 4
    const AIAssistantPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      // drawer: const AppDrawer(),
      // appBar: AppBar(
      //   title: Text(appState.t("Biashara Smart", "Biashara Janja")),
      //   actions: [
      //     IconButton(
      //       icon: Icon(appState.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      //       onPressed: () => appState.toggleTheme(),
      //     )
      //   ],
      // ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed, // Muhimu kwa icons nyingi
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: appState.t("Home", "Home"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_up),
            label: appState.t("Sales", "Mauzo"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.trending_down),
            label: appState.t("Exp", "Gharama"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.inventory_2_outlined),
            label: appState.t("Stock", "Stoo"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people_outline),
            label: appState.t("Vendors", "Wauzaji"),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_awesome),
            label: appState.t("AI", "AI"),
          ),
        ],
      ),
    );
  }
}
