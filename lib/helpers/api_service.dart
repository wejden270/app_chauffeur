import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DriverNotFoundException implements Exception {
  final String message;
  DriverNotFoundException(this.message);
}

class ApiService {
  static const String DRIVER_ID_KEY = 'driver_id';
  static String? _connectedDriverId;

  // Méthode d'authentification
  static Future<String> authenticateDriver(String phone, String password) async {
    final url = Uri.parse('$baseUrl/driver/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final driverId = data['driver']['id'].toString();
        await _saveDriverId(driverId);
        return driverId;
      } else {
        throw Exception('Échec de l\'authentification');
      }
    } catch (e) {
      print('🔥 Erreur d\'authentification: $e');
      rethrow;
    }
  }

  static Future<void> _saveDriverId(String driverId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(DRIVER_ID_KEY, driverId);
    _connectedDriverId = driverId;
  }

  static Future<String?> getStoredDriverId() async {
    final prefs = await SharedPreferences.getInstance();
    _connectedDriverId = prefs.getString(DRIVER_ID_KEY);
    return _connectedDriverId;
  }

  // Méthode pour définir l'ID du driver connecté
  static void setConnectedDriverId(String driverId) {
    _connectedDriverId = driverId;
  }

  // Méthode pour obtenir l'ID du driver connecté
  static String? getConnectedDriverId() {
    return _connectedDriverId;
  }

  static String get baseUrl {
    return 'http://192.168.1.110:8000/api'; // remplace par l'IP réelle de ton PC
  }

  static Future<void> updateDriverFCMToken(String? driverId, String fcmToken) async {
    final String? actualDriverId = driverId ?? await getStoredDriverId();
    if (actualDriverId == null) {
      throw Exception('Veuillez vous authentifier d\'abord');
    }

    final url = Uri.parse('$baseUrl/driver/$actualDriverId/fcm-token');

    final payload = {
      'fcm_token': fcmToken,
      'device_type': 'android',
    };

    print('📤 Envoi du token FCM au serveur');
    print('URL: $url');
    print('Payload: $payload');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Token FCM mis à jour avec succès sur le serveur');
      } else if (responseData['error']?.contains('No query results for model')) {
        throw DriverNotFoundException('Le chauffeur avec l\'ID $driverId n\'existe pas');
      } else {
        print('❌ Échec de la mise à jour du token FCM. Code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      if (e is DriverNotFoundException) {
        rethrow;
      }
      print('🔥 Erreur lors de la mise à jour du token FCM: $e');
    }
  }

  static Future<void> updateChauffeurLocation(String driverId, double latitude, double longitude) async {
    final url = Uri.parse('$baseUrl/chauffeurs/update-location');

    final payload = {
      'driver_id': driverId,
      'latitude': latitude,
      'longitude': longitude,
    };

    print('📍 Envoi position chauffeur');
    print('URL: $url');
    print('Données: $payload');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('📥 Réponse: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Échec mise à jour position: ${response.body}');
      }
    } catch (e) {
      print('❌ Erreur: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(DRIVER_ID_KEY);
    _connectedDriverId = null;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);
      
      if (response.statusCode != 200) {
        throw Exception(data['message'] ?? 'Échec de la connexion');
      }

      // Vérifier que toutes les données nécessaires sont présentes
      if (data['driver'] == null || data['driver']['id'] == null) {
        throw Exception('Données de connexion invalides');
      }

      return data;
    } catch (e) {
      print('Erreur de connexion: $e');
      rethrow;
    }
  }
}
