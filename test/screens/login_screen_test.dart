import 'package:BabyGrowth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:BabyGrowth/mocks.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('widgets are rendered', (tester) async {
      // widgets needed
      final logoImage = find.byKey(ValueKey('logoImage'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      // check
      expect(logoImage, findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(TextButton), findsNWidgets(2));
    });

  group('text fields test', () {

    testWidgets('email text field test', (tester) async {
      // widgets needed
      final emailField = find.byKey(ValueKey('emailField'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      await tester.enterText(emailField, 'email');
      await tester.pump();
      // check
      expect(find.text('email'), findsOneWidget);
    });

    testWidgets('password text field test', (tester) async {
      // find widgets needed
      final passwordField = find.byKey(ValueKey('passwordField'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      await tester.enterText(passwordField, 'password');
      await tester.pump();
      // check
      expect(find.text('password'), findsOneWidget);
    });
  });

  group('button tap tests', () {

    testWidgets('reset button test', (tester) async {
      // find widgets needed
      final resetButton = find.byKey(ValueKey('resetButton'));
      final resetEmailField = find.byKey(ValueKey('resetEmailField'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      await tester.tap(resetButton);
      await tester.pumpAndSettle();
      // check
      expect(resetEmailField, findsOneWidget);
    });

    testWidgets('login button test with no user input', (tester) async {
      // find widgets needed
      final loginButton = find.byKey(ValueKey('loginButton'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      // check
      expect(find.text('Please enter an email and password.'), findsOneWidget);
    });

    testWidgets('login button test with a email or password missing', (tester) async {
      // find widgets needed
     final emailField = find.byKey(ValueKey('emailField'));
     final loginButton = find.byKey(ValueKey('loginButton'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      await tester.enterText(emailField, 'email');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      // check
      expect(find.text('Please enter an email and password.'), findsOneWidget);
    });

    testWidgets('Alert dialog is shown when when wrong email or password is given', (tester) async {
      // TODO fix this test
      // find widgets needed
      final emailField = find.byKey(ValueKey('emailField'));
      final passwordField = find.byKey(ValueKey('passwordField'));
      final loginButton = find.byKey(ValueKey('loginButton'));
      // execute test 1
      await tester.pumpWidget(MaterialApp(home: LoginScreen()));
      // check 1
      expect(find.byType(AlertDialog), findsNothing);
      // execute test 2
      await tester.enterText(emailField, 'email@email.com');
      await tester.enterText(passwordField, '000');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      // check
      expect(find.byType(AlertDialog), findsOneWidget);
    });

  });
}