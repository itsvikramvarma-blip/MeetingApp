/// API Configuration for Meeting App
/// Configure your API base URL and endpoints here

class ApiConfig {
  // Production API base URL
  static const String baseUrl = 'https://www.vasavyavidyalayam.in/meeting_api';
  
  // API Endpoints
  static const String authLogin = '$baseUrl/auth/login';
  static const String authRegister = '$baseUrl/auth/register';
  static const String meetingsEndpoint = '$baseUrl/meetings';
  static const String tasksEndpoint = '$baseUrl/tasks';
  static const String minutesEndpoint = '$baseUrl/meetings';
  
  // Request timeout (seconds)
  static const int requestTimeout = 30;
  
  // For development/testing - change to false in production
  static const bool useMockData = false; // Set to true to use local mock data
}
