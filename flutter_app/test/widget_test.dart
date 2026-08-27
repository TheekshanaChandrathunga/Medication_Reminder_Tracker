import 'package:flutter_test/flutter_test.dart';
import 'package:meditrack/main.dart';

void main() {
  testWidgets('App loads and displays title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MediTrackApp());

    // Verify that the app name 'MediTrack' is displayed.
    // We use findsWidgets because it might appear in multiple places (splash/header).
    expect(find.text('MediTrack'), findsWidgets);
  });
}
