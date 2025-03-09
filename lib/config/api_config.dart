class ApiConfig {
  // Configuration de l'API avec le contexte path correct
  static const String baseUrl = 'http://192.168.1.27:8080/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String currentUser = '/users/me';

  // Project endpoints
  static const String projects = '/projects';
  static String project(int id) => '/projects/$id';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
