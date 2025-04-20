import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class DriverService {
  static Future<Map<String, dynamic>> getDriverProfile(String? driverId) async {
    try {
      if (driverId == null) {
        throw Exception('ID du chauffeur non disponible');
      }

      final url = '${ApiConfig.baseUrl}${ApiConfig.getDriverUrl(driverId)}';
      print('Fetching profile from URL: $url');
      
      final headers = await ApiConfig.getAuthHeaders();
      print('Request headers: $headers');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('Profile response status: ${response.statusCode}');
      print('Profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors du chargement du profil');
      }
    } catch (e) {
      print('Error fetching driver profile: $e');
      throw Exception('Erreur lors du chargement du profil: $e');
    }
  }
}
