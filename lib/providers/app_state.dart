import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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

  // 1. Setup the Gemini Model with System Instructions
  final model = GenerativeModel(
    model: 'gemini-3-flash-preview',
    apiKey: "AIzaSyBUsAzkFxtgqK-IIy7trkSXOPaAg8diF8w",
    systemInstruction: Content.system(
      "You are Biashara Smart Assistant. Your goal is to help business owners grow. "
      "Rules: 1. Be concise. 2. Use bullet points for steps. "
      "3. Always end with an 'Action Step' or an open-ended question like 'How do you currently handle...' to build rapport. "
      "4. Use a mix of English and Swahili if requested.",
    ),
  );

  // --- Mfumo wa Kuhifadhi Data (Save/Load) ---
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('items', jsonEncode(items));
    prefs.setString('vendors', jsonEncode(vendors));

    // Geuza tarehe kuwa String ili zisave-ike kwenye JSON
    prefs.setString(
      'sales',
      jsonEncode(
        sales.map((s) {
          var map = Map<String, dynamic>.from(s);
          map['date'] = (map['date'] as DateTime).toIso8601String();
          return map;
        }).toList(),
      ),
    );

    prefs.setString(
      'expenses',
      jsonEncode(
        expenses.map((e) {
          var map = Map<String, dynamic>.from(e);
          map['date'] = (map['date'] as DateTime).toIso8601String();
          return map;
        }).toList(),
      ),
    );

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
      if (itemsJson != null)
        items = List<Map<String, dynamic>>.from(jsonDecode(itemsJson));

      String? salesJson = prefs.getString('sales');
      if (salesJson != null) {
        sales = List<Map<String, dynamic>>.from(jsonDecode(salesJson)).map((s) {
          s['date'] = DateTime.parse(s['date']);
          return s;
        }).toList();
      }

      String? expensesJson = prefs.getString('expenses');
      if (expensesJson != null) {
        expenses = List<Map<String, dynamic>>.from(jsonDecode(expensesJson))
            .map((e) {
              e['date'] = DateTime.parse(e['date']);
              return e;
            })
            .toList();
      }

      String? vendorsJson = prefs.getString('vendors');
      if (vendorsJson != null)
        vendors = List<Map<String, dynamic>>.from(jsonDecode(vendorsJson));
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
        'date': expenses[index]['date'],
      };
      _saveToPrefs();
      notifyListeners();
    }
  }

  // --- 10. Unified getAIResponse (Merged Online & Offline) ---
  Future<String> getAIResponse(String prompt) async {
    String q = prompt.toLowerCase();

    // 1. FIRST: Check for Internet
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool isOffline = connectivityResult.contains(ConnectivityResult.none);

    // 2. OFFLINE LOGIC: Use local data if offline OR for specific data queries
    if (isOffline ||
        q.contains("profit") ||
        q.contains("faida") ||
        q.contains("sales") ||
        q.contains("mauzo")) {
      if (q.contains("profit") || q.contains("faida")) {
        return t(
          "Total profit is TSh $totalProfit (Sales: $totalSales - Expenses: $totalExpenses).",
          "Jumla ya faida ni TSh $totalProfit (Mauzo $totalSales - Matumizi $totalExpenses).",
        );
      } else if (q.contains("sales") || q.contains("mauzo")) {
        return t(
          "You have made sales worth TSh $totalSales today.",
          "Umefanya mauzo ya TSh $totalSales leo.",
        );
      }

      // If offline but not a specific data query
      if (isOffline) {
        return t(
          "I'm currently offline. I can't reach the cloud, but you can still ask about your sales or profit!",
          "Kwa sasa siko hewani. Siwezi kufikia mtandao, lakini unaweza kuuliza kuhusu mauzo au faida yako!",
        );
      }
    }

    // 3. ONLINE LOGIC: Call Gemini API for complex questions
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      String rawResponse = response.text ?? "No response";

      // CLIENT-SIDE WRAPPER: Make it "Compelling"
      return """
$rawResponse

---
**Growth Question for You:** *How do you currently handle this in your $businessName?*
""";
    } catch (e) {
      return "Error: $e";
    }
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
    expenses.insert(0, {
      'amount': amount,
      'category': category,
      'date': DateTime.now(),
    });
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
    double totalQty = items.fold(
      0,
      (sum, item) => sum + (item['quantity'] ?? 0),
    );
    return (totalQty / 100).clamp(0.0, 1.0);
  }

  double get totalSales =>
      sales.fold(0.0, (sum, s) => sum + (s['total'] ?? 0.0));
  double get totalExpenses =>
      expenses.fold(0.0, (sum, e) => sum + (e['amount'] ?? 0.0));
  double get totalProfit => totalSales - totalExpenses;
}
