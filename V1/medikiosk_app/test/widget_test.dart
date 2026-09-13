import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medikiosk_app/app.dart';
import 'package:medikiosk_app/core/services/storage_service.dart';
import 'package:medikiosk_app/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('MediKiosk app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const MediKioskApp(),
      ),
    );

    // Let the splash screen timer finish and settle transitions
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(MediKioskApp), findsOneWidget);
  });

  testWidgets('ProfileScreen test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    await storageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('रमेश कुमार (Ramesh Kumar)'), findsOneWidget);
    expect(find.text('सर्वर व डेटाबेस चयन (Server & Database Environment)'), findsOneWidget);
  });
}

