class ApiConfig {
  // Configuration de l'API avec le contexte path correct
  static const String baseUrl = 'http://localhost:8080';
  
  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String signup = '/api/auth/signup';
  static const String currentUser = '/api/users/me';
  
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
