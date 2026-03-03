import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'main_navigation.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _businessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      backgroundColor: appState.isDarkMode ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.business_center, size: 80, color: Color(0xFF6366F1));
                },
              ),
              const SizedBox(height: 30),
              Text(
                "Biashara Smart",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: appState.isDarkMode ? Colors.white : const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(height: 10),
              
              // REKEBISHO 1: Tulitenganisha English na Swahili kwa koma
              Text(
                appState.t("Register your business", "Sajili biashara yako"),
                style: const TextStyle(color: Colors.grey),
              ),
              
              const SizedBox(height: 40),
              
              TextField(
                controller: _userController,
                style: TextStyle(color: appState.isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  // REKEBISHO 2: Koma katikati ya maneno mawili
                  labelText: appState.t("Your Name", "Jina Lako"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              
              const SizedBox(height: 20),
              
              TextField(
                controller: _businessController,
                style: TextStyle(color: appState.isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  // REKEBISHO 3: Koma katikati ya maneno mawili
                  labelText: appState.t("Business Name", "Jina la Biashara"),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    if (_userController.text.trim().isNotEmpty && 
                        _businessController.text.trim().isNotEmpty) {
                      
                      await appState.updateProfile(
                        _userController.text.trim(), 
                        _businessController.text.trim()
                      );
                      
                      if (mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainNavigation()),
                        );
                      }
                    } else {
                      // REKEBISHO 4: SnackBar translation fix
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(appState.t("Please fill all fields", "Tafadhali jaza nafasi zote")))
                      );
                    }
                  },
                  child: Text(
                    // REKEBISHO 5: Koma katikati ya maneno
                    appState.t("Get Started", "Anza Sasa"),
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}