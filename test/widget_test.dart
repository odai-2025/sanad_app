import 'package:flutter_test/flutter_test.dart';
import 'package:sanad_app/app/app.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SanadApp());
    expect(find.byType(SanadApp), findsOneWidget);
  });
}