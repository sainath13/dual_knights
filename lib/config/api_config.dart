// lib/config/api_config.dart

class ApiConfig {
  // Base URLs
  static const String baseUrl = 'http://localhost:3000/api/v1';
  
  // API Endpoints
  static const String gameLevels = '/game-levels';
  static const String maps = '/maps';
  static const String themes = '/themes';
  
  // API Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  
  // Status Codes
  static const int successCode = 200;
  static const int createdCode = 201;
  static const int badRequestCode = 400;
  static const int unauthorizedCode = 401;
  static const int notFoundCode = 404;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
