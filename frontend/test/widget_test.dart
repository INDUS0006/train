import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('TrainBuddy app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrainBuddyApp());

    // Advance past splash timer
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    // Verify app branding / sign-in is rendered
    expect(find.text('TrainBuddy'), findsWidgets);
  });
}
