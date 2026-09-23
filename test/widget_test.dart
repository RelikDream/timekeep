import 'package:flutter_test/flutter_test.dart';
import 'package:timekeep/main.dart';

void main() {
  testWidgets('shows the app name', (tester) async {
    await tester.pumpWidget(const TimekeepApp());

    expect(find.text('Pointage'), findsOneWidget);
  });
}
