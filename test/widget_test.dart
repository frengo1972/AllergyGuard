import 'package:flutter_test/flutter_test.dart';

import 'package:allergyguard/main.dart';

void main() {
  testWidgets('BootstrapErrorApp shows the provided error message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BootstrapErrorApp(message: 'boom'));
    await tester.pumpAndSettle();

    expect(find.text('boom'), findsOneWidget);
    expect(find.byType(BootstrapErrorApp), findsOneWidget);
  });
}
