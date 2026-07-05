### Auth Domain

**Quick Navigation**

- [Folder Layout](#folder-layout)
- [Packages](#packages)
- [Api Endpoints](#api-endpoints)
- [Api Client - Token & POST Support](#api-client---token--post-support)
- [Models - User Model](#models---user-model)
- [Models - Login Request](#models---login-request)
- [Models - Register Request](#models---register-request)
- [Models - Auth Response](#models---auth-response)
- [Services - Auth](#services---auth)
- [Repository - Auth](#repository---auth)
- [Provider](#provider)
- [Screens - Login](#screens---login)
- [Screens - Register](#screens---register)
- [Bootstrap Wiring](#bootstrap-wiring)

---

### Folder Layout

Following `Architecture.md` — folders marked _(empty)_ exist now, filled later:

```bash
features/auth/
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── login_request.dart
│   │   ├── register_request.dart
│   │   └── auth_response.dart
│   ├── services/
│   │   └── auth_api_service.dart
│   └── repositories/
│       └── auth_repository.dart
└── presentation/
    ├── entities/                        # (empty)
    ├── providers/
    │   └── auth_provider.dart
    ├── screens/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── helpers/                         # (empty)
    └── widgets/                         # (empty)
```

---

> [!IMPORTANT]
> One new dependency for persisting the token across app restarts:

```bash
flutter pub add shared_preferences
```

---

### Api Endpoints

> `core/network/api_endpoints.dart` — add:

```dart
class ApiEndpoints {
  // ...existing...
  static const String login = '/auth/login';
  static const String register = '/auth/register';
}
```

---

### Api Client - Token & POST Support

> `core/network/api_client.dart` — add a token field + `post()`.
> Once `setToken` is called, every request carries
> `Authorization: Bearer <token>` — which the rental domain will need too.

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

### Exception

> `core/errors/app_exception.dart`

Add this custom **Exception**

```dart
/// Catch-all for other API errors (401, 422 validation, etc.)
/// carrying the server's own message.
class ApiException extends AppException {
  const ApiException(super.message, super.status);
}

```

---

### Models - User Model

> `features/auth/data/models/user_model.dart`

```dart
class UserModel {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String role;

  const UserModel({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.role,
  });

  String get fullName => '$firstname $lastname';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstname: json['firstname'] as String? ?? '',
      lastname: json['lastname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? 'customer', // register response has no role
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'role': role,
  };
}
```

---

### Models - Login Request

> `features/auth/data/models/login_request.dart`

```dart
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
```

---

### Models - Register Request

> `features/auth/data/models/register_request.dart`

```dart
class RegisterRequest {
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
    'firstname': firstname,
    'lastname': lastname,
    'email': email,
    'phone': phone,
    'password': password,
    'password_confirmation': passwordConfirmation,
  };
}
```

---

### Models - Auth Response

> `features/auth/data/models/auth_response.dart`
>
> Both `/auth/login` and `/auth/register` return `{ user, token, token_type }`.

```dart
class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }
}
```

---

### Services - Auth

> `features/auth/data/services/auth_api_service.dart` — raw calls only, no storage.

```dart
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
```

---

### Repository - Auth

> `features/auth/data/repositories/auth_repository.dart`
>
> Service + token storage (per `Architecture.md`). Owns the token lifecycle:
> persist it, restore it on app launch, inject it into `ApiClient`.

```dart
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
```

---

### Provider

> `features/auth/presentation/providers/auth_provider.dart`
>
> Same `AppState` machine as `HomeProvider`. `isLoggedIn` is what the
> rental flow will check before allowing "Rent this bike".

```dart
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
    return _run(() => _repository.login(
      LoginRequest(email: email, password: password),
    ));
  }

  Future<bool> register({
    required String firstname,
    required String lastname,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return _run(() => _repository.register(
      RegisterRequest(
        firstname: firstname,
        lastname: lastname,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      ),
    ));
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
```

---

### Screens - Login

> `features/auth/presentation/screens/login_screen.dart`
>
> Pushed with `Navigator` (e.g. from Settings, or before starting a rental).
> Pops with `true` on success so the caller can continue its flow.

```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await context.read<AuthProvider>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (ok && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isLoading = provider.state == AppState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 8),
            if (provider.state == AppState.error)
              Text(
                provider.errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Login'),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
              child: const Text("Don't have an account? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Screens - Register

> `features/auth/presentation/screens/register_screen.dart`

```dart
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await context.read<AuthProvider>().register(
      firstname: _firstnameController.text.trim(),
      lastname: _lastnameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    // pop back past LoginScreen too — user is now logged in
    if (ok && mounted) {
      Navigator.of(context)
        ..pop()
        ..pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AuthProvider>();
    final isLoading = provider.state == AppState.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _firstnameController,
                  decoration: const InputDecoration(labelText: 'First name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastnameController,
                  decoration: const InputDecoration(labelText: 'Last name'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Password'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmController,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm password'),
          ),
          const SizedBox(height: 8),
          if (provider.state == AppState.error)
            Text(
              provider.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isLoading ? null : _submit,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create account'),
          ),
        ],
      ),
    );
  }
}
```

---

### Bootstrap Wiring

> `bootstrap.dart` — register `AuthProvider` and restore any saved session
> at launch. `AuthRepository` gets the **same** `apiClient` instance so the
> token flows into every future request (rentals).

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();
  final authRepository = AuthRepository(AuthApiService(apiClient), apiClient, LocalStorage());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository)..restoreSession(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              HomeProvider(StationRepository(StationApiService(apiClient)))
                ..loaded(),
        ),
      ],
      child: const App(),
    ),
  );
}
```

---

> [!TIP]
> **Usage from anywhere** (e.g. a future "Rent" button):
>
> ```dart
> final auth = context.read<AuthProvider>();
> if (!auth.isLoggedIn) {
>   final ok = await Navigator.push<bool>(
>     context,
>     MaterialPageRoute(builder: (_) => const LoginScreen()),
>   );
>   if (ok != true) return; // user backed out
> }
> // proceed to start rental — token is already on ApiClient
> ```
