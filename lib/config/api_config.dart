class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}
