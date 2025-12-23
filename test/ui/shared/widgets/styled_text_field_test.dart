import 'package:cribe/ui/shared/widgets/styled_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StyledTextField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    testWidgets('should display text field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display label when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              label: 'Test Label',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('should display hint when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              hint: 'Test Hint',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, 'Test Hint');
    });

    testWidgets('should obscure text when obscureText is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });

    testWidgets('should be disabled when enabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              enabled: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, false);
    });

    testWidgets('should display prefix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              prefixIcon: const Icon(Icons.email),
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.prefixIcon, isNotNull);
    });

    testWidgets('should display suffix icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              suffixIcon: const Icon(Icons.visibility),
              onPressedSuffixIcon: () {},
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.suffixIcon, isNotNull);
    });

    testWidgets('should call onFieldSubmitted when submitted', (tester) async {
      bool wasSubmitted = false;
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              onFieldSubmitted: (value) {
                wasSubmitted = true;
                submittedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(wasSubmitted, true);
      expect(submittedValue, 'test');
    });

    testWidgets('should update controller text on input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'new text');
      await tester.pump();

      expect(controller.text, 'new text');
    });

    testWidgets('should display helper text when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              helperText: 'Helper text',
            ),
          ),
        ),
      );

      expect(find.text('Helper text'), findsOneWidget);
    });

    testWidgets('should validate with validator function', (tester) async {
      validator(value) {
        if (value == null || value.isEmpty) {
          return 'Field is required';
        }
        return null;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: StyledTextField(
                controller: controller,
                validator: validator,
              ),
            ),
          ),
        ),
      );

      final formState = tester.state<FormState>(find.byType(Form));
      final isValid = formState.validate();

      await tester.pump();

      expect(isValid, false);
      expect(find.text('Field is required'), findsOneWidget);
    });

    testWidgets('should show error border when validation fails',
        (tester) async {
      validator(value) {
        return 'Error message';
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: StyledTextField(
                controller: controller,
                validator: validator,
              ),
            ),
          ),
        ),
      );

      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();

      await tester.pump();

      expect(find.text('Error message'), findsOneWidget);
    });

    testWidgets('should set keyboard type when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.emailAddress);
    });

    testWidgets('should set maxLines when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              maxLines: 3,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 3);
    });

    testWidgets('should use focus node when provided', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              focusNode: focusNode,
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      expect(focusNode.hasFocus, true);

      focusNode.dispose();
    });

    testWidgets('should set textInputAction when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              controller: controller,
              textInputAction: TextInputAction.next,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.textInputAction, TextInputAction.next);
    });

    testWidgets('should work without label', (tester) async {
      const hint = 'Search...';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledTextField(
              hint: hint,
              controller: controller,
              prefixIcon: const Icon(Icons.search),
            ),
          ),
        ),
      );

      expect(find.text(hint), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
