import 'package:flutter_test/flutter_test.dart';
import 'package:jumbli/main.dart';

void main() {
  testWidgets('App loads Main Menu Screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JumbliApp());

    // Allow animations to finish
    await tester.pumpAndSettle();

    // Verify that Main Menu elements are on screen.
    expect(find.text('JUMBLI'), findsOneWidget);
    expect(find.text('PASS & PLAY'), findsOneWidget);
    expect(find.text('HOST GAME'), findsOneWidget);
  });
}