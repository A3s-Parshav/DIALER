import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:advayx/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const advayx());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
