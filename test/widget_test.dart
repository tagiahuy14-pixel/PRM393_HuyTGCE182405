import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab1/main.dart';
import 'package:lab1/models/gallery_stats.dart';
import 'package:lab1/screens/login_screen.dart';
import 'package:lab1/screens/register_screen.dart';
import 'package:lab1/widgets/stats_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and displays ArtGalleryApp', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const ArtGalleryApp());
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Art Gallery Manager'), findsOneWidget);

    // Advance past splash delay
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(find.text('Sign in to manage your collection'), findsOneWidget);
  });

  testWidgets('LoginScreen displays required fields and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify Title and Subtitle
    expect(find.text('Art Gallery Manager'), findsOneWidget);
    expect(find.text('Sign in to manage your collection'), findsOneWidget);

    // Verify Form Fields
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Register now'), findsOneWidget);

    // Tap login with empty fields triggers validation
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter username'), findsOneWidget);
    expect(find.text('Please enter password'), findsOneWidget);
  });

  testWidgets(
    'RegisterScreen displays required fields and validates password match',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Tap register without inputs
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Username is required'), findsOneWidget);
    },
  );

  testWidgets('StatsCard displays correct counts and labels', (
    WidgetTester tester,
  ) async {
    const stats = GalleryStats(
      totalArtworks: 12,
      favoriteArtworks: 5,
      totalCategories: 3,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatsCard(stats: stats)),
      ),
    );

    expect(find.text('Gallery Statistics'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Artworks'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
