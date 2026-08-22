import 'package:flutter_test/flutter_test.dart';
import 'package:jumbli/main.dart';

void main() {
  testWidgets('App loads Player 1 Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JumbliApp());

    // Allow animations to finish
    await tester.pumpAndSettle();

    // Verify that Player 1 text is on screen.
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.text('SHOW'), findsOneWidget);
  });
}
