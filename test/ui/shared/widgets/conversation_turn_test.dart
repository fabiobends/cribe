import 'package:cribe/ui/shared/widgets/conversation_turn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConversationTurn', () {
    testWidgets('renders with speaker name and content',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Test Speaker',
              contentWidgets: [
                Text('Hello'),
                Text('World'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Speaker'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('World'), findsOneWidget);
    });

    testWidgets('aligns left by default', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.start);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('aligns right when specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
              alignment: TurnAlignment.right,
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.end);
    });

    testWidgets('uses custom accent color when provided',
        (WidgetTester tester) async {
      const customColor = Colors.green;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
              accentColor: customColor,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration == null &&
              widget.color == customColor,
        ),
      );

      expect(container.color, customColor);
    });

    testWidgets('uses primary color for left alignment by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.red,
            ),
          ),
          home: const Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration == null &&
              widget.color != null,
        ),
      );

      expect(container.color, Colors.blue);
    });

    testWidgets('uses secondary color for right alignment by default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              secondary: Colors.red,
            ),
          ),
          home: const Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
              alignment: TurnAlignment.right,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration == null &&
              widget.color != null,
        ),
      );

      expect(container.color, Colors.red);
    });

    testWidgets('respects custom max width fraction',
        (WidgetTester tester) async {
      const customMaxWidth = 0.5;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [Text('Content')],
              maxWidthFraction: customMaxWidth,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final constrainedBoxes =
          tester.widgetList<ConstrainedBox>(find.byType(ConstrainedBox));
      final screenWidth =
          tester.view.physicalSize.width / tester.view.devicePixelRatio;
      final expectedMaxWidth = screenWidth * customMaxWidth;

      // Find the ConstrainedBox with maxWidth constraint matching our custom fraction
      final matchingBox = constrainedBoxes.firstWhere(
        (box) => box.constraints.maxWidth == expectedMaxWidth,
      );

      expect(matchingBox.constraints.maxWidth, expectedMaxWidth);
    });

    testWidgets('renders all content widgets in order',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConversationTurn(
              speakerName: 'Speaker',
              contentWidgets: [
                Text('First'),
                Text('Second'),
                Text('Third'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });
  });
}
