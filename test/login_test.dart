//This contains the test for the register.dart page

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucky13capstone/login_page.dart';

//import 'package:mockito/mockito.dart';

//class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  testWidgets('Login button and Registration button',
      (WidgetTester tester) async {
    //Wrap signuppage widget with the MediaQuery(...) instance due to Scaffold(..)
    Widget testWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: LoginPage()));
    // Build our app and trigger a frame.
    await tester.pumpWidget(testWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets('Login button and Registration button',
      (WidgetTester tester) async {
    //Wrap signuppage widget with the MediaQuery(...) instance due to Scaffold(..)
    Widget testWidget = const MediaQuery(
        data: MediaQueryData(), child: MaterialApp(home: LoginPage()));
    // Build our app and trigger a frame.
    await tester.pumpWidget(testWidget);

    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });
}
