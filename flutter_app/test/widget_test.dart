import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/main.dart';
import 'package:meditrack/pages/reports_page.dart';
import 'package:meditrack/services/auth_service.dart';
import 'package:meditrack/services/database_service.dart';

void main() {
  testWidgets('App loads and displays title', (WidgetTester tester) async {
    await tester.pumpWidget(const MediTrackApp());
    expect(find.text('MediTrack'), findsWidgets);
  });

  testWidgets('Reports page shows adherence report actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: AuthService()),
          Provider<DatabaseService>.value(value: DatabaseService()),
        ],
        child: const MaterialApp(
          home: ReportsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Adherence Report'), findsOneWidget);
    expect(find.text('Generate PDF'), findsOneWidget);
    expect(find.text('Email Caregiver'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('Export CSV'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Export CSV'), findsOneWidget);
    expect(find.text('Overall Adherence'), findsOneWidget);
  });
}
