import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
}
