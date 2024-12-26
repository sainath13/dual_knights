// lib/config/env_config.dart

enum Environment {
  dev,
  staging,
  prod,
}

class EnvConfig {
  static Environment environment = Environment.dev;

  static String get baseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://localhost:3000/api/v1';
      case Environment.staging:
        return 'https://staging-api.yourgame.com/api/v1';
      case Environment.prod:
        return 'https://api.yourgame.com/api/v1';
    }
  }

  static Map<String, String> get headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    
    // Add environment-specific headers
    switch (environment) {
      case Environment.dev:
        headers['X-Environment'] = 'development';
        break;
      case Environment.staging:
        headers['X-Environment'] = 'staging';
        break;
      case Environment.prod:
        headers['X-Environment'] = 'production';
        break;
    }
    
    return headers;
  }
}
