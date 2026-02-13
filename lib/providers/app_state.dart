import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppState extends ChangeNotifier {
  AppState() {
    loadProfile(); // Inapakia data zote app ikifunguka
  }

  // --- SETTINGS & PROFILE ---
  bool isDarkMode = true;
  String language = 'en';
  String userName = "User";
  String businessName = "My Business";

  // --- DATA LISTS ---
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> vendors = [];

  // --- Mfumo wa Kuhifadhi Data (Save/Load) ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setString('items', jsonEncode(items));
    prefs.setString('vendors', jsonEncode(vendors));
    
    // Geuza tarehe kuwa String ili zisave-ike kwenye JSON
    prefs.setString('sales', jsonEncode(sales.map((s) {
      var map = Map<String, dynamic>.from(s);
      map['date'] = (map['date'] as DateTime).toIso8601String();
      return map;
    }).toList()));

    prefs.setString('expenses', jsonEncode(expenses.map((e) {
      var map = Map<String, dynamic>.from(e);
      map['date'] = (map['date'] as DateTime).toIso8601String();
      return map;
    }).toList()));

    prefs.setString('userName', userName);
    prefs.setString('businessName', businessName);
    prefs.setString('language', language);
    prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "User";
    businessName = prefs.getString('businessName') ?? "My Business";
    language = prefs.getString('language') ?? "en";
    isDarkMode = prefs.getBool('isDarkMode') ?? true;

    try {
      String? itemsJson = prefs.getString('items');
      if (itemsJson != null) items = List<Map<String, dynamic>>.from(jsonDecode(itemsJson));

      String? salesJson = prefs.getString('sales');
      if (salesJson != null) {
        sales = List<Map<String, dynamic>>.from(jsonDecode(salesJson)).map((s) {
          s['date'] = DateTime.parse(s['date']);
          return s;
        }).toList();
      }

      String? expensesJson = prefs.getString('expenses');
      if (expensesJson != null) {
        expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson)).map((e) {
          e['date'] = DateTime.parse(e['date']);
          return e;
        }).toList();
      }

      String? vendorsJson = prefs.getString('vendors');
      if (vendorsJson != null) vendors = List<Map<String, dynamic>>.from(jsonDecode(vendorsJson));
    } catch (e) {
      debugPrint("Error loading data: $e");
    }

    notifyListeners();
  }

  // --- METHODS ZILIZOKOSEKANA (Correcting Errors) ---

  // 1. updateProfile
  Future<void> updateProfile(String name, String bName) async {
    userName = name;
    businessName = bName;
    await _saveToPrefs();
    notifyListeners();
  }

  // 2. setLanguage
  void setLanguage(String lang) {
    language = lang;
    _saveToPrefs();
    notifyListeners();
  }

  // 3. deleteSale
  void deleteSale(int index) {
    if (index >= 0 && index < sales.length) {
      sales.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 4. deleteExpense
  void deleteExpense(int index) {
    if (index >= 0 && index < expenses.length) {
      expenses.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 5. deleteStock
  void deleteStock(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 6. editStock
  void editStock(int index, String name, String quantityStr, double price) {
    double qty = double.tryParse(quantityStr) ?? 0.0;
    if (index >= 0 && index < items.length) {
      items[index] = {'name': name, 'quantity': qty, 'price': price};
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 7. removevendor (v ndogo kama inavyotafutwa na screen)
  void removevendor(int index) {
    if (index >= 0 && index < vendors.length) {
      vendors.removeAt(index);
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 8. updateVendor
  void updateVendor(int index, String name, String phone, String category) {
    if (index >= 0 && index < vendors.length) {
      vendors[index] = {'name': name, 'phone': phone, 'category': category};
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 9. editExpense
  void editExpense(int index, double amount, String category) {
    if (index >= 0 && index < expenses.length) {
      expenses[index] = {
        'amount': amount,
        'category': category,
        'date': expenses[index]['date']
      };
      _saveToPrefs();
      notifyListeners();
    }
  }

  // 10. getAIResponse (Inatumika Dashboard na AI Assistant)
  String getAIResponse(String query) {
    String q = query.toLowerCase();
    if (q.contains("profit") || q.contains("faida")) {
      return "Jumla ya faida ni TSh $totalProfit (Mauzo $totalSales - Matumizi $totalExpenses).";
    } else if (q.contains("sales") || q.contains("mauzo")) {
      return "Umefanya mauzo ya TSh $totalSales leo.";
    }
    return "Nipo hapa kukusaidia kusimamia $businessName!";
  }

  // --- ZINGINEZO ---
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _saveToPrefs();
    notifyListeners();
  }

  String t(String en, String sw) => language == 'sw' ? sw : en;

  void addStock(String name, double quantity, double price) {
    items.add({'name': name, 'quantity': quantity, 'price': price});
    _saveToPrefs();
    notifyListeners();
  }

  void addSale(double total, String itemName, double qty) {
    sales.insert(0, {
      'name': itemName,
      'quantity': qty,
      'price': qty > 0 ? total / qty : 0,
      'total': total,
      'date': DateTime.now(),
    });
    _saveToPrefs();
    notifyListeners();
  }

  void addExpense(double amount, String category) {
    expenses.insert(0, {'amount': amount, 'category': category, 'date': DateTime.now()});
    _saveToPrefs();
    notifyListeners();
  }

  void addVendor(String name, String phone, String category) {
    vendors.add({'name': name, 'phone': phone, 'category': category});
    _saveToPrefs();
    notifyListeners();
  }

  double get stockStatusPercentage {
    if (items.isEmpty) return 0.0;
    double totalQty = items.fold(0, (sum, item) => sum + (item['quantity'] ?? 0));
    return (totalQty / 100).clamp(0.0, 1.0);
  }

  double get totalSales => sales.fold(0.0, (sum, s) => sum + (s['total'] ?? 0.0));
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
  double get totalProfit => totalSales - totalExpenses;
}