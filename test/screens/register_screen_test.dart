import 'package:BabyGrowth/mocks.dart';
import 'package:BabyGrowth/screens/main_screen.dart';
import 'package:BabyGrowth/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
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
    final emailField = find.byKey(ValueKey('emailField'));
    final passwordField = find.byKey(ValueKey('passwordField'));
    final registerButton = find.byKey(ValueKey('registerButton'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    // check
    expect(logoImage, findsOneWidget);
    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(registerButton, findsOneWidget);
  });

group('text fields tests', () {

  testWidgets('email text field test', (tester) async {
    // find widgets needed
    final emailField = find.byKey(ValueKey('emailField'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    await tester.enterText(emailField, 'email');
    await tester.pump();
    // check
    expect(find.text('email'), findsOneWidget);
  });

  testWidgets('password text field test', (tester) async {
    // find widgets needed
    final passwordField = find.byKey(ValueKey('passwordField'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));
    await tester.enterText(passwordField, 'password');
    await tester.pump();
    // check
    expect(find.text('password'), findsOneWidget);
  });
});

group('user taps register button', () {
  NavigatorObserver mockObserver;
  setUpAll(() {
    mockObserver = MockNavigatorObserver();
  });

  testWidgets('user taps register button without entering username or password', (tester) async {
    // find widgets needed
    final registerButton = find.byKey(ValueKey('registerButton'));
    // execute test
    await _loadRegisterScreen(tester, mockObserver);
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
    // check
    expect(find.text('Please enter an email and password.'), findsOneWidget);
  });

  testWidgets('user enters username and password and taps register button then is pushed to MainScreen', (tester) async {
    // TODO - Fix this test
    // find widgets needed
    final emailField = find.byKey(ValueKey('emailField'));
    final passwordField = find.byKey(ValueKey('passwordField'));
    final registerButton = find.byKey(ValueKey('registerButton'));
    // execute test
    await _loadRegisterScreen(tester, mockObserver);
    await tester.enterText(emailField, 'email@email.com');
    await tester.enterText(passwordField, '123456');
    await tester.tap(registerButton);
    await tester.pumpAndSettle();
    // check
    expect(find.byType(MainScreen), findsOneWidget);
  });

});
}

Future<void> _loadRegisterScreen(WidgetTester tester, NavigatorObserver mockObserver) async {
  await tester.pumpWidget(MaterialApp(
    home: RegisterScreen(),
    navigatorObservers: [mockObserver],
  ));
  verify(mockObserver.didPush(any, any));
}