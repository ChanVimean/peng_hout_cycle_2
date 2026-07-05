import 'package:peng_houth_cycle/core/network/api_client.dart';
import 'package:peng_houth_cycle/core/network/api_endpoints.dart';
import 'package:peng_houth_cycle/features/auth/data/models/auth_response.dart';
import 'package:peng_houth_cycle/features/auth/data/models/login_request.dart';
import 'package:peng_houth_cycle/features/auth/data/models/register_model.dart';

class AuthApiService {
  AuthApiService(this._client);
  final ApiClient _client;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _client.post(
      ApiEndpoints.login,
      body: request.toJson(),
    );
    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _client.post(
      ApiEndpoints.register,
      body: request.toJson(),
    );
    return AuthResponse.fromJson(response as Map<String, dynamic>);
  }
}
