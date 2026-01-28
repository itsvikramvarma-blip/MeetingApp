import 'package:http/http.dart' as http;
import 'dart:convert';

/// Diagnostic script to test API connectivity
/// Run this in Flutter to identify 404 issues
class APIDiagnostics {
  static const String baseUrl = 'https://www.vasavyavidyalayam.in/meeting_api';
  
  static Future<void> runDiagnostics() async {
    print('=== API Diagnostics ===\n');
    
    await testDomainAccess();
    await testAPIRoot();
    await testAuthEndpoint();
    await testMeetingsEndpoint();
  }
  
  /// Test 1: Can we reach the domain?
  static Future<void> testDomainAccess() async {
    print('Test 1: Domain Access');
    try {
      final response = await http
          .get(Uri.parse('https://www.vasavyavidyalayam.in/'))
          .timeout(const Duration(seconds: 10));
      
      print('✅ Domain accessible');
      print('Status: ${response.statusCode}\n');
    } catch (e) {
      print('❌ Cannot reach domain');
      print('Error: $e\n');
    }
  }
  
  /// Test 2: Does /meeting_api exist?
  static Future<void> testAPIRoot() async {
    print('Test 2: API Root Path');
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(const Duration(seconds: 10));
      
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body.substring(0, 200)}...\n');
      
      if (response.statusCode == 404) {
        print('❌ 404 - API folder not found at $baseUrl');
        print('Possible causes:');
        print('  1. Folder not uploaded to server');
        print('  2. Incorrect path on server');
        print('  3. .htaccess not configured\n');
      } else if (response.statusCode == 200) {
        print('✅ API root is accessible\n');
      } else {
        print('⚠️  Unexpected status: ${response.statusCode}\n');
      }
    } catch (e) {
      print('❌ Error accessing API root');
      print('Error: $e\n');
    }
  }
  
  /// Test 3: Test auth endpoint
  static Future<void> testAuthEndpoint() async {
    print('Test 3: Auth Endpoint');
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': 'test@test.com',
              'password': 'test'
            }),
          )
          .timeout(const Duration(seconds: 10));
      
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}\n');
      
      if (response.statusCode == 404) {
        print('❌ Auth endpoint not found');
      } else if (response.statusCode == 200 || response.statusCode == 401) {
        print('✅ Auth endpoint is responding\n');
      }
    } catch (e) {
      print('❌ Error calling auth endpoint');
      print('Error: $e\n');
    }
  }
  
  /// Test 4: Test meetings endpoint
  static Future<void> testMeetingsEndpoint() async {
    print('Test 4: Meetings Endpoint');
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/meetings'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer test-token'
            },
          )
          .timeout(const Duration(seconds: 10));
      
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body.substring(0, 200)}...\n');
      
      if (response.statusCode == 404) {
        print('❌ Meetings endpoint not found');
      } else if (response.statusCode == 401 || response.statusCode == 200) {
        print('✅ Meetings endpoint is responding\n');
      }
    } catch (e) {
      print('❌ Error calling meetings endpoint');
      print('Error: $e\n');
    }
  }
  
  /// Suggest fixes based on diagnostics
  static void suggestFixes() {
    print('=== Suggested Fixes ===\n');
    
    print('If domain is accessible but /meeting_api returns 404:');
    print('1. SSH to server: ssh u403094450@vasavyavidyalayam.in');
    print('2. Check folder: ls -la public_html/meeting_api/');
    print('3. If missing, upload api/php/* to public_html/meeting_api/');
    print('4. Run: composer install');
    print('5. Run: chmod -R 755 public_html/meeting_api/');
    print('6. Test: curl https://www.vasavyavidyalayam.in/meeting_api/\n');
    
    print('Alternative paths to try:');
    print('- https://www.vasavyavidyalayam.in/ (root)');
    print('- https://api.vasavyavidyalayam.in/ (subdomain)');
    print('- https://www.vasavyavidyalayam.in/api/ (different folder)\n');
  }
}

// Usage in your app:
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await APIDiagnostics.runDiagnostics();
//   APIDiagnostics.suggestFixes();
//   runApp(const MeetingApp());
// }
