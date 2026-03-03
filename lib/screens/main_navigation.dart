import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/app_drawer.dart';
import 'dashboard.dart';
import 'sales.dart';
import 'expenses.dart';
import 'stock.dart';
import 'vendors.dart';
import 'ai_assistant.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // 1. Hakikisha Key imetengenezwa hapa
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // 2. MUHIMU: Hamisha orodha ya kurasa iingie NDANI ya build
    final List<Widget> _pages = [
      DashboardPage(onMenuPressed: () {
        _scaffoldKey.currentState?.openDrawer();
      }),
      const SalesPage(),
      const ExpensesPage(),
      const StockPage(),
      const VendorsPage(),
      const AIAssistantPage(),
    ];

    return Scaffold(
      // 3. Hakikisha Key imeunganishwa hapa
      key: _scaffoldKey, 
      drawer: const AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: appState.t("Home", "Nyumbani")),
          BottomNavigationBarItem(icon: const Icon(Icons.trending_up), label: appState.t("Sales", "Mauzo")),
          BottomNavigationBarItem(icon: const Icon(Icons.money_off), label: appState.t("Expenses", "Gharama")),
          BottomNavigationBarItem(icon: const Icon(Icons.inventory), label: appState.t("Stock", "Stoo")),
          BottomNavigationBarItem(icon: const Icon(Icons.people), label: appState.t("Vendors", "Wauzaji")),
          BottomNavigationBarItem(icon: const Icon(Icons.auto_awesome), label: appState.t("AI", "AI")),
        ],
      ),
    );
  }
}