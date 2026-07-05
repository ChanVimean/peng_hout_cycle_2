import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';
  static const _rentalKey = 'active_rental_id';

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

  Future<void> saveActiveRentalId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_rentalKey, id);
  }

  Future<int?> readActiveRentalId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_rentalKey);
  }

  Future<void> clearActiveRentalId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rentalKey);
  }
}
