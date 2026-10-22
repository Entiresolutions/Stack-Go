import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stack_pulse/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StackPulseApp smoke test renders Home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StackPulseApp());
    await tester.pumpAndSettle();

    expect(find.text('STACK PULSE'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('THEMES'), findsOneWidget);
    expect(find.text('HOW TO PLAY'), findsOneWidget);
  });
}
