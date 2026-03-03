import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark professional background
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store_rounded, size: 80, color: Color(0xFF6366F1)),
                const SizedBox(height: 20),
                Text(
                  appState.t("Welcome to Biashara Smart", "Karibu Biashara Smart"),
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // --- BOX 1: OWNER NAME ---
                _buildTextField(
                  controller: _nameController,
                  label: "Name of the Owner / Jina la Mmiliki",
                  hint: "e.g. John Doe",
                  icon: Icons.person,
                ),
                const SizedBox(height: 20),

                // --- BOX 2: BUSINESS NAME ---
                _buildTextField(
                  controller: _businessController,
                  label: "Name of the Business / Jina la Biashara",
                  hint: "e.g. John's Hardware",
                  icon: Icons.business_center,
                ),
                
                const SizedBox(height: 40),

                // SAVE BUTTON
                SValuesButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _businessController.text.isNotEmpty) {
                      appState.updateProfile(_nameController.text, _businessController.text);
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                  text: appState.t("Get Started", "Anza Sasa"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable Widget for visible TextFields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF6366F1)),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF1E293B),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class SValuesButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const SValuesButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}