// This is a basic Flutter widget test for the MetalMetric app.

import 'package:flutter_test/flutter_test.dart';
import 'package:metal_metric/main.dart';

void main() {
  testWidgets('App loads and shows bottom navigation',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MetalMetricApp());

    // Wait for async operations to complete
    await tester.pumpAndSettle();

    // Verify that we have the bottom navigation bar items.
    expect(find.text('Calculator'), findsOneWidget);
    expect(find.text('Live Markets'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
  });
}
