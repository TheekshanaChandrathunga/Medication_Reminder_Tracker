import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meditrack/pages/login_page.dart';
import 'package:meditrack/pages/reports_page.dart';
import 'package:meditrack/services/auth_service.dart';
import 'package:meditrack/services/database_service.dart';
import 'package:meditrack/services/report_service.dart';

void main() {
  testWidgets('Login page displays title', (WidgetTester tester) async {
    await tester.pumpWidget(
      Provider<AuthService>.value(
        value: AuthService(),
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );
    expect(find.text('MediTrack'), findsWidgets);
  });

  testWidgets('Reports page shows adherence report actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthService>.value(value: AuthService()),
          Provider<DatabaseService>.value(value: DatabaseService()),
          Provider<ReportService>.value(value: ReportService()),
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
