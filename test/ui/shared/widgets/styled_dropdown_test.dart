import 'package:cribe/ui/shared/widgets/styled_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StyledDropdown', () {
    testWidgets('should call onChanged when value is selected - happy path',
        (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledDropdown<String>(
              label: 'Test Label',
              value: 'Option 1',
              options: const [
                (value: 'Option 1', label: 'Option 1'),
                (value: 'Option 2', label: 'Option 2'),
              ],
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Option 2').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 'Option 2');
    });

    testWidgets('should not call onChanged when disabled - unhappy path',
        (tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledDropdown<String>(
              label: 'Test Label',
              value: 'Option 1',
              enabled: false,
              options: const [
                (value: 'Option 1', label: 'Option 1'),
                (value: 'Option 2', label: 'Option 2'),
              ],
              onChanged: (value) {
                selectedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(selectedValue, isNull);
    });

    testWidgets('should display subtitle when provided - conditional rendering',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledDropdown<String>(
              label: 'Test Label',
              value: 'Option 1',
              subtitle: 'This is a subtitle',
              options: const [
                (value: 'Option 1', label: 'Option 1'),
              ],
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('This is a subtitle'), findsOneWidget);
    });
  });
}
