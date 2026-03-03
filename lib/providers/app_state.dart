import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AppState extends ChangeNotifier {
  AppState() {
    loadProfile();
  }

  // --- SETTINGS & PROFILE ---
  bool isDarkMode = true;
  String languageCode = 'en';
  String userName = "User";
  String businessName = "My Business";

  // --- DATA LISTS ---
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> vendors = [];

  // --- AI ENGINE ---
  final model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: "AIzaSyBUsAzkFxtgqK-IIy7trkSXOPaAg8diF8w",
    systemInstruction: Content.system("You are Biashara Smart Assistant. Help business owners grow."),
  );

  // --- PERSISTENCE (Save/Load) ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('items', jsonEncode(items));
    prefs.setString('vendors', jsonEncode(vendors));
    
    prefs.setString('sales', jsonEncode(sales.map((s) {
      var map = Map<String, dynamic>.from(s);
      if (map['date'] is DateTime) map['date'] = (map['date'] as DateTime).toIso8601String();
      return map;
    }).toList()));

    prefs.setString('expenses', jsonEncode(expenses.map((e) {
      var map = Map<String, dynamic>.from(e);
      if (map['date'] is DateTime) map['date'] = (map['date'] as DateTime).toIso8601String();
      return map;
    }).toList()));

    prefs.setString('userName', userName);
    prefs.setString('businessName', businessName);
    prefs.setString('languageCode', languageCode);
    prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "User";
    businessName = prefs.getString('businessName') ?? "My Business";
    languageCode = prefs.getString('languageCode') ?? "en";
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
      debugPrint("Load Error: $e");
    }
    notifyListeners();
  }

  // --- SALES METHODS ---
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

  void deleteSale(int index) {
    sales.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  // --- EXPENSES METHODS ---
  void addExpense(double amount, String category) {
    expenses.insert(0, {'amount': amount, 'category': category, 'date': DateTime.now()});
    _saveToPrefs();
    notifyListeners();
  }

  void editExpense(int index, double amount, String category) {
    expenses[index] = {'amount': amount, 'category': category, 'date': expenses[index]['date']};
    _saveToPrefs();
    notifyListeners();
  }

  void deleteExpense(int index) {
    expenses.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  // --- STOCK METHODS ---
  void addStock(String name, double quantity, double price) {
    items.add({'name': name, 'quantity': quantity, 'price': price});
    _saveToPrefs();
    notifyListeners();
  }

  void editStock(int index, String name, String quantityStr, double price) {
    double qty = double.tryParse(quantityStr) ?? 0.0;
    items[index] = {'name': name, 'quantity': qty, 'price': price};
    _saveToPrefs();
    notifyListeners();
  }

  void deleteStock(int index) {
    items.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  // --- VENDOR METHODS ---
  void addVendor(String name, String phone, String category) {
    vendors.add({'name': name, 'phone': phone, 'category': category});
    _saveToPrefs();
    notifyListeners();
  }

  void updateVendor(int index, String name, String phone, String category) {
    vendors[index] = {'name': name, 'phone': phone, 'category': category};
    _saveToPrefs();
    notifyListeners();
  }

  void removevendor(int index) { // Jina hili lazima liwe na 'v' ndogo kufuta error
    vendors.removeAt(index);
    _saveToPrefs();
    notifyListeners();
  }

  // --- UTILITIES ---
  void toggleTheme() { isDarkMode = !isDarkMode; _saveToPrefs(); notifyListeners(); }
  void setLanguage(String lang) { languageCode = lang; _saveToPrefs(); notifyListeners(); }
  String t(String en, String sw) => languageCode == 'sw' ? sw : en;
  
  Future<void> updateProfile(String name, String bName) async {
    userName = name; businessName = bName; await _saveToPrefs(); notifyListeners();
  }

  double get totalSales => sales.fold(0.0, (sum, s) => sum + (s['total'] ?? 0.0));
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
  double get totalProfit => totalSales - totalExpenses;
  double get stockStatusPercentage => items.isEmpty ? 0.0 : (items.length / 100).clamp(0.0, 1.0);

  Future<String> getAIResponse(String prompt) async {
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "No response";
    } catch (e) { return "AI Error"; }
  }
}