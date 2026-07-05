### Core

**Quick Navigation**

- [Enum - App State](#enum---app-state)
- [Errors - App Exception](#errors---app-exception)
- [Extensions - App Extension](#extensions---app-extension)
- [Network - Api Client](#network---api-client)
- [Network - Api Endpoints](#network---api-endpoints)
- [Theme - App Theme](#theme---app-theme)
- [Storage - Local Storage](#storage---local-storage)

---

### Enum - App State

> `core/enum/app_state.dart`

```dart
enum AppState { idle, loading, success, error }
```

---

### Errors - App Exception

> `core/errors/app_excepion.dart`

```dart
class AppException implements Exception {
  final String message;
  final int status;

  const AppException(this.message, this.status);

  @override
  String toString() => message;
  int toInt() => status;
}

class NetworkException extends AppException {
  const NetworkException()
    : super(
        'No internet connection',
        0, // ! 0 = no HTTP response
    );
}

class ServerException extends AppException {
  const ServerException([
    super.message = 'Server error, try again later',
    super.status = 500, // ! Server Error
  ]);
}

class NotFoundException extends AppException {
  const NotFoundException()
    : super(
        'Resource not found',
        404, // ! Not Found
    );
}
```

---

### Extensions - App Extension

> `core/extensions/app_extension.dart`

```dart
class TimeoutAppException extends AppException {
  const TimeoutAppException() : super('Server is waking up, try again');
}
```

---

### Network - Api Client

> `core/network/api_client.dart`

```dart
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
```

---

### Network - Api Endpoints

> `core/network/api_endpoints.dart`

```dart
class ApiEndpoints {
  ApiEndpoints();

  static const String baseUrl = 'https://peng-houth-cycle-api.onrender.com/api';
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Stations
  static const String stations = '/stations';
  static String stationDetail(int id) => '/stations/$id';
}
```

---

### Theme - App Theme

> `core/theme/app_theme.dart`

```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    scaffoldBackgroundColor: Colors.grey.shade50,
  );
}
```

---

### Storage - Local Storage

> `core/storage/local_storage.dart`

```dart
class LocalStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> saveSession({
    required String token,
    required String userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, userJson);
  }

  Future<String?> readToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> readUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
```