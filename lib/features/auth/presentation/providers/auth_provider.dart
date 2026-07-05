import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/core/enum/app_state.dart';
import 'package:peng_houth_cycle/features/auth/data/models/login_request.dart';
import 'package:peng_houth_cycle/features/auth/data/models/register_model.dart';
import 'package:peng_houth_cycle/features/auth/data/models/user_model.dart';
import 'package:peng_houth_cycle/features/auth/data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._repository);

  final AuthRepository _repository;

  AppState _state = AppState.idle;
  AppState get state => _state;

  UserModel? _user;
  UserModel? get user => _user;
  bool get isLoggedIn => _user != null;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  /// Call once from bootstrap: ..restoreSession()
  Future<void> restoreSession() async {
    _user = await _repository.restoreSession();
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _run(
      () => _repository.login(LoginRequest(email: email, password: password)),
    );
  }

  Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _run(
      () => _repository.register(
        RegisterRequest(
          firstname: firstname,
          lastname: lastname,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      ),
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    _state = AppState.idle;
    notifyListeners();
  }

  Future<bool> _run(Future<UserModel> Function() action) async {
    _state = AppState.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await action();
      _state = AppState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = AppState.error;
      notifyListeners();
      return false;
    }
  }
}
