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
  final String Function() _baseUrlResolver;
  AuthTokens _tokens = AuthTokens(
    accessToken: '',
    refreshToken: '',
  );
  final StorageService _storageService;
  final HttpClient _httpClient = HttpClient();

  ApiService({
    required String apiUrl,
    required StorageService storageService,
    String Function()? baseUrlResolver,
  })  : _baseUrlResolver = baseUrlResolver ?? (() => apiUrl),
        _storageService = storageService;

  String get baseUrl => _baseUrlResolver();

  @override
  Future<void> init() async {
    final accessToken = _storageService.getValue(StorageKey.accessToken);
    final refreshToken = _storageService.getValue(StorageKey.refreshToken);
    setTokens(
      LoginResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    final StorageService storageService = StorageService();
    await storageService.dispose();
  }

  Future<void> setTokens(AuthTokens tokens) async {
    await _storageService.setValue(StorageKey.accessToken, tokens.accessToken);
    await _storageService.setValue(
      StorageKey.refreshToken,
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
    try {
      final uri = Uri.parse('$baseUrl/$path');
      final httpRequest = await _httpClient.getUrl(uri);
      _addHeaders(httpRequest);
      return _refreshAndProcessResponse(httpRequest, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Network error during GET request: $e',
      );
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$path');
      final httpRequest = await _httpClient.postUrl(uri);
      _addHeaders(httpRequest);
      _addBody(httpRequest, body);
      return _refreshAndProcessResponse(httpRequest, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error during POST request: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/$path');
      final httpRequest = await _httpClient.deleteUrl(uri);
      _addHeaders(httpRequest);
      return _refreshAndProcessResponse(httpRequest, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Network error during DELETE request: $e',
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl}/$path');
      final httpRequest = await _httpClient.putUrl(uri);
      _addHeaders(httpRequest);
      _addBody(httpRequest, body);
      return _refreshAndProcessResponse(httpRequest, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Network error during PUT request: $e',
      );
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$path');
      final httpRequest = await _httpClient.patchUrl(uri);
      _addHeaders(httpRequest);
      _addBody(httpRequest, body);
      return _refreshAndProcessResponse(httpRequest, fromJson);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'Network error during PATCH request: $e',
      );
    }
  }

  void _updateAccessToken(String accessToken) {
    _tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: _tokens.refreshToken,
    );
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
      final response = await post<RefreshTokenResponse>(
        ApiPath.refreshToken,
        RefreshTokenResponse.fromJson,
        body: {'refreshToken': _tokens.refreshToken},
      );
      if (response.statusCode == 200) {
        // If the refresh is successful, update the access token
        _updateAccessToken(response.data.accessToken);
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  Future<ApiResponse<T>> _refreshAndProcessResponse<T>(
    HttpClientRequest httpRequest,
    T Function(dynamic) fromJson,
  ) async {
    HttpClientResponse response = await httpRequest.close();
    final hasRefreshed = await _refreshTokenIfNeeded(response);
    if (hasRefreshed) {
      _addHeaders(httpRequest); // Re-add headers after refresh
      response = await httpRequest.close(); // Re-send request
    }
    return _processResponse(response, fromJson);
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
