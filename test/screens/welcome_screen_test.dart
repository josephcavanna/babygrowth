import 'package:BabyGrowth/screens/login_screen.dart';
import 'package:BabyGrowth/screens/register_screen.dart';
import 'package:BabyGrowth/screens/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BabyGrowth/mocks.dart';
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() async {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });
  
  testWidgets('widgets are rendered', (tester) async {
    // find widgets needed
    final logoImage = find.byKey(ValueKey('logoImage'));
    final logoText = find.byKey(ValueKey('logoText'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: WelcomeScreen()));
    // check
    expect(logoImage, findsOneWidget);
    expect(logoText, findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
  
  group('Welcome screen navigation tests', () {
    NavigatorObserver mockObserver;
    setUpAll(() {
      mockObserver = MockNavigatorObserver();
    });

    Future<void> _buildWelcomeScreen(WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: WelcomeScreen(),
        navigatorObservers: [mockObserver],
      ));
      verify(mockObserver.didPush(any, any));
    }

    Future<void> _navigateToRegisterScreen(WidgetTester tester) async {
      await tester.tap(find.byKey(ValueKey('registerButton')));
      await tester.pumpAndSettle();
    }

    Future<void> _navigateToLoginScreen(WidgetTester tester) async {
      await tester.tap(find.byKey(ValueKey('loginButton')));
      await tester.pumpAndSettle();
    }

  testWidgets('register button tap routes to register screen', (tester) async {
    // execute test
    await _buildWelcomeScreen(tester);
    await _navigateToRegisterScreen(tester);
    //check
    expect(find.byType(RegisterScreen), findsOneWidget);
  });

  testWidgets('log in button tap routes to register screen', (tester) async {
    //execute test
    await _buildWelcomeScreen(tester);
    await _navigateToLoginScreen(tester);
    //check
    expect(find.byType(LoginScreen), findsOneWidget);
  });
  });
}