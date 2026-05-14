import 'package:flutter_test/flutter_test.dart';
import 'package:nextronix_frontend/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NextronixAdmin());
    expect(find.text('Nextronix'), findsOneWidget);
  });
}
