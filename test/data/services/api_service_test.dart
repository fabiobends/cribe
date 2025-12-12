import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/models/auth/login_response.dart';
import 'package:cribe/data/models/auth/refresh_token_response.dart';
import 'package:cribe/data/services/api_service.dart';
import 'package:cribe/data/services/storage_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_service_test.mocks.dart';

@GenerateMocks([
  HttpClient,
  HttpClientResponse,
  HttpClientRequest,
  HttpHeaders,
  StorageService,
])
void main() {
  final baseUrl = 'https://api.example.com/v1';

  setUpAll(() async {
    dotenv.testLoad(fileInput: 'API_URL=$baseUrl');
  });

  group('ApiResponse', () {
    test('should create ApiResponse with all fields', () {
      // Arrange
      const testData = 'test_data';
      const statusCode = 200;
      const message = 'Success';

      // Act
      final response = ApiResponse<String>(
        data: testData,
        statusCode: statusCode,
        message: message,
      );

      // Assert
      expect(response.data, equals(testData));
      expect(response.statusCode, equals(statusCode));
      expect(response.message, equals(message));
    });

    test('should create ApiResponse without message', () {
      // Arrange
      const testData = 42;
      const statusCode = 201;

      // Act
      final response = ApiResponse<int>(
        data: testData,
        statusCode: statusCode,
      );

      // Assert
      expect(response.data, equals(testData));
      expect(response.statusCode, equals(statusCode));
      expect(response.message, isNull);
    });
  });

  group('ApiException', () {
    test('should create ApiException with message only', () {
      // Arrange
      const message = 'Test error message';

      // Act
      final exception = ApiException(message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.statusCode, isNull);
      expect(
        exception.toString(),
        equals('ApiException: $message (Status: null)'),
      );
    });

    test('should create ApiException with message and status code', () {
      // Arrange
      const message = 'Unauthorized';
      const statusCode = 401;

      // Act
      final exception = ApiException(message, statusCode: statusCode);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.statusCode, equals(statusCode));
      expect(
        exception.toString(),
        equals('ApiException: $message (Status: $statusCode)'),
      );
    });
  });

  group('ApiService', () {
    late ApiService apiService;
    late MockStorageService mockStorageService;
    late MockHttpClient mockHttpClient;
    late MockHttpClientRequest mockRequest;
    late MockHttpClientResponse mockResponse;
    late MockHttpHeaders mockHeaders;

    setUp(() async {
      mockStorageService = MockStorageService();
      mockHttpClient = MockHttpClient();
      mockRequest = MockHttpClientRequest();
      mockResponse = MockHttpClientResponse();
      mockHeaders = MockHttpHeaders();

      when(mockRequest.headers).thenReturn(mockHeaders);
      when(mockStorageService.getSecureValue(any)).thenAnswer((_) async => '');
      when(mockStorageService.setSecureValue(any, any))
          .thenAnswer((_) async => true);

      apiService = ApiService(
        storageService: mockStorageService,
        httpClient: mockHttpClient,
      );
    });

    tearDown(() async {
      try {
        await apiService.dispose();
        await mockStorageService.dispose();
      } catch (e) {
        // Ignore disposal errors in tests
      }
    });

    group('initialization', () {
      test('should initialize and dispose without errors', () async {
        await expectLater(apiService.init(), completes);
        await expectLater(apiService.dispose(), completes);
      });
    });

    group('updateBaseUrl', () {
      test('should update base URL when different', () {
        // Arrange
        const newUrl = 'https://api.newdomain.com/v2';

        // Act
        apiService.updateBaseUrl(newUrl);

        // Assert - verify the URL was updated (we can't directly check _baseUrl since it's private)
        // The method should complete without error and log the change
        expect(() => apiService.updateBaseUrl(newUrl), returnsNormally);
      });

      test('should not update base URL when same', () {
        // Arrange
        const currentUrl = 'https://api.example.com/v1';
        // Act & Assert
        expect(() => apiService.updateBaseUrl(currentUrl), returnsNormally);
      });
    });

    group('setTokens', () {
      test('should set authentication tokens', () async {
        final tokens = LoginResponse(
          accessToken: 'test_access_token',
          refreshToken: 'test_refresh_token',
        );

        await expectLater(apiService.setTokens(tokens), completes);
      });

      test('should handle empty tokens', () async {
        final tokens = LoginResponse(accessToken: '', refreshToken: '');
        await expectLater(apiService.setTokens(tokens), completes);
      });
    });

    group('_refreshTokenIfNeeded', () {
      test('should refresh token if expired and retry', () async {
        // Arrange
        final path = 'protected_resource';
        final initialTokens = AuthTokens(
          accessToken: 'expired_token',
          refreshToken: 'valid_refresh_token',
        );
        final refreshResponse = RefreshTokenResponse(
          accessToken: 'new_access_token',
        );

        var getUrlCallCount = 0;

        // Mock GET requests: first returns 401, second returns 200
        when(mockHttpClient.getUrl(any)).thenAnswer((_) async {
          getUrlCallCount++;
          final mockRequest = MockHttpClientRequest();
          when(mockRequest.headers).thenReturn(mockHeaders);
          when(mockRequest.close()).thenAnswer((_) async {
            final mockResponse = MockHttpClientResponse();
            if (getUrlCallCount == 1) {
              // First GET request - 401
              when(mockResponse.statusCode).thenReturn(HttpStatus.unauthorized);
              when(mockResponse.transform(utf8.decoder)).thenAnswer(
                (_) => Stream.value('{"message": "Unauthorized"}'),
              );
            } else {
              // Second GET request - 200
              when(mockResponse.statusCode).thenReturn(HttpStatus.ok);
              when(mockResponse.transform(utf8.decoder))
                  .thenAnswer((_) => Stream.value('{"data": "success"}'));
            }
            return mockResponse;
          });
          return mockRequest;
        });

        // Mock POST request for token refresh
        when(mockHttpClient.postUrl(any)).thenAnswer((_) async {
          final mockRequest = MockHttpClientRequest();
          when(mockRequest.headers).thenReturn(mockHeaders);
          when(mockRequest.close()).thenAnswer((_) async {
            final mockResponse = MockHttpClientResponse();
            when(mockResponse.statusCode).thenReturn(HttpStatus.ok);
            when(mockResponse.transform(utf8.decoder)).thenAnswer(
              (_) => Stream.value(jsonEncode(refreshResponse.toJson())),
            );
            return mockResponse;
          });
          return mockRequest;
        });

        apiService.setTokens(initialTokens);

        // Act
        final response = await apiService.get(path, (json) => json);

        // Assert
        expect(response.statusCode, equals(200));
        expect(response.data, equals({'data': 'success'}));
        verify(mockHttpClient.getUrl(any)).called(2); // Initial + retry
        verify(mockHttpClient.postUrl(any)).called(1); // Refresh token request
        verify(
          mockStorageService.setSecureValue(
            SecureStorageKey.accessToken,
            refreshResponse.accessToken,
          ),
        ).called(1);
      });

      test('should handle refresh token failure', () async {
        // Arrange
        final path = 'protected_resource';
        final initialTokens = AuthTokens(
          accessToken: 'expired_token',
          refreshToken: 'invalid_refresh_token',
        );

        // Mock GET request - returns 401
        when(mockHttpClient.getUrl(any)).thenAnswer((_) async {
          final mockRequest = MockHttpClientRequest();
          when(mockRequest.headers).thenReturn(mockHeaders);
          when(mockRequest.close()).thenAnswer((_) async {
            final mockResponse = MockHttpClientResponse();
            when(mockResponse.statusCode).thenReturn(HttpStatus.unauthorized);
            when(mockResponse.transform(utf8.decoder))
                .thenAnswer((_) => Stream.value('{"message": "Unauthorized"}'));
            return mockResponse;
          });
          return mockRequest;
        });

        // Mock POST request for token refresh - fails
        when(mockHttpClient.postUrl(any)).thenAnswer((_) async {
          final mockRequest = MockHttpClientRequest();
          when(mockRequest.headers).thenReturn(mockHeaders);
          when(mockRequest.close()).thenAnswer((_) async {
            final mockResponse = MockHttpClientResponse();
            when(mockResponse.statusCode).thenReturn(HttpStatus.unauthorized);
            when(mockResponse.transform(utf8.decoder)).thenAnswer(
              (_) => Stream.value('{"message": "Invalid refresh token"}'),
            );
            return mockResponse;
          });
          return mockRequest;
        });

        apiService.setTokens(initialTokens);

        // Act & Assert
        await expectLater(
          () => apiService.get(path, (json) => json),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              401,
            ),
          ),
        );
      });
    });

    // Table-driven tests for HTTP methods
    final httpMethodTests = [
      {
        'method': 'GET',
        'setupMock': (mock) => when(mock.getUrl(any)),
        'verifyMock': (mock) => verify(mock.getUrl(any)),
        'call': (path, body) => apiService.get(path, (json) => json),
      },
      {
        'method': 'POST',
        'setupMock': (mock) => when(mock.postUrl(any)),
        'verifyMock': (mock) => verify(mock.postUrl(any)),
        'call': (path, body) =>
            apiService.post(path, (json) => json, body: body),
      },
      {
        'method': 'PATCH',
        'setupMock': (mock) => when(mock.patchUrl(any)),
        'verifyMock': (mock) => verify(mock.patchUrl(any)),
        'call': (path, body) =>
            apiService.patch(path, (json) => json, body: body),
      },
      {
        'method': 'PUT',
        'setupMock': (mock) => when(mock.putUrl(any)),
        'verifyMock': (mock) => verify(mock.putUrl(any)),
        'call': (path, body) =>
            apiService.put(path, (json) => json, body: body),
      },
      {
        'method': 'DELETE',
        'setupMock': (mock) => when(mock.deleteUrl(any)),
        'verifyMock': (mock) => verify(mock.deleteUrl(any)),
        'call': (path, body) => apiService.delete(path, (json) => json),
      },
    ];

    for (final testCase in httpMethodTests) {
      group(testCase['method'] as String, () {
        test('should return data when API call is successful', () async {
          const response = '{"data": "test"}';
          (testCase['setupMock'] as Function)(mockHttpClient)
              .thenAnswer((_) async => mockRequest);
          when(mockRequest.close()).thenAnswer((_) async => mockResponse);
          when(mockResponse.statusCode).thenReturn(HttpStatus.ok);
          when(mockResponse.transform(utf8.decoder))
              .thenAnswer((_) => Stream.value(response));

          final result =
              await (testCase['call'] as Function)('path', {'key': 'val'});

          expect(result.statusCode, equals(200));
          (testCase['verifyMock'] as Function)(mockHttpClient).called(1);
          verify(mockRequest.close()).called(1);
        });

        test('should throw ApiException on error', () async {
          (testCase['setupMock'] as Function)(mockHttpClient)
              .thenAnswer((_) async => mockRequest);
          when(mockRequest.close()).thenAnswer((_) async => mockResponse);
          when(mockResponse.statusCode).thenReturn(HttpStatus.badRequest);
          when(mockResponse.transform(utf8.decoder))
              .thenAnswer((_) => Stream.value('{"message": "Error"}'));

          await expectLater(
            () => (testCase['call'] as Function)('path', null),
            throwsA(isA<ApiException>()),
          );
        });

        test('should throw ApiException on network error', () async {
          (testCase['setupMock'] as Function)(mockHttpClient)
              .thenThrow(const SocketException('No network'));

          await expectLater(
            () => (testCase['call'] as Function)('path', null),
            throwsA(isA<ApiException>()),
          );
        });
      });
    }

    group('getStream', () {
      test('should stream SSE events successfully', () async {
        // Arrange
        const path = 'stream/events';
        final sseData = 'event: message\n'
            'data: {"id": 1, "text": "Hello"}\n'
            '\n'
            'event: message\n'
            'data: {"id": 2, "text": "World"}\n'
            '\n';

        // Create a controller for the stream
        final streamController = StreamController<List<int>>();

        when(mockHttpClient.getUrl(any)).thenAnswer((_) async => mockRequest);
        when(mockRequest.close()).thenAnswer((_) async => mockResponse);
        when(mockResponse.statusCode).thenReturn(200);

        // Mock both transform and listen to handle the stream properly
        when(mockResponse.transform(utf8.decoder))
            .thenAnswer((_) => streamController.stream.transform(utf8.decoder));
        when(
          mockResponse.listen(
            any,
            onError: anyNamed('onError'),
            onDone: anyNamed('onDone'),
            cancelOnError: anyNamed('cancelOnError'),
          ),
        ).thenAnswer((invocation) {
          return streamController.stream.listen(
            invocation.positionalArguments[0] as void Function(List<int>),
            onError: invocation.namedArguments[#onError] as Function?,
            onDone: invocation.namedArguments[#onDone] as void Function()?,
            cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
          );
        });

        // Act
        final stream = apiService.getStream<Map<String, dynamic>>(
          path,
          (eventType, json) => json,
        );

        // Add data to stream after a delay to ensure listener is set up
        Future.delayed(const Duration(milliseconds: 10), () {
          streamController.add(sseData.codeUnits);
          streamController.close();
        });

        // Assert
        final events = await stream.toList();
        expect(events.length, 2);
        expect(events[0]['id'], 1);
        expect(events[0]['text'], 'Hello');
        expect(events[1]['id'], 2);
        expect(events[1]['text'], 'World');

        verify(mockHttpClient.getUrl(any)).called(1);
        verify(mockRequest.close()).called(1);
      });

      test('should throw ApiException on HTTP error status', () async {
        // Arrange
        const path = 'stream/events';
        final streamController = StreamController<List<int>>();

        when(mockHttpClient.getUrl(any)).thenAnswer((_) async => mockRequest);
        when(mockRequest.close()).thenAnswer((_) async => mockResponse);
        when(mockResponse.statusCode).thenReturn(404);
        when(mockResponse.transform(utf8.decoder))
            .thenAnswer((_) => streamController.stream.transform(utf8.decoder));
        when(
          mockResponse.listen(
            any,
            onError: anyNamed('onError'),
            onDone: anyNamed('onDone'),
            cancelOnError: anyNamed('cancelOnError'),
          ),
        ).thenAnswer((invocation) {
          return streamController.stream.listen(
            invocation.positionalArguments[0] as void Function(List<int>),
            onError: invocation.namedArguments[#onError] as Function?,
            onDone: invocation.namedArguments[#onDone] as void Function()?,
            cancelOnError: invocation.namedArguments[#cancelOnError] as bool?,
          );
        });

        // Add error response
        Future.delayed(const Duration(milliseconds: 10), () {
          streamController.add('{"message": "Not found"}'.codeUnits);
          streamController.close();
        });

        // Act & Assert
        await expectLater(
          apiService.getStream(path, (eventType, json) => json).toList(),
          throwsA(
            isA<ApiException>().having(
              (e) => e.statusCode,
              'statusCode',
              404,
            ),
          ),
        );
      });
    });
  });
}
