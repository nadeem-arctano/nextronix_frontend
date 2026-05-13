import 'package:flutter_test/flutter_test.dart';
import 'package:nexttronics_front_end/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NextTronicsAdmin());
    expect(find.text('NextTronics'), findsOneWidget);
  });
}
