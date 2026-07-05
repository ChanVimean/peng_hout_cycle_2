class ApiEndpoints {
  ApiEndpoints();

  static const String baseUrl = 'https://peng-houth-cycle-api.onrender.com/api';
  // static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Stations
  static const String stations = '/stations';
  static String stationDetail(int id) => '/stations/$id';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
}
