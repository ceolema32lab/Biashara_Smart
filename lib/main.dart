import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_navigation.dart';
import 'screens/registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.loadProfile();
  runApp(ChangeNotifierProvider.value(value: appState, child: const BiasharaSmartApp()));
}

class BiasharaSmartApp extends StatelessWidget {
  const BiasharaSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF0F172A)),
          home: (appState.businessName == "My Business" || appState.businessName.isEmpty)
              ? const RegistrationPage()
              : const MainNavigation(), // Ikiwa bado ina error, ondoa 'const' hapa
        );
      },
    );
  }
}