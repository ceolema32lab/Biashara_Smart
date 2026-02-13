import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_navigation.dart';
import 'screens/registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appState = AppState();
  await appState.loadProfile();
  
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const BiasharaSmartApp(),
    ),
  );
}

class BiasharaSmartApp extends StatelessWidget {
  const BiasharaSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tunamsikiliza AppState hapa ili kubadilisha Theme au Page pindi data zikibadilika
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Biashara Smart',
          
          // Mipangilio ya Rangi (Light & Dark Mode)
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorSchemeSeed: Colors.indigo,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0F172A),
            colorSchemeSeed: Colors.indigo,
          ),
          
          // Logic ya kuelekeza mtumiaji
          // Kama biashara haina jina, anapelekwa kusajili (Registration)
          // Kama tayari anayo, anapelekwa kwenye Navigation kuu
          home: appState.businessName == "My Business" || appState.businessName.isEmpty
              ? const RegistrationPage() 
              : const MainNavigation(),
        );
      },
    );
  }
}