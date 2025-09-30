import 'package:cribe/ui/shared/widgets/styled_button.dart';
import 'package:cribe/ui/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StyledButton', () {
    testWidgets('should display text and handle tap', (tester) async {
      // Arrange
      bool wasPressed = false;
      const buttonText = 'Test Button';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: buttonText,
              variant: ButtonVariant.primary,
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(StyledButton));
      await tester.pump();

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(wasPressed, isTrue);
    });

    testWidgets('should render primary variant correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Primary Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(StyledButton), findsOneWidget);
      expect(find.text('Primary Button'), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('should render secondary variant correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Secondary Button',
              variant: ButtonVariant.secondary,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(StyledButton), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
    });

    testWidgets('should render danger variant correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Danger Button',
              variant: ButtonVariant.danger,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(StyledButton), findsOneWidget);
      expect(find.text('Danger Button'), findsOneWidget);
    });

    testWidgets('should disable button when isEnabled is false',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Disabled Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      // Act & Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show loading indicator when isLoading is true',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Loading Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Act & Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(StyledText), findsOneWidget);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull); // Should be disabled when loading
    });

    testWidgets(
        'should disable button when both isLoading and isEnabled are false',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Disabled Loading Button',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isLoading: true,
              isEnabled: false,
            ),
          ),
        ),
      );

      // Act & Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle null onPressed callback', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Null Callback',
              variant: ButtonVariant.primary,
              onPressed: null,
            ),
          ),
        ),
      );

      // Act & Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should render with all variants and states combinations',
        (tester) async {
      // Arrange - Test all variant combinations
      final variants = [
        ButtonVariant.primary,
        ButtonVariant.secondary,
        ButtonVariant.danger,
      ];

      for (final variant in variants) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  StyledButton(
                    text: 'Enabled ${variant.name}',
                    variant: variant,
                    onPressed: () {},
                  ),
                  StyledButton(
                    text: 'Disabled ${variant.name}',
                    variant: variant,
                    onPressed: () {},
                    isEnabled: false,
                  ),
                  StyledButton(
                    text: 'Loading ${variant.name}',
                    variant: variant,
                    onPressed: () {},
                    isLoading: true,
                  ),
                ],
              ),
            ),
          ),
        );

        // Act & Assert
        expect(find.byType(StyledButton), findsNWidgets(3));
        await tester.pump();
      }
    });

    testWidgets('should properly handle StyledText color when loading',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StyledButton(
              text: 'Loading Text Test',
              variant: ButtonVariant.primary,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      // Act & Assert
      final styledText = tester.widget<StyledText>(find.byType(StyledText));
      expect(styledText.color, equals(Colors.transparent));
    });
  });
}
