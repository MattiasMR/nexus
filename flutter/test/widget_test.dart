import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nexus_flutter/main.dart';

void main() {
  testWidgets('Home screen shows Nexus actions', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Nexus'), findsAtLeastNWidgets(1));
    expect(find.text('Ver pacientes'), findsOneWidget);
    expect(find.text('Ver fichas médicas'), findsOneWidget);
    expect(find.byIcon(Icons.local_hospital), findsOneWidget);
  });
}
