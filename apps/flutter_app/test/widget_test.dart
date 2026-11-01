import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/main.dart';

void main() {
  testWidgets('App smoke test renders launcher title', (WidgetTester tester) async {
    await tester.pumpWidget(const SquareSurvivalApp());

    expect(find.text('Square Survival'), findsOneWidget);
    expect(find.text('Single Player (Offline)'), findsOneWidget);
  });
}
