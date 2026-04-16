import 'package:allergyguard/l10n/app_localizations.dart';
import 'package:allergyguard/ui/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('prefills negative scan accuracy feedback when requested',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FeedbackScreen(
            prefilledResultLevel: 'danger',
            initialIsCorrect: false,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Il risultato della scansione era corretto?'),
        findsOneWidget);
    expect(find.text('Quale sarebbe stato il risultato corretto?'),
        findsOneWidget);
    expect(find.text('No, sbagliato'), findsOneWidget);
  });
}
