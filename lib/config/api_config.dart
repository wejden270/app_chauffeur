import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://192.168.1.110:8000/api';
  
  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/driver/{id}/profile';  // Mise à jour pour correspondre à l'URL exacte
  
  // Fonction utilitaire pour remplacer l'ID dans l'URL
  static String getDriverUrl(String driverId) {
    return profile.replaceAll('{id}', driverId);
  }
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
