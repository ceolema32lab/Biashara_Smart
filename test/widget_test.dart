import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:biashara_smart/main.dart'; // Ensure this matches your package name
import 'package:biashara_smart/providers/app_state.dart';

void main() {
  testWidgets('Registration page shows on first run smoke test', (WidgetTester tester) async {
    // 1. Mock the SharedPreferences to simulate a first-time user
    SharedPreferences.setMockInitialValues({
      'is_registered': false,
    });

    // 2. Build our app and trigger a frame.
    // We wrap it in a Provider just like in main.dart
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const MyApp(isRegistered: false),
      ),
    );

    // 3. Verify that the Registration screen appears
    // We look for the "Get Started" button text
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Welcome to Biashara Smart'), findsOneWidget);

    // 4. Verify that the Home page is NOT showing yet
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('Home page shows if already registered smoke test', (WidgetTester tester) async {
    // Mock the SharedPreferences to simulate an existing user
    SharedPreferences.setMockInitialValues({
      'is_registered': true,
      'user_name': 'Test User',
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppState()),
        ],
        child: const MyApp(isRegistered: true),
      ),
    );

    // Verify that the Dashboard (Home) appears instead of Registration
    // (Assuming your Home page has an AppBar or specific text)
    expect(find.text('Get Started'), findsNothing);
  });
}