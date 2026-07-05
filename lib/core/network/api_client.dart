import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:peng_houth_cycle/core/errors/app_exception.dart';

import 'api_endpoints.dart';

class ApiClient {
  // ← no extends: helper is static-only
  String? _token;
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 60);

  /// Called by AuthRepository on login/restore/logout.
  void setToken(String? token) => _token = token;

  Future<dynamic> get(String endpoint, {Map<String, String>? query}) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$endpoint',
    ).replace(queryParameters: query);
    try {
      final response = await ApiClientHelper.withRetry(
        // token headers here too → authenticated GETs work later
        () => _client
            .get(uri, headers: ApiClientHelper.headers(_token))
            .timeout(_timeout),
      );
      return ApiClientHelper.handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException(); // retry already happened inside withRetry
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$path');
    try {
      final response = await ApiClientHelper.withRetry(
        () => _client
            .post(
              uri,
              headers: ApiClientHelper.headers(_token),
              body: jsonEncode(body ?? {}), // ← THE missing piece
            )
            .timeout(_timeout), // ← was missing too
      );
      return ApiClientHelper.handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    } on TimeoutException {
      throw const NetworkException();
    }
  }
}

class ApiClientHelper {
  static Map<String, String> headers(String? token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  /// Render cold start → one automatic retry on timeout/client error.
  static Future<http.Response> withRetry(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
    } on TimeoutException {
      return await request();
    } on http.ClientException {
      return await request();
    }
  }

  static dynamic handleResponse(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return decoded;
      case 404:
        throw const NotFoundException();
      case >= 500:
        throw const ServerException();
      default:
        // 401 wrong password, 422 validation, etc.
        // Surface Laravel's own message instead of "Error 422".
        final message = decoded is Map<String, dynamic>
            ? decoded['message'] as String? ?? 'Request failed'
            : 'Request failed';
        throw ApiException(message, response.statusCode);
    }
  }
}
