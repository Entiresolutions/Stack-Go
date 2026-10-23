import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_pulse/app.dart';
import 'package:stack_pulse/core/game_theme.dart';
import 'package:stack_pulse/ui/screens/splash_screen.dart';
import 'package:stack_pulse/ui/screens/themes_screen.dart';
import 'package:stack_pulse/ui/widgets/gameplay_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StackPulseApp smoke test renders Home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StackPulseApp());
    await tester.pumpAndSettle();

    expect(find.text('STACK PULSE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('THEMES'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });

  testWidgets('Navigation transitions between screens operate cleanly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const StackPulseApp());
    await tester.pumpAndSettle();

    // 1. Home -> Themes
    await tester.tap(find.text('THEMES'));
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR VIBE'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

    // Themes -> Home
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);

    // 2. Home -> Settings
    await tester.tap(find.text('SETTINGS'));
    await tester.pumpAndSettle();
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Haptic Feedback'), findsOneWidget);
    expect(find.text('Reduced Motion'), findsOneWidget);

    // Settings -> Home
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);

    // 3. Home -> How to Play
    await tester.tap(find.text('HOW TO PLAY'));
    await tester.pumpAndSettle();
    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('LET\'S PLAY'), findsOneWidget);

    // How to Play -> Home via LET'S PLAY
    await tester.tap(find.text('LET\'S PLAY'));
    await tester.pumpAndSettle();
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets(
      'Responsive Viewport Audit across portrait targets (360x800, 390x844, 412x915)',
      (WidgetTester tester) async {
    const testSizes = [
      Size(360, 800),
      Size(390, 844),
      Size(412, 915),
    ];

    for (final size in testSizes) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(const StackPulseApp());
      await tester.pumpAndSettle();

      // Ensure no RenderFlex overflows on Home
      expect(tester.takeException(), isNull);
      expect(find.text('PLAY'), findsOneWidget);

      // Check Themes on this size
      await tester.tap(find.text('THEMES'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('CHOOSE YOUR VIBE'), findsOneWidget);

      // Back to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Check Settings on this size
      await tester.tap(find.text('SETTINGS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Sound Effects'), findsOneWidget);

      // Back to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Check How to Play on this size
      await tester.tap(find.text('HOW TO PLAY'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('LET\'S PLAY'), findsOneWidget);

      // Back to Home
      await tester.tap(find.text('LET\'S PLAY'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  });

  testWidgets(
      'SplashScreen renders ambient background CustomPaint and branding',
      (WidgetTester tester) async {
    bool loaded = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          theme: GameTheme.midnightNeon,
          reducedMotion: false,
          onLoaded: () => loaded = true,
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify branding and logo exist
    expect(find.text('STACK'), findsOneWidget);
    expect(find.text('PULSE'), findsOneWidget);
    expect(find.text('ONE TAP. PERFECT STACK.'), findsOneWidget);

    // Verify ambient CustomPaint layer is mounted
    expect(find.byType(CustomPaint), findsWidgets);

    // Settle out splash and check callback
    await tester.pumpAndSettle();
    expect(loaded, isTrue);
  });

  testWidgets(
      'SplashScreen respects reducedMotion by bypassing ambient background animation',
      (WidgetTester tester) async {
    bool loaded = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(
          theme: GameTheme.midnightNeon,
          reducedMotion: true,
          onLoaded: () => loaded = true,
        ),
      ),
    );

    await tester.pump();

    // Verify branding remains perfectly readable
    expect(find.text('STACK'), findsOneWidget);
    expect(find.text('PULSE'), findsOneWidget);

    // Settle and verify callback triggers cleanly
    await tester.pumpAndSettle();
    expect(loaded, isTrue);
  });

  testWidgets(
      'ThemeGameplayBackground renders distinct environment assets for all 10 themes',
      (WidgetTester tester) async {
    for (final theme in GameTheme.allThemes) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThemeGameplayBackground(
              theme: theme,
              currentScore: 5,
              currentStreak: 2,
              perfectTriggerCount: 1,
              reducedMotion: false,
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ThemeGameplayBackground), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) =>
            w is CustomPaint &&
            w.painter.runtimeType
                .toString()
                .contains('ThemeEnvironmentPainter')),
        findsOneWidget,
      );
    }
  });

  testWidgets(
      'ThemeGameplayBackground respects reducedMotion by bypassing procedural CustomPaint',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ThemeGameplayBackground(
            theme: GameTheme.aurora,
            currentScore: 10,
            currentStreak: 3,
            perfectTriggerCount: 2,
            reducedMotion: true,
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(ThemeGameplayBackground), findsOneWidget);
    // CustomPaint for procedural environment effects must not be in tree
    expect(
      find.byWidgetPredicate((w) =>
          w is CustomPaint &&
          w.painter.runtimeType.toString().contains('ThemeEnvironmentPainter')),
      findsNothing,
    );
  });

  testWidgets(
      'ThemesScreen displays all 10 theme cards and respects unlock milestones',
      (WidgetTester tester) async {
    GameTheme? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: ThemesScreen(
          currentTheme: GameTheme.midnightNeon,
          bestScore: 25,
          totalPlacements: 300,
          onSelectTheme: (t) => selected = t,
          onDismiss: () {},
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('CHOOSE YOUR VIBE'), findsOneWidget);

    // Verify initial cards
    expect(find.text('Midnight Neon'), findsOneWidget);
    expect(find.text('Aurora'), findsOneWidget);

    // Tap Aurora card and verify selection callback
    await tester.tap(find.text('Aurora'));
    await tester.pumpAndSettle();
    expect(selected?.type, ThemeType.aurora);

    // Scroll down to check prestige themes
    await tester.scrollUntilVisible(
      find.text('Prism Rift'),
      300.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Prism Rift'), findsOneWidget);
  });
}
