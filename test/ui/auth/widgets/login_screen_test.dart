import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/repositories/auth_repository.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/ui/auth/view_model/login_view_model.dart';
import 'package:cribe/ui/auth/widgets/login_screen.dart';
import 'package:cribe/ui/core/shared/button.dart';
import 'package:cribe/ui/core/shared/text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'login_screen_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginViewModel loginViewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginViewModel = LoginViewModel(mockAuthRepository);
  });

  Widget createTestWidget() {
    return MaterialApp(
      routes: {
        '/': (context) => ChangeNotifierProvider<LoginViewModel>.value(
              value: loginViewModel,
              child: const LoginScreen(),
            ),
        '/home': (context) => const Scaffold(
              body: Text('Home Screen'),
            ),
        '/register': (context) => const Scaffold(
              body: Text('Register Screen'),
            ),
      },
    );
  }

  group('LoginScreen', () {
    testWidgets('should display welcome text and form elements',
        (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle(); // Wait for any animations

      // Assert
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);

      // Check for text fields by type
      expect(find.byType(TextInput), findsNWidgets(2));

      // Check for button
      expect(find.byType(Button), findsOneWidget);
    });

    testWidgets('should have email field with correct properties',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Act - Find the email field (first TextInput)
      final emailFields = find.byType(TextInput);
      final emailField = tester.widget<TextInput>(emailFields.first);

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

      // Act - Find the password field (second TextInput)
      final textFields = find.byType(TextInput);
      final passwordField = tester.widget<TextInput>(textFields.at(1));

      // Assert
      expect(passwordField.label, equals('Password'));
      expect(passwordField.hint, equals('Enter your password'));
      expect(passwordField.obscureText, isTrue);
    });

    testWidgets('should show validation errors for empty fields',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Tap the button without filling fields
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert - Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show email validation error for invalid email',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show password validation error for short password',
        (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Enter valid email and short password
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), '123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Assert
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should call login with valid credentials', (tester) async {
      // Arrange
      final mockLoginResponse = LoginResponse(
        accessToken: 'access_token_123',
        refreshToken: 'refresh_token_123',
      );
      final mockApiResponse = ApiResponse<LoginResponse>(
        data: mockLoginResponse,
        statusCode: 200,
      );
      when(mockAuthRepository.login(any, any))
          .thenAnswer((_) async => mockApiResponse);

      await tester.pumpWidget(createTestWidget());

      // Act - Fill in valid credentials
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert
      verify(mockAuthRepository.login('test@example.com', 'password123'))
          .called(1);
    });

    testWidgets('should disable fields when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act - Set loading state manually
      loginViewModel.setLoading(true);
      await tester.pump();

      // Assert - Check that fields are disabled
      final emailField = tester.widget<TextInput>(find.byType(TextInput).first);
      final passwordField =
          tester.widget<TextInput>(find.byType(TextInput).at(1));

      expect(emailField.enabled, isFalse);
      expect(passwordField.enabled, isFalse);
    });

    testWidgets('should show snackbar on login error', (tester) async {
      // Arrange
      when(mockAuthRepository.login(any, any))
          .thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(createTestWidget());

      // Act - Fill credentials and submit
      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), 'wrongpassword');
      await tester.tap(find.text('Sign In'));
      await tester
          .pumpAndSettle(); // Wait for all animations and async operations

      // Assert - Error snackbar should be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Exception: Invalid credentials'), findsOneWidget);
    });

    testWidgets('should have sign up link', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });
  });
}
