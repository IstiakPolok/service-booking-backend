import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ServiceBookingApp());
    expect(find.byType(ServiceBookingApp), findsOneWidget);
  });
}
