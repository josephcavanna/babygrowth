import 'package:BabyGrowth/mocks.dart';
import 'package:BabyGrowth/screens/add_entry.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('widgets are rendered', (tester) async {
    // widgets needed
    final scaleIcon = find.byIcon(MaterialCommunityIcons.scale);
    final altimeterIcon = find.byIcon(MaterialCommunityIcons.altimeter);
    final calendarIcon = find.byIcon(FontAwesome5.calendar);
    final backButton = find.byKey(ValueKey('backButton'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: AddEntry()));
    // check
    expect(scaleIcon, findsOneWidget);
    expect(altimeterIcon, findsOneWidget);
    expect(calendarIcon, findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.byKey(ValueKey('dateButton')), findsOneWidget);
    expect(find.byKey(ValueKey('addButton')), findsOneWidget);
    expect(backButton, findsOneWidget);
    expect(find.text('New entry'), findsOneWidget);
  });

  group('text field tests', () {

    // TODO fix this test
    testWidgets('weight text field test', (tester) async {
      // find widgets needed
      final weightField = find.byKey(ValueKey('weightField'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: AddEntry()));
      await tester.enterText(weightField, '3,5');
      await tester.pump();
      // check
      expect(find.text('3,5'), findsOneWidget);
    });

    testWidgets('height text field test', (tester) async {
      // find widgets needed
      final heightField = find.byKey(ValueKey('heightField'));
      // execute test
      await tester.pumpWidget(MaterialApp(home: AddEntry()));
      await tester.enterText(heightField, '53');
      await tester.pump();
      // check
      expect(find.text('53'), findsOneWidget);
    });
  });

  testWidgets('pick date button test', (tester) async {
    // find widgets needed
    final dateButton = find.byKey(ValueKey('dateButton'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: AddEntry()));
    await tester.tap(dateButton);
    await tester.pumpAndSettle();
    // check
    expect(find.text('2021'), findsOneWidget);
  });

  testWidgets('add button test empty fields', (tester) async {
    // find widgets needed
    final addButton = find.byKey(ValueKey('addButton'));
    // execute test
    await tester.pumpWidget(MaterialApp(home: AddEntry()));
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    // check
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });
}