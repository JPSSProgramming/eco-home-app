import 'package:flutter_test/flutter_test.dart';

import 'package:eco_home_app/main.dart';

void main() {
  testWidgets('Arduino mock dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Eco Home'), findsOneWidget);
    expect(find.text('LCD 16×2'), findsOneWidget);
    expect(find.textContaining('Time:'), findsWidgets);

    await tester.tap(find.text('SET · режим'));
    await tester.pump();

    expect(find.text('1.Set TIME'), findsOneWidget);

    await tester.tap(find.text('STEP · вибір'));
    await tester.pump();

    expect(find.text('2.Set Rel Time'), findsOneWidget);
  });
}
