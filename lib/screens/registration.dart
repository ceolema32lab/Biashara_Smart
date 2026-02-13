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
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center( // Inaweka vitu katikati ya screen
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- SEHEMU YA LOGO ---
              Image.asset(
                'assets/logo.png', 
                height: 300, // <--- BADILISHA NAMBA HII ILI KUONGEZA/KUPUNGUZA SIZE
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.rocket_launch, 
                    size: 100, 
                    color: Color(0xFF6366F1)
                  );
                },
              ),
              const SizedBox(height: 1),

              // --- MAANDISHI YA KARIBU ---
              Text(
                appState.t("Welcome to Biashara Smart", "Karibu Biashara Smart"), 
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white, 
                  fontSize: 26, 
                  fontWeight: FontWeight.bold
                )
              ),
              const SizedBox(height: 10),
              Text(
                appState.t(
                  "Setup your business profile to begin", 
                  "Sanidi wasifu wa biashara yako ili kuanza"
                ), 
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54)
              ),
              const SizedBox(height: 40),

              // --- INPUT FIELDS ---
              _buildField(
                appState.t("Your Name", "Jina Lako"), 
                _nameController, 
                Icons.person
              ),
              const SizedBox(height: 15),
              _buildField(
                appState.t("Business Name", "Jina la Biashara"), 
                _businessController, 
                Icons.store
              ),
              const SizedBox(height: 30),

              // --- KITUFE CHA KUANZA ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                  ),
                  onPressed: () async {
                    if (_nameController.text.isNotEmpty && 
                        _businessController.text.isNotEmpty) {
                      await appState.updateProfile(
                        _nameController.text, 
                        _businessController.text
                      );
                      if (mounted) {
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => const MainNavigation())
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appState.t("Please fill all fields", "Tafadhali jaza nafasi zote")
                          )
                        )
                      );
                    }
                  },
                  child: Text(
                    appState.t("Start My Business", "Anza Biashara Yangu"), 
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white38),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), 
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}