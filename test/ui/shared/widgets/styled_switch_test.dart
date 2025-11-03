import 'package:cribe/ui/shared/widgets/styled_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StyledSwitch', () {
    testWidgets('should call onChanged when tapped - happy path',
        (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSwitch(
              value: false,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(changedValue, isTrue);
    });

    testWidgets('should not call onChanged when disabled - unhappy path',
        (tester) async {
      bool? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSwitch(
              value: false,
              enabled: false,
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(changedValue, isNull);
    });

    testWidgets(
        'should display Switch when no title/subtitle - conditional rendering',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSwitch(
              value: true,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets(
        'should display SwitchListTile when title provided - conditional rendering',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledSwitch(
              value: true,
              onChanged: (_) {},
              title: 'Enable Feature',
            ),
          ),
        ),
      );

      expect(find.byType(SwitchListTile), findsOneWidget);
    });
  });
}
