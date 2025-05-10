import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String DRIVER_ID_KEY = 'driver_id';
  static const String USER_DATA_KEY = 'user_data';

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(DRIVER_ID_KEY, userData['id'].toString());
    await prefs.setString('token', userData['token']);
    await prefs.setString(USER_DATA_KEY, jsonEncode(userData));
  }

  static Future<String?> getDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(DRIVER_ID_KEY);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(DRIVER_ID_KEY);
    await prefs.remove(USER_DATA_KEY);
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Constants.apiUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        await saveUserData(userData);
        
        // After successful login, update FCM token
        final fcmToken = await getFcmToken();
        if (fcmToken != null) {
          final fcmService = FCMService();
          final tokenUpdated = await fcmService.updateFcmToken(
            userData['user']['id'].toString(),
            fcmToken,
          );
          
          if (!tokenUpdated) {
            print('⚠️ Échec de la mise à jour du token FCM après la connexion');
          }
        }
        
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      return false;
    }
  }
}
