import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pulse_budget/main.dart';

void main() {
  testWidgets('PulseBudget renders initial overview balance', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PulseBudgetApp());
    await tester.pumpAndSettle();

    expect(find.text('Budget Overview'), findsOneWidget);
    expect(find.text('\$0.00'), findsOneWidget);
  });
}
