import 'dart:convert';

import 'package:peng_houth_cycle/core/network/api_client.dart';
import 'package:peng_houth_cycle/core/storage/local_storage.dart';
import 'package:peng_houth_cycle/features/auth/data/models/auth_response.dart';
import 'package:peng_houth_cycle/features/auth/data/models/login_request.dart';
import 'package:peng_houth_cycle/features/auth/data/models/register_model.dart';
import 'package:peng_houth_cycle/features/auth/data/models/user_model.dart';
import 'package:peng_houth_cycle/features/auth/data/services/auth_api_service.dart';

class AuthRepository {
  AuthRepository(this._service, this._client, this._storage);

  final AuthApiService _service;
  final ApiClient _client;
  final LocalStorage _storage;

  Future<UserModel> login(LoginRequest request) async {
    final res = await _service.login(request);
    await _saveSession(res);
    return res.user;
  }

  Future<UserModel> register(RegisterRequest request) async {
    final res = await _service.register(request);
    await _saveSession(res);
    return res.user;
  }

  /// Called once at app start — returns the user if a session exists.
  Future<UserModel?> restoreSession() async {
    final token = await _storage.readToken();
    final userJson = await _storage.readUser();
    if (token == null || userJson == null) return null;

    _client.setToken(token);
    return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _client.setToken(null);
  }

  Future<void> _saveSession(AuthResponse res) async {
    await _storage.saveSession(
      token: res.token,
      userJson: jsonEncode(res.user.toJson()),
    );
    _client.setToken(res.token);
  }
}
