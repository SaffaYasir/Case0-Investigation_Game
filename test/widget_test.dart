import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:case_zero_detective/app.dart';

void main() {
  testWidgets('CASE 0 app launches successfully', (WidgetTester tester) async {
    // Build app with ProviderScope
    await tester.pumpWidget(
      ProviderScope(
        child: MyApp(),
      ),
    );

    // Let routing & widgets settle
    await tester.pumpAndSettle();

    // Verify app title exists somewhere
    expect(find.textContaining('CASE 0'), findsWidgets);
  });
}
