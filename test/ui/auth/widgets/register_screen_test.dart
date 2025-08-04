import 'package:cribe/data/model/auth/register_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_model/register_view_model.dart';
import 'package:cribe/ui/auth/widgets/register_screen.dart';
import 'package:cribe/ui/core/shared/button.dart';
import 'package:cribe/ui/core/shared/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'register_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late RegisterViewModel registerViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    registerViewModel = RegisterViewModel(mockAuthRepository);
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/': (context) => Scaffold(
              body: ChangeNotifierProvider<RegisterViewModel>.value(
                value: registerViewModel,
                child: const RegisterScreen(),
              ),
            ),
        '/login': (context) => const Scaffold(
              body: Text('Login Screen'),
            ),
        '/home': (context) => const Scaffold(
              body: Text('Home Screen'),
            ),
      },
    );
  }

  group('RegisterScreen', () {
    testWidgets('should display title text and form elements', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Wait for any animations

      // Assert
      expect(
        find.text('Create Account'),
        findsNWidgets(2),
      ); // Title and button text
      expect(find.text('Sign up to get started'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Check for text fields by type - should have 5 fields
      expect(find.byType(TextInput), findsNWidgets(5));

      // Check for button
      expect(find.byType(Button), findsOneWidget);
      expect(
        find.text('Create Account'),
        findsNWidgets(2),
      ); // Title and button text
    });

    testWidgets('should have first name field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Find the first name field (first TextInput)
      final firstNameFields = find.byType(TextInput);
      final firstNameField = tester.widget<TextInput>(firstNameFields.first);

      // Assert
      expect(firstNameField.label, equals('First Name'));
      expect(firstNameField.hint, equals('Enter your first name'));
      expect(firstNameField.keyboardType, equals(TextInputType.name));
      expect(firstNameField.obscureText, isFalse);
    });

    testWidgets('should have last name field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find the last name field (second TextInput)
      final textFields = find.byType(TextInput);
      final lastNameField = tester.widget<TextInput>(textFields.at(1));

      // Assert
      expect(lastNameField.label, equals('Last Name'));
      expect(lastNameField.hint, equals('Enter your last name'));
      expect(lastNameField.keyboardType, equals(TextInputType.name));
      expect(lastNameField.obscureText, isFalse);
    });

    testWidgets('should have email field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find the email field (third TextInput)
      final textFields = find.byType(TextInput);
      final emailField = tester.widget<TextInput>(textFields.at(2));

      // Assert
      expect(emailField.label, equals('Email'));
      expect(emailField.hint, equals('Enter your email'));
      expect(emailField.keyboardType, equals(TextInputType.emailAddress));
      expect(emailField.obscureText, isFalse);
    });

    testWidgets('should have password field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find the password field (fourth TextInput)
      final textFields = find.byType(TextInput);
      final passwordField = tester.widget<TextInput>(textFields.at(3));

      // Assert
      expect(passwordField.label, equals('Password'));
      expect(passwordField.hint, equals('Create a password'));
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('should have confirm password field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find the confirm password field (fifth TextInput)
      final textFields = find.byType(TextInput);
      final confirmPasswordField = tester.widget<TextInput>(textFields.at(4));

      // Assert
      expect(confirmPasswordField.label, equals('Confirm Password'));
      expect(confirmPasswordField.hint, equals('Confirm your password'));
      expect(confirmPasswordField.obscureText, isTrue);
    });

    testWidgets('should show validation errors for empty fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Find the button by text and tap it without filling fields
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Assert - Should show validation errors
      expect(find.text('Please enter your first name'), findsOneWidget);
      expect(find.text('Please enter your last name'), findsOneWidget);
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('should show email validation error for invalid email',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter invalid email
      final emailField = find.byType(TextFormField).at(2);
      await tester.enterText(emailField, 'invalid-email');
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show password validation error for short password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter valid info and short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'test@example.com');
      await tester.enterText(textFields.at(3), '123');
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Assert
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should show password mismatch error', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter valid info but mismatched passwords
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'test@example.com');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password456');
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should call register with valid credentials', (tester) async {
      // Arrange
      final mockRegisterResponse = RegisterResponse(
        id: 123,
      );
      final mockApiResponse = ApiResponse<RegisterResponse>(
        data: mockRegisterResponse,
        statusCode: 201,
      );
      when(mockAuthRepository.register(any, any, any, any))
          .thenAnswer((_) async => mockApiResponse);

      await tester.pumpWidget(createTestWidget());

      // Act - Fill in valid credentials
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'test@example.com');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert
      verify(
        mockAuthRepository.register(
          'test@example.com',
          'password123',
          'John',
          'Doe',
        ),
      ).called(1);
    });

    testWidgets('should disable fields when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Set loading state manually
      registerViewModel.setLoading(true);
      await tester.pump();

      // Assert - Check that fields are disabled
      final firstNameField =
          tester.widget<TextInput>(find.byType(TextInput).first);
      final lastNameField =
          tester.widget<TextInput>(find.byType(TextInput).at(1));
      final emailField = tester.widget<TextInput>(find.byType(TextInput).at(2));
      final passwordField =
          tester.widget<TextInput>(find.byType(TextInput).at(3));
      final confirmPasswordField =
          tester.widget<TextInput>(find.byType(TextInput).at(4));

      expect(firstNameField.enabled, isFalse);
      expect(lastNameField.enabled, isFalse);
      expect(emailField.enabled, isFalse);
      expect(passwordField.enabled, isFalse);
      expect(confirmPasswordField.enabled, isFalse);
    });

    testWidgets('should show snackbar on register error', (tester) async {
      // Arrange
      when(mockAuthRepository.register(any, any, any, any))
          .thenThrow(Exception('Registration failed'));

      await tester.pumpWidget(createTestWidget());

      // Act - Fill credentials and submit
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'John');
      await tester.enterText(textFields.at(1), 'Doe');
      await tester.enterText(textFields.at(2), 'test@example.com');
      await tester.enterText(textFields.at(3), 'password123');
      await tester.enterText(textFields.at(4), 'password123');
      final buttonFinder = find.widgetWithText(Button, 'Create Account');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert - Error snackbar should be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Registration failed'), findsOneWidget);
    });

    testWidgets('should have sign in link', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should disable back button when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Set loading state manually
      registerViewModel.setLoading(true);
      await tester.pump();

      // Assert - Check that back button is disabled by finding the IconButton
      final backButtonFinder = find.byType(IconButton);
      expect(backButtonFinder, findsOneWidget);

      // The button should be disabled, we can check that the IconButton widget has onPressed set to null
      final iconButton = tester.widget<IconButton>(backButtonFinder);
      expect(iconButton.onPressed, isNull);
    });
  });
}
