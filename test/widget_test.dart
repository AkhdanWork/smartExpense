import 'package:flutter_test/flutter_test.dart';
import 'package:smart_expense/main.dart';

void main() {
  testWidgets('smartExpense app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartExpenseApp());
    expect(find.byType(SmartExpenseApp), findsOneWidget);
  });
}
