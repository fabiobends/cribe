import 'dart:convert';
import 'dart:io';

import 'package:cribe/core/constants/api_path.dart';
import 'package:cribe/core/constants/storage_keys.dart';
import 'package:cribe/data/model/auth/login_response.dart';
import 'package:cribe/data/model/auth/refresh_token_response.dart';
import 'package:cribe/data/services/base_service.dart';
import 'package:cribe/data/services/storage_service.dart';

class ApiResponse<T> {
  final T data;
  final int statusCode;
  final String? message;

  ApiResponse({
    required this.data,
    required this.statusCode,
    this.message,
  });
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService extends BaseService {
  final String Function() baseUrlResolver;
  AuthTokens _tokens = AuthTokens(
    accessToken: '',
    refreshToken: '',
  );
  final StorageService storageService;
  final HttpClient httpClient;

  ApiService({
    required this.storageService,
    required this.httpClient,
    required this.baseUrlResolver,
  });

  String get baseUrl => baseUrlResolver();

  @override
  Future<void> init() async {
    logger.debug('Initializing ApiService tokens from secure storage');
    final accessToken =
        await storageService.getSecureValue(SecureStorageKey.accessToken);
    final refreshToken =
        await storageService.getSecureValue(SecureStorageKey.refreshToken);
    setTokens(
      LoginResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    logger.debug('Disposing ApiService resources');
    final StorageService storageService = StorageService();
    await storageService.dispose();
  }

  Future<void> setTokens(AuthTokens tokens) async {
    logger.debug('Setting authentication tokens');
    await storageService.setSecureValue(
      SecureStorageKey.accessToken,
      tokens.accessToken,
    );
    await storageService.setSecureValue(
      SecureStorageKey.refreshToken,
      tokens.refreshToken,
    );
    _tokens = AuthTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
  }

  Future<ApiResponse<T>> get<T>(
    String path,
    T Function(dynamic) fromJson,
  ) async {
    return _makeRequestWithRetry(
      () async {
        final uri = _getUri(path);
        final httpRequest = await httpClient.getUrl(uri);
        _addHeaders(httpRequest);
        return httpRequest;
      },
      fromJson,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    return _makeRequestWithRetry(
      () async {
        final uri = _getUri(path);
        final httpRequest = await httpClient.postUrl(uri);
        _addHeaders(httpRequest);
        _addBody(httpRequest, body);
        return httpRequest;
      },
      fromJson,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path,
    T Function(dynamic) fromJson,
  ) async {
    return _makeRequestWithRetry(
      () async {
        final uri = _getUri(path);
        final httpRequest = await httpClient.deleteUrl(uri);
        _addHeaders(httpRequest);
        return httpRequest;
      },
      fromJson,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    return _makeRequestWithRetry(
      () async {
        final uri = _getUri(path);
        final httpRequest = await httpClient.putUrl(uri);
        _addHeaders(httpRequest);
        _addBody(httpRequest, body);
        return httpRequest;
      },
      fromJson,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    return _makeRequestWithRetry(
      () async {
        final uri = _getUri(path);
        final httpRequest = await httpClient.patchUrl(uri);
        _addHeaders(httpRequest);
        _addBody(httpRequest, body);
        return httpRequest;
      },
      fromJson,
    );
  }

  Uri _getUri(String path) {
    final uri = Uri.parse(baseUrl).resolve(path);
    return uri;
  }

  void _updateAccessToken(String accessToken) {
    _tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: _tokens.refreshToken,
    );
    // Keep storage in sync - use secure storage for token
    storageService.setSecureValue(SecureStorageKey.accessToken, accessToken);
  }

  void _addHeaders(HttpClientRequest httpRequest) {
    httpRequest.headers.set('Content-Type', 'application/json');
    httpRequest.headers.set('Accept', 'application/json');
    if (_tokens.accessToken.isNotEmpty) {
      httpRequest.headers.set('Authorization', 'Bearer ${_tokens.accessToken}');
    }
  }

  void _addBody(HttpClientRequest httpRequest, Map<String, dynamic>? body) {
    if (body != null) {
      httpRequest.write(jsonEncode(body));
    }
  }

  Future<bool> _refreshTokenIfNeeded(HttpClientResponse response) async {
    final shouldRefresh =
        response.statusCode == 401 && _tokens.refreshToken.isNotEmpty;
    if (shouldRefresh) {
      try {
        // Make refresh token request directly without retry logic
        final uri = _getUri(ApiPath.refreshToken);
        final httpRequest = await httpClient.postUrl(uri);
        _addHeaders(httpRequest);
        _addBody(httpRequest, {'refreshToken': _tokens.refreshToken});
        final refreshResponse = await httpRequest.close();

        if (refreshResponse.statusCode == 200) {
          final responseBody =
              await refreshResponse.transform(utf8.decoder).join();
          final data = RefreshTokenResponse.fromJson(jsonDecode(responseBody));
          _updateAccessToken(data.accessToken);
          return true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<ApiResponse<T>> _makeRequestWithRetry<T>(
    Future<HttpClientRequest> Function() createRequest,
    T Function(dynamic) fromJson,
  ) async {
    try {
      // Make the initial request
      HttpClientRequest httpRequest = await createRequest();
      HttpClientResponse response = await httpRequest.close();

      // Check if we need to refresh the token
      final hasRefreshed = await _refreshTokenIfNeeded(response);

      if (hasRefreshed) {
        // Create a new request for the retry
        httpRequest = await createRequest();
        response = await httpRequest.close();
      }

      return _processResponse(response, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: $e');
    }
  }

  Future<ApiResponse<T>> _processResponse<T>(
    HttpClientResponse response,
    T Function(dynamic) fromJson,
  ) async {
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode >= 400) {
      String message = 'Request failed';
      try {
        final errorData = jsonDecode(responseBody);
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          message = errorData['message'].toString();
        }
      } catch (e) {
        // If JSON parsing fails, use the response body as message or default
        message = responseBody.isNotEmpty ? responseBody : 'Request failed';
      }
      throw ApiException(message, statusCode: response.statusCode);
    }

    final data = fromJson(jsonDecode(responseBody));
    return ApiResponse(data: data, statusCode: response.statusCode);
  }
}
