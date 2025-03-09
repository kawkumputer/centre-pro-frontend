class ApiConfig {
  // Base URL selon les MEMORIES
  static const String baseUrl = 'http://localhost:8080';

  // Auth endpoints selon les MEMORIES
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
  static const String currentUser = '/api/users/me';

  // Project endpoints selon les MEMORIES
  static const String projects = '/api/projects';
  static String project(int id) => '/api/projects/$id';

  // Headers selon les MEMORIES
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
