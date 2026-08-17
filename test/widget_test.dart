import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker_app/main.dart';

void main() {
  testWidgets('App renders Dashboard with APEX GYM TRACKER title', (WidgetTester tester) async {
    await tester.pumpWidget(const ApexGymApp());
    await tester.pumpAndSettle();

    expect(find.text('APEX GYM TRACKER'), findsOneWidget);
    expect(find.text('DAILY FUEL & PROTEIN'), findsOneWidget);
  });
}
