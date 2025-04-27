import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // 🔹 Définition de l'URL de base selon la plateforme
  static String get baseUrl {
    // true = téléphone réel, false = émulateur
    const bool isPhysicalDevice = true;

    if (defaultTargetPlatform == TargetPlatform.android && !isPhysicalDevice) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://192.168.1.110:8000/api'; // remplace par ton IP locale
    }
  }

  // 🔹 INSCRIPTION CHAUFFEUR
  static Future<Map<String, dynamic>> registerDriver(Map<String, dynamic> driverData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(driverData),
      );

      print("🔹 [INSCRIPTION] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 CONNEXION CHAUFFEUR
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      print("🔹 [CONNEXION] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await saveToken(data['token']); // Sauvegarder le token après la connexion
        }
        return data;
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 ENREGISTRER LE TOKEN (Stockage sécurisé)
  static Future<void> saveToken(String token) async {
    print('save token ======= $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // 🔹 RÉCUPÉRER LE TOKEN
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 🔹 SUPPRIMER LE TOKEN (Déconnexion)
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 🔹 LOGOUT (Déconnexion)
  static Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/driver/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        print("🔹 [LOGOUT] Code: ${response.statusCode}, Réponse: ${response.body}");

        if (response.statusCode == 200) {
          await deleteToken(); // Supprime le token local
        } else {
          throw Exception("Erreur de déconnexion");
        }
      } else {
        throw Exception("Token non trouvé");
      }
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
      throw e;
    }
  }

  // 🔹 RÉCUPÉRER LES DONNÉES D'UN CHAUFFEUR SPÉCIFIQUE
  static Future<Map<String, dynamic>> getDriverData(String driverId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/driver/$driverId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("🔹 [DONNÉES CHAUFFEUR] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 GESTION DES ERREURS HTTP
  static String _handleError(http.Response response) {
    try {
      final Map<String, dynamic> errorData = json.decode(response.body);
      return errorData['message'] ?? 'Erreur inconnue (${response.statusCode})';
    } catch (e) {
      return 'Erreur de traitement (${response.statusCode})';
    }
  }

  // 🔹 METTRE À JOUR LE TOKEN FCM
  static Future<bool> updateDriverFCMToken(String driverId, String fcmToken) async {
    try {
      print('🔍 Tentative de mise à jour du token FCM');
      print('📱 Driver ID: $driverId');
      print('🔑 FCM Token: $fcmToken');
      print('🌐 URL: $baseUrl/driver/fcm/token/update');

      final payload = {
        'driver_id': driverId,
        'fcm_token': fcmToken,
      };
      print('📦 Payload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/driver/fcm/token/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      print("📥 [UPDATE FCM] Status: ${response.statusCode}");
      print("📄 Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Erreur lors de la mise à jour du token FCM : $e");
      return false;
    }
  }

  // 🔹 RÉCUPÉRER LE PROFIL DU CHAUFFEUR PAR ID
  static Future<Map<String, dynamic>> getDriverProfileById(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/driver/$driverId/profile'),
        headers: {'Content-Type': 'application/json'},
      );

      print("🔹 [PROFIL CHAUFFEUR] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'error': _handleError(response)};
      }
    } catch (e) {
      return {'error': 'Erreur de connexion : $e'};
    }
  }

  // 🔹 METTRE À JOUR LE STATUT DU CHAUFFEUR PAR ID
  static Future<Map<String, dynamic>> updateDriverStatusById(String driverId, String newStatus) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/$driverId/status/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );

      print("🔹 [MISE À JOUR STATUT] Code: ${response.statusCode}, Réponse: ${response.body}");
      return json.decode(response.body);
    } catch (e) {
      print("Erreur lors de la mise à jour du statut : $e");
      return {'error': 'Erreur lors de la mise à jour du statut'};
    }
  }

  // 🔹 METTRE À JOUR LA LOCALISATION DU CHAUFFEUR (Version sans token)
  static Future<bool> updateChauffeurLocation(String driverId, double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/driver/$driverId/location/update'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': latitude,
          'longitude': longitude,
        }),
      );

      print("🔹 [MISE À JOUR LOCALISATION] Code: ${response.statusCode}, Réponse: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("Erreur lors de la mise à jour de la localisation : $e");
      return false;
    }
  }

  // 🔹 RÉCUPÉRER LES MISSIONS DU CHAUFFEUR (Version sans token)
  static Future<List<dynamic>> getDriverMissions(String driverId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/driver/$driverId/missions'),
        headers: {'Content-Type': 'application/json'},
      );

      print("🔹 [MISSIONS] Code: ${response.statusCode}, Réponse: ${response.body}");

      if (response.statusCode == 200) {
        final missions = json.decode(response.body);
        // Vérifie que les coordonnées du client sont présentes dans chaque mission
        return missions.map((mission) {
          if (!mission.containsKey('client_latitude')) {
            mission['client_latitude'] = 0.0;
          }
          if (!mission.containsKey('client_longitude')) {
            mission['client_longitude'] = 0.0;
          }
          return mission;
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
